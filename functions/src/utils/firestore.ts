/**
 * Firestore utility helpers — collection references, batch operations, queries.
 */

import * as admin from 'firebase-admin';

// Initialize admin if not already done
if (admin.apps.length === 0) {
  admin.initializeApp();
}

export const db = admin.firestore();

// ─── Collection References ────────────────────────────────────────
export const plantsCol = () => db.collection('plants');
export const usersCol = () => db.collection('users');
export const userPlantsCol = () => db.collection('user_plants');
export const achievementsCol = () => db.collection('achievements');
export const userAchievementsCol = () => db.collection('user_achievements');
export const scansCol = () => db.collection('scans');
export const unverifiedPlantsCol = () => db.collection('unverified_plants');
export const flaggedPhotosCol = () => db.collection('flagged_photos');

// ─── Plant Queries ────────────────────────────────────────────────
export async function findPlantByScientificName(scientificName: string): Promise<any> {
  const cleaned = scientificName.trim().toLowerCase();
  const snapshot = await plantsCol()
    .where('scientific_name_lower', '==', cleaned)
    .where('verified', '==', true)
    .limit(1)
    .get();

  if (!snapshot.empty) {
    return { id: snapshot.docs[0].id, ...snapshot.docs[0].data() };
  }
  return null;
}

export async function findPlantById(plantId: string): Promise<any> {
  const doc = await plantsCol().doc(plantId).get();
  if (doc.exists) {
    return { id: doc.id, ...doc.data() };
  }
  return null;
}

// ─── User Queries ─────────────────────────────────────────────────
export async function getUserById(uid: string): Promise<any> {
  const doc = await usersCol().doc(uid).get();
  if (doc.exists) {
    return { id: doc.id, ...doc.data() };
  }
  return null;
}

export async function getUserPlant(uid: string, plantId: string): Promise<any> {
  const doc = await userPlantsCol().doc(`${uid}_${plantId}`).get();
  if (doc.exists) {
    return { id: doc.id, ...doc.data() };
  }
  return null;
}

// ─── Stats Helpers ────────────────────────────────────────────────
export async function incrementUserStats(
  uid: string,
  updates: Record<string, number>
) {
  const ref = usersCol().doc(uid);
  await db.runTransaction(async (transaction) => {
    const doc = await transaction.get(ref);
    if (!doc.exists) return;

    const data: Record<string, any> = {};
    for (const [key, increment] of Object.entries(updates)) {
      data[key] = admin.firestore.FieldValue.increment(increment);
    }
    data['last_active'] = admin.firestore.FieldValue.serverTimestamp();

    transaction.update(ref, data);
  });
}

export async function incrementPlantUnlockCount(plantId: string) {
  const ref = plantsCol().doc(plantId);
  await ref.update({
    total_unlocks: admin.firestore.FieldValue.increment(1),
    updated_at: admin.firestore.FieldValue.serverTimestamp(),
  });
}

// ─── Scan Audit Log ───────────────────────────────────────────────
export async function createScanLog(data: Record<string, any>) {
  const ref = scansCol().doc();
  await ref.set({
    ...data,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });
  return ref.id;
}

// ─── Unverified Plant ─────────────────────────────────────────────
export async function createOrUpdateUnverified(data: {
  scientific_name: string;
  common_names: string[];
  suggestions_json: string;
  user_id: string;
  photo_url: string;
  confidence: number;
}) {
  // Check if already exists by scientific name
  const cleaned = data.scientific_name.trim().toLowerCase();
  const existing = await unverifiedPlantsCol()
    .where('scientific_name_lower', '==', cleaned)
    .where('status', '==', 'pending')
    .limit(1)
    .get();

  if (!existing.empty) {
    const doc = existing.docs[0];
    await doc.ref.update({
      user_ids: admin.firestore.FieldValue.arrayUnion(data.user_id),
      photo_urls: admin.firestore.FieldValue.arrayUnion(data.photo_url),
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  // Create new
  const ref = unverifiedPlantsCol().doc();
  await ref.set({
    plant_name: data.common_names[0] || data.scientific_name,
    scientific_name: data.scientific_name,
    scientific_name_lower: cleaned,
    common_names: data.common_names,
    suggestions_json: data.suggestions_json,
    user_ids: [data.user_id],
    photo_urls: [data.photo_url],
    status: 'pending',
    created_at: admin.firestore.FieldValue.serverTimestamp(),
    updated_at: admin.firestore.FieldValue.serverTimestamp(),
  });
  return ref.id;
}

// ─── Daily Scan Limit ────────────────────────────────────────────
export async function checkDailyScanLimit(uid: string, tier = 'free'): Promise<{
  allowed: boolean;
  used: number;
  limit: number;
}> {
  const user = await getUserById(uid);
  if (!user) return { allowed: true, used: 0, limit: 5 };

  const limits: Record<string, number> = {
    free: 5,
    trial: 10,
    premium: -1, // unlimited
  };

  const limit = limits[tier] ?? 5;

  // Premium: always allowed
  if (limit === -1) return { allowed: true, used: 0, limit: -1 };

  // Check if we need to reset (new day)
  const lastScanDate = user.last_scan_date as string | undefined;
  const today = new Date().toISOString().split('T')[0];

  if (lastScanDate !== today) {
    // New day — reset
    await usersCol().doc(uid).update({
      daily_scans_used: 0,
      last_scan_date: today,
    });
    return { allowed: true, used: 0, limit };
  }

  const used = (user.daily_scans_used as number) || 0;
  return { allowed: used < limit, used, limit };
}

export async function incrementDailyScanCount(uid: string) {
  const ref = usersCol().doc(uid);
  const doc = await ref.get();
  if (!doc.exists) {
    // Create user doc if it doesn't exist yet (race with auth trigger)
    await ref.set({
      uid,
      display_name: 'Explorer',
      email: '',
      language: 'en',
      tier: 'free',
      daily_scans_used: 1,
      last_scan_date: new Date().toISOString().split('T')[0],
      total_xp: 0,
      level: 1,
      total_scans: 0,
      plants_unlocked: 0,
      normal_count: 0,
      rare_count: 0,
      special_rare_count: 0,
      achievements_earned: 0,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      last_active: admin.firestore.FieldValue.serverTimestamp(),
    });
    return;
  }
  await ref.update({
    daily_scans_used: admin.firestore.FieldValue.increment(1),
    last_scan_date: new Date().toISOString().split('T')[0],
  });
}

// ─── Timestamp ────────────────────────────────────────────────────
export const serverTimestamp = () => admin.firestore.FieldValue.serverTimestamp();