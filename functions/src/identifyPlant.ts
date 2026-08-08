/**
 * identifyPlant Cloud Function
 * 
 * Core endpoint — receives plant photo, identifies via AI provider,
 * builds the plant profile directly from AI response (no Firestore plant DB lookup),
 * handles unlock/duplicate logic via user_plants, awards XP,
 * evaluates achievements, writes audit log.
 */

import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';
import sharp from 'sharp';
import { v4 as uuidv4 } from 'uuid';
import { z } from 'zod';

import { identifyPlantImage, IdentificationResult } from './utils/aiProvider.js';
import { validateImage, ExifData } from './utils/antiSpoofing.js';
import { evaluateAchievements } from './utils/achievements.js';
import { analyzeSafety, SafetyInfo } from './utils/safetyAnalyzer.js';
import {
  getUserById,
  incrementUserStats,
  createScanLog,
  checkDailyScanLimit,
  incrementDailyScanCount,
  serverTimestamp,
} from './utils/firestore.js';

// ─── Request Validation Schema ────────────────────────────────────
const identifyPlantSchema = z.object({
  exif_data: z.string().optional(),
  location: z.string().optional(),
  device_model: z.string().optional(),
  app_version: z.string().optional(),
});

// Note: Schema ready for future request body validation
void identifyPlantSchema;

// ─── Constants ────────────────────────────────────────────────────
const CONFIDENCE_THRESHOLD = 0.6;
const XP_UNLOCK = 100;
const XP_DUPLICATE = 50;
const XP_UNMATCHED = 10;

// ── Rarity distribution (since we don't look up from DB) ──────────
function rollRarity(): 'normal' | 'rare' | 'special_rare' {
  const r = Math.random();
  if (r < 0.05) return 'special_rare';  // 5%
  if (r < 0.20) return 'rare';           // 15%
  return 'normal';                        // 80%
}

// ── Key helper: deterministic user_plant ID from species ──────────
function userPlantKey(uid: string, scientificName: string): string {
  const normalized = scientificName.trim().toLowerCase().replace(/\s+/g, '_');
  return `${uid}_${normalized}`;
}

// ── Check if user already has this plant ──────────────────────────
async function getUserPlantBySpecies(uid: string, scientificName: string): Promise<any | null> {
  const key = userPlantKey(uid, scientificName);
  const doc = await admin.firestore().collection('user_plants').doc(key).get();
  if (doc.exists) {
    return { id: doc.id, ...doc.data() };
  }
  return null;
}

