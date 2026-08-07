/**
 * adminApi Cloud Function
 * 
 * All admin operations — secured by Firebase custom claims (admin: true).
 * Actions: plant CRUD, user management, review queues, analytics.
 */

import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';

const db = admin.firestore();

// ─── Auth Middleware ──────────────────────────────────────────────
async function requireAdmin(req: any) {
  const authHeader = req.headers.authorization;
  if (!authHeader?.startsWith('Bearer ')) {
    throw new Error('unauthenticated');
  }

  const token = authHeader.split('Bearer ')[1];
  const decoded = await admin.auth().verifyIdToken(token);

  if (!decoded.admin) {
    throw new Error('forbidden');
  }

  return decoded;
}

// ─── Cloud Function ──────────────────────────────────────────────
export const adminApi = functions
  .runWith({ timeoutSeconds: 60, memory: '256MB' })
  .https.onRequest(async (req, res) => {
    res.set('Access-Control-Allow-Origin', '*');
    res.set('Access-Control-Allow-Methods', 'POST, OPTIONS');
    res.set('Access-Control-Allow-Headers', 'Content-Type, Authorization');

    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    try {
      const adminUser = await requireAdmin(req);
      console.log(`[adminApi] Admin: ${adminUser.uid}, action: ${req.body?.action}`);

      const { action, payload } = req.body || {};

      switch (action) {
        // ─── Plant CRUD ────────────────────────────────────────
        case 'createPlant':
          return await handleCreatePlant(payload, res);
        case 'updatePlant':
          return await handleUpdatePlant(payload, res);
        case 'deletePlant':
          return await handleDeletePlant(payload, res);
        case 'listPlants':
          return await handleListPlants(payload, res);
        case 'getPlant':
          return await handleGetPlant(payload, res);

        // ─── User Management ──────────────────────────────────
        case 'listUsers':
          return await handleListUsers(payload, res);
        case 'getUserDetail':
          return await handleGetUserDetail(payload, res);
        case 'banUser':
          return await handleBanUser(payload, res);

        // ─── Review Queues ────────────────────────────────────
        case 'listUnverified':
          return await handleListUnverified(payload, res);
        case 'reviewUnverified':
          return await handleReviewUnverified(payload, res);
        case 'listFlagged':
          return await handleListFlagged(payload, res);
        case 'reviewFlaggedPhoto':
          return await handleReviewFlaggedPhoto(payload, res);

        // ─── Achievements ─────────────────────────────────────
        case 'createAchievement':
          return await handleCreateAchievement(payload, res);
        case 'updateAchievement':
          return await handleUpdateAchievement(payload, res);

        // ─── Analytics ────────────────────────────────────────
        case 'getAnalytics':
          return await handleGetAnalytics(payload, res);

        default:
          res.status(400).json({ success: false, error: 'unknown_action' });
      }
    } catch (error: any) {
      if (error.message === 'unauthenticated') {
        res.status(401).json({ success: false, error: 'unauthenticated' });
      } else if (error.message === 'forbidden') {
        res.status(403).json({ success: false, error: 'forbidden' });
      } else {
        console.error('[adminApi] Error:', error);
        res.status(500).json({ success: false, error: 'internal_error' });
      }
    }
  });

// ─── Plant Handlers ─────────────────────────────────────────────

async function handleCreatePlant(payload: any, res: any) {
  const docRef = db.collection('plants').doc();
  const plantData = {
    ...payload,
    scientific_name_lower: (payload.scientific_name || '').toLowerCase(),
    verified: payload.verified ?? false,
    rarity: payload.rarity || 'normal',
    image_urls: payload.image_urls || [],
    search_keywords: [
      (payload.name_en || '').toLowerCase(),
      (payload.name_kh || ''),
      (payload.scientific_name || '').toLowerCase(),
    ].filter(Boolean),
    total_unlocks: 0,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
    updated_at: admin.firestore.FieldValue.serverTimestamp(),
  };

  await docRef.set(plantData);
  res.status(200).json({ success: true, plant_id: docRef.id });
}

