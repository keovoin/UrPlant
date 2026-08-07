/**
 * Achievement Evaluation
 *
 * Checks user stats against achievement definitions and awards newly-earned ones.
 */

import * as admin from 'firebase-admin';
import { achievementsCol, userAchievementsCol, usersCol } from './firestore.js';

export interface Achievement {
  id: string;
  name_en: string;
  name_kh: string;
  description_en: string;
  description_kh: string;
  icon: string;
  type: string;
  requirement_value: number;
  xp_reward: number;
}

export interface EarnedAchievement {
  id: string;
  name: string;
  icon: string;
  xp: number;
}

// Default achievements if Firestore collection is empty
const DEFAULT_ACHIEVEMENTS: Omit<Achievement, 'id'>[] = [
  {
    name_en: 'First Scan', name_kh: 'ការស្កេនដំបូង',
    description_en: 'Complete your first plant scan', description_kh: 'បញ្ចប់ការស្កេនរុក្ខជាតិដំបូងរបស់អ្នក',
    icon: 'camera', type: 'total_scans', requirement_value: 1, xp_reward: 50,
  },
  {
    name_en: 'Plant Scout', name_kh: 'អ្នករុករករុក្ខជាតិ',
    description_en: 'Scan 10 plants', description_kh: 'ស្កេនរុក្ខជាតិចំនួន ១០',
    icon: 'explore', type: 'total_scans', requirement_value: 10, xp_reward: 100,
  },
  {
    name_en: 'Botanist', name_kh: 'អ្នករុក្ខសាស្ត្រ',
    description_en: 'Scan 50 plants', description_kh: 'ស្កេនរុក្ខជាតិចំនួន ៥០',
    icon: 'science', type: 'total_scans', requirement_value: 50, xp_reward: 300,
  },
  {
    name_en: 'First Discovery', name_kh: 'ការរកឃើញដំបូង',
    description_en: 'Unlock your first plant', description_kh: 'ដោះសោរុក្ខជាតិដំបូងរបស់អ្នក',
    icon: 'eco', type: 'plants_unlocked', requirement_value: 1, xp_reward: 50,
  },
  {
    name_en: 'Collector', name_kh: 'អ្នកប្រមូល',
    description_en: 'Unlock 5 plants', description_kh: 'ដោះសោរុក្ខជាតិចំនួន ៥',
    icon: 'collections', type: 'plants_unlocked', requirement_value: 5, xp_reward: 150,
  },
  {
    name_en: 'Plant Master', name_kh: 'មេរុក្ខជាតិ',
    description_en: 'Unlock 20 plants', description_kh: 'ដោះសោរុក្ខជាតិចំនួន ២០',
    icon: 'verified', type: 'plants_unlocked', requirement_value: 20, xp_reward: 500,
  },
  {
    name_en: 'Rare Hunter', name_kh: 'អ្នកប្រមាញ់រុក្ខជាតិកម្រ',
    description_en: 'Find a rare plant', description_kh: 'រកឃើញរុក្ខជាតិកម្រមួយ',
    icon: 'star', type: 'rare_count', requirement_value: 1, xp_reward: 200,
  },
  {
    name_en: 'Special Collector', name_kh: 'អ្នកប្រមូលពិសេស',
    description_en: 'Find a special rare plant', description_kh: 'រកឃើញរុក្ខជាតិកម្រពិសេសមួយ',
    icon: 'diamond', type: 'special_rare_count', requirement_value: 1, xp_reward: 500,
  },
];

async function getAchievementDefinitions(): Promise<Achievement[]> {
  const snapshot = await achievementsCol().orderBy('sort_order').get();

  if (!snapshot.empty) {
    return snapshot.docs.map(doc => ({
      id: doc.id,
      ...doc.data(),
    })) as Achievement[];
  }

  // Seed defaults if collection is empty
  console.log('[Achievements] Seeding default achievements');
  const batch = admin.firestore().batch();
  const seeded: Achievement[] = [];

  for (let i = 0; i < DEFAULT_ACHIEVEMENTS.length; i++) {
    const ach = DEFAULT_ACHIEVEMENTS[i];
    const ref = achievementsCol().doc();
    const data = { ...ach, sort_order: i };
    batch.set(ref, data);
    seeded.push({ id: ref.id, ...data });
  }

  await batch.commit();
  return seeded;
}

export async function evaluateAchievements(uid: string): Promise<EarnedAchievement[]> {
  const earned: EarnedAchievement[] = [];
  const achievements = await getAchievementDefinitions();
  const userDoc = await usersCol().doc(uid).get();

  if (!userDoc.exists) return earned;

  const userData = userDoc.data()!;
  const totalXp = userData.total_xp || 0;

  for (const ach of achievements) {
    // Check if already earned
    const userAchDoc = await userAchievementsCol()
      .doc(`${uid}_${ach.id}`)
      .get();

    if (userAchDoc.exists && userAchDoc.data()?.earned === true) continue;

    // Check requirement
    const statValue = userData[ach.type] || 0;
    if (statValue < ach.requirement_value) {
      // Update progress
      const currentProgress = userAchDoc.exists
        ? userAchDoc.data()!.progress || 0
        : 0;
      if (statValue > currentProgress) {
        await userAchievementsCol().doc(`${uid}_${ach.id}`).set(
          {
            user_id: uid,
            achievement_id: ach.id,
            progress: statValue,
            earned: false,
            earned_at: null,
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
          },
          { merge: true }
        );
      }
      continue;
    }

    // Earned!
    await userAchievementsCol().doc(`${uid}_${ach.id}`).set(
      {
        user_id: uid,
        achievement_id: ach.id,
        progress: ach.requirement_value,
        earned: true,
        earned_at: admin.firestore.FieldValue.serverTimestamp(),
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      },
      { merge: true }
    );

    // Award XP
    if (ach.xp_reward > 0) {
      await usersCol().doc(uid).update({
        total_xp: admin.firestore.FieldValue.increment(ach.xp_reward),
        last_active: admin.firestore.FieldValue.serverTimestamp(),
      });
    }

    earned.push({
      id: ach.id,
      name: ach.name_en,
      icon: ach.icon,
      xp: ach.xp_reward,
    });

    console.log(`[Achievements] User ${uid} earned: ${ach.name_en} (+${ach.xp_reward} XP)`);
  }

  return earned;
}