// ─── Cloud Function ──────────────────────────────────────────────
export const identifyPlant = functions
  .runWith({
    timeoutSeconds: 60,
    memory: '512MB',
  })
  .https.onRequest(async (req, res) => {
    // CORS
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    if (req.method !== 'POST') {
      res.status(405).json({ success: false, error: 'method_not_allowed' });
      return;
    }

    try {
      // 1. Authenticate
      const authHeader = req.headers.authorization;
      if (!authHeader || !authHeader.startsWith('Bearer ')) {
        res.status(401).json({ success: false, error: 'unauthenticated' });
        return;
      }

      const token = authHeader.split('Bearer ')[1];
      let decoded;
      try {
        decoded = await admin.auth().verifyIdToken(token);
      } catch {
        res.status(401).json({ success: false, error: 'unauthenticated' });
        return;
      }

      const uid = decoded.uid;
      console.log(`[identifyPlant] User: ${uid}`);

      // 2. Parse multipart form data
      const busboy = require('busboy');
      const fields: Record<string, string> = {};
      let imageBuffer: Buffer | null = null;

      // Parse the request
      const parsed = await new Promise<{ fields: Record<string, string>; image: Buffer | null }>(
        (resolve, reject) => {
          const bb = busboy({ headers: req.headers });
          const f: Record<string, string> = {};
          let img: Buffer | null = null;

          bb.on('field', (name: string, val: string) => {
            f[name] = val;
          });

          bb.on('file', (_name: string, stream: any, info: any) => {
            const chunks: Buffer[] = [];
            stream.on('data', (chunk: Buffer) => chunks.push(chunk));
            stream.on('end', () => {
              img = Buffer.concat(chunks);
            });
          });

          bb.on('finish', () => resolve({ fields: f, image: img }));
          bb.on('error', (err: Error) => reject(err));

          req.pipe(bb);
        }
      );

      if (!parsed.image) {
        res.status(400).json({ success: false, error: 'invalid_request', message: 'Image required' });
        return;
      }

      // 3. Compress image to WebP
      const webpBuffer = await sharp(parsed.image)
        .resize(1024, 1024, { fit: 'inside', withoutEnlargement: true })
        .webp({ quality: 80 })
        .toBuffer();

      imageBuffer = webpBuffer;

      // 4. Upload to Firebase Storage
      const scanId = uuidv4();
      const bucket = admin.storage().bucket();
      const userPhotoPath = `user_photos/${uid}/${scanId}.webp`;
      const userThumbnailPath = `user_photos/${uid}/${scanId}_thumb.webp`;

      const file = bucket.file(userPhotoPath);
      await file.save(webpBuffer, {
        contentType: 'image/webp',
        metadata: { firebaseStorageDownloadTokens: scanId },
      });

      // Generate thumbnail
      const thumbBuffer = await sharp(webpBuffer)
        .resize(200, 200, { fit: 'cover' })
        .webp({ quality: 70 })
        .toBuffer();

      const thumbFile = bucket.file(userThumbnailPath);
      await thumbFile.save(thumbBuffer, {
        contentType: 'image/webp',
        metadata: { firebaseStorageDownloadTokens: scanId },
      });

      // Make public
      await file.makePublic();
      await thumbFile.makePublic();

      const photoUrl = `https://storage.googleapis.com/${bucket.name}/${userPhotoPath}`;
      const thumbnailUrl = `https://storage.googleapis.com/${bucket.name}/${userThumbnailPath}`;

      // 5. Get user data
      const user = await getUserById(uid);
      const userLanguage = user?.language || 'en';
      const userTier = user?.tier || 'free';

      // 6. Check daily scan limit
      const limitCheck = await checkDailyScanLimit(uid, userTier);
      if (!limitCheck.allowed) {
        res.status(429).json({
          success: false,
          error: 'daily_limit_reached',
          message_en: `Daily scan limit reached (${limitCheck.used}/${limitCheck.limit}).`,
          scans_used: limitCheck.used,
          scans_limit: limitCheck.limit,
        });
        return;
      }

      // 7. Anti-spoofing check
      let exifData: ExifData = { has_exif: false };
      try {
        if (parsed.fields.exif_data) {
          exifData = JSON.parse(parsed.fields.exif_data);
        }
      } catch {
        // EXIF parse failed — proceed but flag
      }
      const spoofResult = validateImage(exifData);

      // 8. AI Identification
      const imageBase64 = webpBuffer.toString('base64');
      let aiResult: IdentificationResult;

      try {
        aiResult = await identifyPlantImage(imageBase64);
      } catch (error: any) {
        console.error('[identifyPlant] AI identification failed:', error.message);
        res.status(503).json({
          success: false,
          error: 'ai_unavailable',
          message_en: 'AI identification service is temporarily unavailable. Please try again.',
        });
        return;
      }

      console.log(`[identifyPlant] AI result: ${aiResult.species}, confidence: ${aiResult.confidence}, provider: ${aiResult.provider}`);

      // 9. Check confidence
      if (aiResult.confidence < CONFIDENCE_THRESHOLD) {
        // Log the attempt
        await createScanLog({
          user_id: uid,
          photo_url: photoUrl,
          thumbnail_url: thumbnailUrl,
          plant_name: aiResult.species,
          confidence: aiResult.confidence,
          suggestions_json: aiResult.raw_response,
          matched_plant_id: null,
          is_new_unlock: false,
          xp_earned: 0,
          achievement_ids_earned: [],
          exif_valid: !spoofResult.isFlagged,
          spoofing_flags: spoofResult.flags,
          is_flagged: spoofResult.isFlagged,
          device_model: parsed.fields.device_model || null,
          app_version: parsed.fields.app_version || null,
        });

        res.status(422).json({
          success: false,
          error: 'low_confidence',
          message_en: "Couldn't identify this plant clearly. Try a closer, well-lit photo.",
          message_kh: 'មិនអាចកំណត់អត្តសញ្ញាណរុក្ខជាតិនេះបានច្បាស់ទេ។ សូមសាកល្បងថតរូបឱ្យជិត និងមានពន្លឺគ្រប់គ្រាន់។',
          confidence: aiResult.confidence,
          suggestions: ['Try better lighting', 'Focus on leaves/flowers', 'Avoid blur'],
        });
        return;
      }

      // 10. Build plant profile directly from AI result (NO database lookup)
      const rarity = rollRarity();
      const plantData = buildPlantFromAi(aiResult, photoUrl, thumbnailUrl, rarity);

      // 11. Check if user already unlocked this plant (by species key in user_plants)
      const existingUserPlant = await getUserPlantBySpecies(uid, aiResult.species);

      // 12. Safety analysis
      let safetyInfo: SafetyInfo | null = null;
      try {
        safetyInfo = await analyzeSafety(
          plantData.name_en,
          plantData.scientific_name,
          aiResult.confidence
        );
      } catch (e: any) {
        console.log('[Safety] Non-critical failure:', e.message);
      }

      if (existingUserPlant) {
        // ─── DUPLICATE — already unlocked ─────────────────────────
        await incrementUserStats(uid, { total_scans: 1 });
        await incrementDailyScanCount(uid);

        // Increment sighting count
        await admin.firestore()
          .collection('user_plants')
          .doc(userPlantKey(uid, aiResult.species))
          .update({
            sighting_count: admin.firestore.FieldValue.increment(1),
            last_seen_at: serverTimestamp(),
            updated_at: serverTimestamp(),
          });

        const newAchievements = await evaluateAchievements(uid);
        const userStats = await getUserById(uid);

        const scanLogId = await createScanLog({
          user_id: uid,
          photo_url: photoUrl,
          thumbnail_url: thumbnailUrl,
          plant_name: aiResult.species,
          confidence: aiResult.confidence,
          suggestions_json: aiResult.raw_response,
          matched_plant_id: userPlantKey(uid, aiResult.species),
          is_new_unlock: false,
          xp_earned: XP_DUPLICATE,
          achievement_ids_earned: newAchievements.map(a => a.id),
          exif_valid: !spoofResult.isFlagged,
          spoofing_flags: spoofResult.flags,
          is_flagged: spoofResult.isFlagged,
          device_model: parsed.fields.device_model || null,
          app_version: parsed.fields.app_version || null,
        });

        res.status(200).json({
          success: true,
          plant: plantData,
          is_new_unlock: false,
          is_duplicate: true,
          user_photo_url: photoUrl,
          xp_earned: XP_DUPLICATE,
          achievements_earned: newAchievements,
          safety_info: safetyInfo,
          user_stats: {
            total_xp: userStats?.total_xp || 0,
            level: userStats?.level || 1,
            total_scans: userStats?.total_scans || 0,
            plants_unlocked: userStats?.plants_unlocked || 0,
          },
          confidence: aiResult.confidence,
          match_status: 'matched',
          is_flagged: spoofResult.isFlagged,
        });
      } else {
        // ─── NEW UNLOCK! ─────────────────────────────────────────
        const upkKey = userPlantKey(uid, aiResult.species);

        // Create user_plant doc
        await admin.firestore()
          .collection('user_plants')
          .doc(upkKey)
          .set({
            user_id: uid,
            plant_id: upkKey,
            unlocked_at: serverTimestamp(),
            rarity,
            photo_url: photoUrl,
            thumbnail_url: thumbnailUrl,
            sighting_count: 1,
            last_seen_at: serverTimestamp(),
            ai_data: {
              scientific_name: aiResult.species,
              common_names: aiResult.common_names,
              family: aiResult.taxonomy.family,
              genus: aiResult.taxonomy.genus,
              characteristics: aiResult.characteristics,
              habitat: aiResult.habitat,
              uses: aiResult.uses,
            },
            created_at: serverTimestamp(),
            updated_at: serverTimestamp(),
          });

        // Update user stats
        await incrementUserStats(uid, {
          total_xp: XP_UNLOCK,
          total_scans: 1,
          plants_unlocked: 1,
          [`${rarity}_count`]: 1,
        });

        await incrementDailyScanCount(uid);

        // Evaluate achievements
        const newAchievements = await evaluateAchievements(uid);
        const userStats = await getUserById(uid);

        const scanLogId = await createScanLog({
          user_id: uid,
          photo_url: photoUrl,
          thumbnail_url: thumbnailUrl,
          plant_name: aiResult.species,
          confidence: aiResult.confidence,
          suggestions_json: aiResult.raw_response,
          matched_plant_id: upkKey,
          is_new_unlock: true,
          xp_earned: XP_UNLOCK,
          achievement_ids_earned: newAchievements.map(a => a.id),
          exif_valid: !spoofResult.isFlagged,
          spoofing_flags: spoofResult.flags,
          is_flagged: spoofResult.isFlagged,
          device_model: parsed.fields.device_model || null,
          app_version: parsed.fields.app_version || null,
        });

        res.status(200).json({
          success: true,
          plant: plantData,
          is_new_unlock: true,
          is_duplicate: false,
          user_photo_url: photoUrl,
          xp_earned: XP_UNLOCK,
          achievements_earned: newAchievements,
          safety_info: safetyInfo,
          user_stats: {
            total_xp: userStats?.total_xp || XP_UNLOCK,
            level: userStats?.level || 1,
            total_scans: userStats?.total_scans || 1,
            plants_unlocked: userStats?.plants_unlocked || 1,
          },
          confidence: aiResult.confidence,
          match_status: 'matched',
          is_flagged: spoofResult.isFlagged,
        });
      }

    } catch (error: any) {
      console.error('[identifyPlant] Unexpected error:', error);
      res.status(500).json({
        success: false,
        error: 'internal_error',
        message_en: 'Something went wrong. Please try again.',
      });
    }
  });