async function handleUpdatePlant(payload: any, res: any) {
  const { plant_id, ...updateData } = payload;
  if (!plant_id) return res.status(400).json({ success: false, error: 'plant_id required' });

  if (updateData.scientific_name) {
    updateData.scientific_name_lower = updateData.scientific_name.toLowerCase();
  }

  updateData.updated_at = admin.firestore.FieldValue.serverTimestamp();

  await db.collection('plants').doc(plant_id).update(updateData);
  res.status(200).json({ success: true });
}

async function handleDeletePlant(payload: any, res: any) {
  const { plant_id } = payload;
  if (!plant_id) return res.status(400).json({ success: false, error: 'plant_id required' });

  await db.collection('plants').doc(plant_id).delete();
  res.status(200).json({ success: true });
}

async function handleListPlants(payload: any, res: any) {
  const { page_size = 20, page = 1, rarity, search, sort = 'name_en' } = payload || {};

  let query: any = db.collection('plants');

  if (rarity && rarity !== 'all') {
    query = query.where('rarity', '==', rarity);
  }

  query = query.orderBy(sort).limit(page_size);
  // Note: offset pagination with Firestore cursors is preferred for production

  const snapshot = await query.get();
  const plants = snapshot.docs.map((doc: any) => ({ id: doc.id, ...doc.data() }));

  res.status(200).json({ success: true, plants, total: snapshot.size });
}

async function handleGetPlant(payload: any, res: any) {
  const { plant_id } = payload;
  const doc = await db.collection('plants').doc(plant_id).get();
  if (!doc.exists) return res.status(404).json({ success: false, error: 'not_found' });
  res.status(200).json({ success: true, plant: { id: doc.id, ...doc.data() } });
}

// ─── User Handlers ─────────────────────────────────────────────

async function handleListUsers(payload: any, res: any) {
  const { page_size = 20, search, tier } = payload || {};

  let query: any = db.collection('users');

  if (tier && tier !== 'all') {
    query = query.where('tier', '==', tier);
  }

  query = query.orderBy('last_active', 'desc').limit(page_size);

  const snapshot = await query.get();
  const users = snapshot.docs.map((doc: any) => ({ id: doc.id, ...doc.data() }));

  res.status(200).json({ success: true, users, total: snapshot.size });
}

async function handleGetUserDetail(payload: any, res: any) {
  const { user_id } = payload;
  if (!user_id) return res.status(400).json({ success: false, error: 'user_id required' });

  const userDoc = await db.collection('users').doc(user_id).get();
  if (!userDoc.exists) return res.status(404).json({ success: false, error: 'not_found' });

  const plantsSnapshot = await db
    .collection('user_plants')
    .where('user_id', '==', user_id)
    .get();
  const plants = plantsSnapshot.docs.map((d) => ({ id: d.id, ...d.data() }));

  res.status(200).json({
    success: true,
    user: { id: userDoc.id, ...userDoc.data() },
    plants,
  });
}

