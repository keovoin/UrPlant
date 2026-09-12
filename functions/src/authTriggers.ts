/**
 * Firebase Auth Triggers
 * 
 * Automatically creates a user profile doc in Firestore when a new user signs up.
 * Initializes default stats, language preferences, and tier.
 */

import * as functions from 'firebase-functions/v1';
import * as admin from 'firebase-admin';

const db = admin.firestore();

export const onUserCreated = functions.auth.user().onCreate(async (user) => {
  console.log(`[Auth Trigger] New user created: ${user.uid} (${user.email || 'no email'})`);

  try {
    const userData = {
      uid: user.uid,
      display_name: user.displayName || user.email?.split('@')[0] || 'Explorer',
      email: user.email || '',
      photo_url: user.photoURL || null,
      language: 'en', // Default — user can change in settings
      tier: 'free',
      trial_ends_at: null,
      daily_scans_limit: 5,
      daily_scans_used: 0,
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
      deleted_at: null,
    };

    await db.collection('users').doc(user.uid).set(userData);
    console.log(`[Auth Trigger] User profile created for ${user.uid}`);

  } catch (error: any) {
    console.error(`[Auth Trigger] Failed to create user profile for ${user.uid}:`, error.message);
  }
});

/**
 * When an account is deleted (from the app or console), wipe the user's
 * personal data: profile doc, collection, achievements, scan history, and
 * uploaded photos. Without this, email/name/photos would be orphaned in the
 * database forever (GDPR / privacy requirement).
 */
export const onUserDeleted = functions.auth.user().onDelete(async (user) => {
  console.log(`[Auth Trigger] User deleted: ${user.uid} — cascading data removal`);
  const uid = user.uid;

  try {
    const batches: Promise<any>[] = [];

    batches.push(db.collection('users').doc(uid).delete().catch(() => {}));

    for (const col of ['user_plants', 'user_achievements']) {
      const snap = await db.collection(col).where('user_id', '==', uid).get();
      snap.docs.forEach((d) => batches.push(d.ref.delete().catch(() => {})));
    }

    // Anonymize scan logs instead of deleting (keep aggregate analytics).
    const scans = await db.collection('scans').where('user_id', '==', uid).get();
    scans.docs.forEach((d) =>
      batches.push(
        d.ref.update({ user_id: 'deleted', photo_url: null, thumbnail_url: null }).catch(() => {})
      )
    );

    // Remove the user's uploaded photos from Storage.
    const bucket = admin.storage().bucket();
    await bucket.deleteFiles({ prefix: `user_photos/${uid}/` });
    console.log(`[Auth Trigger] Cleared user_photos/${uid} storage objects`);

    await Promise.all(batches);
    console.log(`[Auth Trigger] Data cascade complete for ${uid}`);
  } catch (error: any) {
    console.error(`[Auth Trigger] Cascade cleanup failed for ${uid}:`, error.message);
  }
});