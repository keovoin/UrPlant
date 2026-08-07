/**
 * identifyPlant Cloud Function
 * 
 * Core endpoint — receives plant photo, identifies via AI provider,
 * checks against Firestore plant DB, handles unlock logic, awards XP,
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
  findPlantByScientificName,
  getUserById,
  getUserPlant,
  incrementUserStats,
  incrementPlantUnlockCount,
  createScanLog,
  createOrUpdateUnverified,
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

      // 9. Close client connection quickly after AI call
      // (enrichment and achievement evaluation done below)

      // 10. Check confidence
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

      // 11. Search Firestore for plant
      const matchedPlant = await findPlantByScientificName(aiResult.species);

      if (matchedPlant) {
        // ─── PLANT MATCHED ──────────────────────────────────────
        const existingUserPlant = await getUserPlant(uid, matchedPlant.id);

        if (existingUserPlant) {
          // DUPLICATE — already unlocked
          await incrementUserStats(uid, { total_scans: 1 });
          await incrementDailyScanCount(uid);

          // Increment sighting count
          await admin.firestore()
            .collection('user_plants')
            .doc(`${uid}_${matchedPlant.id}`)
            .update({
              sighting_count: admin.firestore.FieldValue.increment(1),
              last_seen_at: serverTimestamp(),
              updated_at: serverTimestamp(),
            });

          const newAchievements = await evaluateAchievements(uid);
          const userStats = await getUserById(uid);

          // Safety analysis
          let safetyInfo: SafetyInfo | null = null;
          if (matchedPlant.scientific_name) {
            try {
              safetyInfo = await analyzeSafety(
                matchedPlant.name_en || aiResult.species,
                matchedPlant.scientific_name,
                aiResult.confidence
              );
            } catch (e: any) {
              console.log('[Safety] Non-critical failure:', e.message);
            }
          }

          const scanLogId = await createScanLog({
            user_id: uid,
            photo_url: photoUrl,
            thumbnail_url: thumbnailUrl,
            plant_name: aiResult.species,
            confidence: aiResult.confidence,
            suggestions_json: aiResult.raw_response,
            matched_plant_id: matchedPlant.id,
            is_new_unlock: false,
            xp_earned: XP_DUPLICATE,
            achievement_ids_earned: newAchievements.map(a => a.id),
            exif_valid: !spoofResult.isFlagged,
            spoofing_flags: spoofResult.flags,
            is_flagged: spoofResult.isFlagged,
            device_model: parsed.fields.device_model || null,
            app_version: parsed.fields.app_version || null,
          });

          const plantData = formatPlantResponse(matchedPlant, userLanguage);

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
          // ─── NEW UNLOCK! ─────────────────────────────────────
          const rarity = matchedPlant.rarity || 'normal';

          // Create user_plant doc
          await admin.firestore()
            .collection('user_plants')
            .doc(`${uid}_${matchedPlant.id}`)
            .set({
              user_id: uid,
              plant_id: matchedPlant.id,
              unlocked_at: serverTimestamp(),
              rarity,
              photo_url: photoUrl,
              thumbnail_url: thumbnailUrl,
              sighting_count: 1,
              last_seen_at: serverTimestamp(),
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
          await incrementPlantUnlockCount(matchedPlant.id);

          // Evaluate achievements + safety
          const newAchievements = await evaluateAchievements(uid);
          const userStats = await getUserById(uid);

          let safetyInfo: SafetyInfo | null = null;
          if (matchedPlant.scientific_name) {
            try {
              safetyInfo = await analyzeSafety(
                matchedPlant.name_en || aiResult.species,
                matchedPlant.scientific_name,
                aiResult.confidence
              );
            } catch (e: any) {
              console.log('[Safety] Non-critical failure on unlock:', e.message);
            }
          }

          // Trigger enrichment if plant descriptions are sparse
          const needsEnrichment = !matchedPlant.description_en || !matchedPlant.description_kh;
          if (needsEnrichment) {
            try {
              const enrichFnUrl = `https://${req.headers.host}/enrichInfo`;
              const axios = require('axios');
              axios.post(enrichFnUrl, {
                plant_id: matchedPlant.id,
                plant_name: matchedPlant.name_en || aiResult.species,
                scientific_name: matchedPlant.scientific_name || aiResult.species,
                taxonomy: {
                  family: matchedPlant.family || '',
                  genus: matchedPlant.genus || '',
                  species: matchedPlant.species || '',
                },
                confidence: aiResult.confidence,
              }).catch((e: any) => console.log('[enrichInfo] Async trigger failed (non-critical):', e.message));
            } catch {
              // Non-critical — enrichment runs async
            }
          }

          const scanLogId = await createScanLog({
            user_id: uid,
            photo_url: photoUrl,
            thumbnail_url: thumbnailUrl,
            plant_name: aiResult.species,
            confidence: aiResult.confidence,
            suggestions_json: aiResult.raw_response,
            matched_plant_id: matchedPlant.id,
            is_new_unlock: true,
            xp_earned: XP_UNLOCK,
            achievement_ids_earned: newAchievements.map(a => a.id),
            exif_valid: !spoofResult.isFlagged,
            spoofing_flags: spoofResult.flags,
            is_flagged: spoofResult.isFlagged,
            device_model: parsed.fields.device_model || null,
            app_version: parsed.fields.app_version || null,
          });

          const plantData = formatPlantResponse(matchedPlant, userLanguage);

          res.status(200).json({
            success: true,
            plant: plantData,
            is_new_unlock: true,
            is_duplicate: false,
            user_photo_url: photoUrl,
            xp_earned: XP_UNLOCK,
            achievements_earned: newAchievements,
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
      } else {
        // ─── NO MATCH — Unverified ──────────────────────────────
        await incrementUserStats(uid, { total_xp: XP_UNMATCHED, total_scans: 1 });
        await incrementDailyScanCount(uid);

        await createOrUpdateUnverified({
          scientific_name: aiResult.species,
          common_names: aiResult.common_names,
          suggestions_json: aiResult.raw_response,
          user_id: uid,
          photo_url: photoUrl,
          confidence: aiResult.confidence,
        });

        const scanLogId = await createScanLog({
          user_id: uid,
          photo_url: photoUrl,
          thumbnail_url: thumbnailUrl,
          plant_name: aiResult.species,
          confidence: aiResult.confidence,
          suggestions_json: aiResult.raw_response,
          matched_plant_id: null,
          is_new_unlock: false,
          xp_earned: XP_UNMATCHED,
          achievement_ids_earned: [],
          exif_valid: !spoofResult.isFlagged,
          spoofing_flags: spoofResult.flags,
          is_flagged: spoofResult.isFlagged,
          device_model: parsed.fields.device_model || null,
          app_version: parsed.fields.app_version || null,
        });

        const userStats = await getUserById(uid);

        res.status(200).json({
          success: true,
          plant: null,
          is_new_unlock: false,
          is_duplicate: false,
          user_photo_url: photoUrl,
          xp_earned: XP_UNMATCHED,
          achievements_earned: [],
          user_stats: {
            total_xp: userStats?.total_xp || 0,
            level: userStats?.level || 1,
            total_scans: userStats?.total_scans || 0,
            plants_unlocked: userStats?.plants_unlocked || 0,
          },
          confidence: aiResult.confidence,
          match_status: 'unmatched',
          message_en: 'Plant identified but not yet in our database. Our team will review it soon!',
          message_kh: 'រុក្ខជាតិត្រូវបានកំណត់អត្តសញ្ញាណ ប៉ុន្តែមិនទាន់មានក្នុងមូលដ្ឋានទិន្នន័យរបស់យើងទេ។ ក្រុមការងាររបស់យើងនឹងពិនិត្យឡើងវិញក្នុងពេលឆាប់ៗនេះ!',
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

// ─── Helper: Format plant data for API response ────────────────────
function formatPlantResponse(plant: any, language: string) {
  const en = language !== 'kh';

  return {
    id: plant.id,
    name_en: plant.name_en || '',
    name_kh: plant.name_kh || '',
    scientific_name: plant.scientific_name || '',
    family: plant.family || '',
    genus: plant.genus || '',
    species: plant.species || '',
    rarity: plant.rarity || 'normal',
    description: en ? (plant.description_en || '') : (plant.description_kh || plant.description_en || ''),
    origin: en ? (plant.origin_en || '') : (plant.origin_kh || plant.origin_en || ''),
    care: en ? (plant.care_en || {}) : (plant.care_kh || plant.care_en || {}),
    fun_facts: en ? (plant.fun_facts_en || []) : (plant.fun_facts_kh || plant.fun_facts_en || []),
    image_url: plant.image_urls?.[0] || '',
    thumbnail_url: plant.thumbnail_url || '',
  };
}