async function handleBanUser(payload: any, res: any) {
  const { user_id, reason } = payload;
  if (!user_id) return res.status(400).json({ success: false, error: 'user_id required' });

  // Disable the user in Firebase Auth
  await admin.auth().updateUser(user_id, { disabled: true });

  await db.collection('users').doc(user_id).update({
    banned: true,
    ban_reason: reason,
    banned_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  res.status(200).json({ success: true });
}

// ─── Review Queue Handlers ────────────────────────────────────

async function handleListUnverified(payload: any, res: any) {
  const { page_size = 20, status = 'pending' } = payload || {};

  const snapshot = await db
    .collection('unverified_plants')
    .where('status', '==', status)
    .orderBy('created_at', 'desc')
    .limit(page_size)
    .get();

  const plants = snapshot.docs.map((d) => ({ id: d.id, ...d.data() }));
  res.status(200).json({ success: true, plants, total: snapshot.size });
}

async function handleReviewUnverified(payload: any, res: any) {
  const { unverified_id, action, plant_data } = payload;
  if (!unverified_id || !action) return res.status(400).json({ success: false, error: 'missing fields' });

  const ref = db.collection('unverified_plants').doc(unverified_id);

  if (action === 'approve') {
    // Create the plant in main catalog
    const plantRef = db.collection('plants').doc();
    await plantRef.set({
      ...plant_data,
      name_en: plant_data?.name_en || '',
      name_kh: plant_data?.name_kh || '',
      scientific_name: plant_data?.scientific_name || '',
      verified: true,
      rarity: plant_data?.rarity || 'normal',
      total_unlocks: 0,
      created_at: admin.firestore.FieldValue.serverTimestamp(),
      updated_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    await ref.update({
      status: 'approved',
      approved_plant_id: plantRef.id,
      reviewed_at: admin.firestore.FieldValue.serverTimestamp(),
    });

    res.status(200).json({ success: true, plant_id: plantRef.id });
  } else if (action === 'reject') {
    await ref.update({
      status: 'rejected',
      reviewed_at: admin.firestore.FieldValue.serverTimestamp(),
    });
    res.status(200).json({ success: true });
  } else {
    res.status(400).json({ success: false, error: 'invalid action' });
  }
}

async function handleListFlagged(payload: any, res: any) {
  const { page_size = 20, status = 'pending' } = payload || {};

  const snapshot = await db
    .collection('flagged_photos')
    .where('status', '==', status)
    .orderBy('created_at', 'desc')
    .limit(page_size)
    .get();

  const photos = snapshot.docs.map((d) => ({ id: d.id, ...d.data() }));
  res.status(200).json({ success: true, photos, total: snapshot.size });
}

async function handleReviewFlaggedPhoto(payload: any, res: any) {
  const { flagged_id, action } = payload;
  if (!flagged_id || !action) return res.status(400).json({ success: false, error: 'missing fields' });

  const status = action === 'clear' ? 'cleared' : 'confirmed_spoof';

  await db.collection('flagged_photos').doc(flagged_id).update({
    status,
    reviewed_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  res.status(200).json({ success: true });
}

// ─── Achievement Handlers ─────────────────────────────────────

async function handleCreateAchievement(payload: any, res: any) {
  const { achievement_id, ...data } = payload;
  if (!achievement_id) return res.status(400).json({ success: false, error: 'achievement_id required' });

  await db.collection('achievements').doc(achievement_id).set({
    ...data,
    created_at: admin.firestore.FieldValue.serverTimestamp(),
  });

  res.status(200).json({ success: true, achievement_id });
}

async function handleUpdateAchievement(payload: any, res: any) {
  const { achievement_id, ...data } = payload;
  if (!achievement_id) return res.status(400).json({ success: false, error: 'achievement_id required' });

  await db.collection('achievements').doc(achievement_id).update(data);
  res.status(200).json({ success: true });
}

// ─── Analytics Handler ────────────────────────────────────────

async function handleGetAnalytics(payload: any, res: any) {
  const { metric, period = '7d' } = payload || {};

  let value: any = 0;

  switch (metric) {
    case 'total_users': {
      const snapshot = await db.collection('users').count().get();
      value = snapshot.data().count;
      break;
    }
    case 'total_scans': {
      const snapshot = await db.collection('scans').count().get();
      value = snapshot.data().count;
      break;
    }
    case 'total_plants': {
      const snapshot = await db
        .collection('plants')
        .where('verified', '==', true)
        .count()
        .get();
      value = snapshot.data().count;
      break;
    }
    case 'pending_reviews': {
      const snapshot = await db
        .collection('unverified_plants')
        .where('status', '==', 'pending')
        .count()
        .get();
      value = snapshot.data().count;
      break;
    }
    default:
      return res.status(400).json({ success: false, error: 'unknown metric' });
  }

  res.status(200).json({ success: true, metric, value, period });
}