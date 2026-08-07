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