// ─── Helper: Build plant response from AI result ──────────────────
function buildPlantFromAi(
  aiResult: IdentificationResult,
  photoUrl: string,
  thumbnailUrl: string,
  rarity: string,
) {
  const species = aiResult.species || 'Unknown';
  const commonName = aiResult.common_names && aiResult.common_names.length > 0
    ? aiResult.common_names[0]
    : species;

  return {
    id: species.trim().toLowerCase().replace(/\s+/g, '_'),
    name_en: commonName,
    name_kh: '',   // To be filled by enrichment or UI defaults to English
    scientific_name: species,
    family: aiResult.taxonomy?.family || '',
    genus: aiResult.taxonomy?.genus || '',
    species: aiResult.taxonomy?.species || '',
    rarity,
    description: aiResult.characteristics || '',
    description_en: aiResult.characteristics || '',
    description_kh: '',
    origin: aiResult.habitat || '',
    origin_en: aiResult.habitat || '',
    origin_kh: '',
    characteristics_en: aiResult.characteristics || '',
    characteristics_kh: '',
    habitat_en: aiResult.habitat || '',
    habitat_kh: '',
    uses_en: aiResult.uses || '',
    uses_kh: '',
    care_en: {},
    care_kh: {},
    fun_facts_en: [] as string[],
    fun_facts_kh: [] as string[],
    image_urls: [photoUrl],
    thumbnail_url: thumbnailUrl,
  };
}