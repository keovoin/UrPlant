# UrPlant — Rarity & Achievements System

> **Version**: 1.0.0 · **Last Updated**: 2026-08-06
>
> Complete specification of the rarity system, XP mechanics, level progression, and full achievement definitions for UrPlant.

---

## 1. Rarity System

### 1.1 Design Philosophy

Rarity is **pre-assigned per plant** by the admin, NOT randomly rolled per user unlock. This ensures consistency:
- An Aloe Vera is always "Normal" for every user
- A Rafflesia is always "Special Rare" for every user
- Users can discuss/share excitement about "that Rare plant I found"

Rarity distribution across the plant database should follow these admin-managed ratios:

| Rarity | Distribution | Color | Badge Icon | Card Background |
|--------|-------------|-------|------------|-----------------|
| **Normal** | ~70% of plants | Green (#4CAF50) | ★ | #E8F5E9 |
| **Rare** | ~25% of plants | Blue (#2196F3) | ✦ | #E3F2FD |
| **Special Rare** | ~5% of plants | Gold (#FFD700) | ✦✦ | #FFF8E1 |

### 1.2 Rarity Assignment Rules (Admin Guidelines)

| Rarity | Criteria | Examples |
|--------|----------|----------|
| **Normal** | Common plants found in gardens, parks, roadsides. Easily identifiable. Wide geographic distribution. | Aloe Vera, Dandelion, Grass species, Common ferns, Marigold, Bougainvillea |
| **Rare** | Less common ornamentals, regional natives, specific climate plants. Distinctive but not commonly encountered. | Orchid species, Venus flytrap, Japanese maple, Bird of paradise, Frangipani |
| **Special Rare** | Endemic species, endangered plants, extremely unusual specimens. Very limited geographic range or unique characteristics. | Rafflesia arnoldii, Titan arum, Ghost orchid, Baobab tree, Pitcher plant species |

### 1.3 UI Treatment by Rarity

| Element | Normal | Rare | Special Rare |
|---------|--------|------|-------------|
| Confetti | 20 pieces, green/white | 50 pieces, blue/silver | 100 pieces, gold/purple |
| Badge glow | None | Soft blue glow (8dp blur) | Pulsing gold glow (16dp blur) |
| Card border | 1dp green | 2dp blue | 3dp gold gradient |
| Celebration duration | 1.5s | 2.5s | 4.0s |
| Haptic feedback | Light tap | Medium double | Heavy triple |
| Profile stat highlight | Standard | Blue label | Gold label with sparkle |

---

## 2. XP & Level System

### 2.1 XP Sources

| Action | XP Earned |
|--------|-----------|
| Unlock a new plant (first time) | 100 XP |
| Duplicate identification | 50 XP |
| Matched but not in DB (unmatched) | 10 XP |
| Achievement earned | Varies (see §3) |

### 2.2 Level Calculation

```
Level = floor(sqrt(total_xp / 100))

Level 1:  0 - 99 XP     (0 plants)
Level 2:  100 - 399 XP   (1-3 plants)
Level 3:  400 - 899 XP   (4-8 plants)
Level 5:  900 - 1,599 XP
Level 10: 1,600 - 24,999 XP
Level 20: 25,000 - 99,999 XP
Level 50: 250,000+ XP
```

### 2.3 Level Titles (Displayed in Profile)

| Level Range | Title EN | Title KH |
|-------------|----------|----------|
| 1-2 | Seedling | កូនសំណាប |
| 3-5 | Plant Scout | អ្នករុករករុក្ខជាតិ |
| 6-10 | Botanist | អ្នករុក្ខសាស្ត្រ |
| 11-20 | Plant Master | ម្ចាស់រុក្ខជាតិ |
| 21-35 | Green Thumb | មេដៃបៃតង |
| 36-50 | Plant Legend | រឿងព្រេងរុក្ខជាតិ |

### 2.4 XP Required Per Level (Reference Table)

| Level | XP Required | Cumulative XP |
|-------|------------|---------------|
| 1 | 0 | 0 |
| 2 | 100 | 100 |
| 3 | 300 | 400 |
| 4 | 500 | 900 |
| 5 | 700 | 1,600 |
| 6 | 900 | 2,500 |
| 7 | 1,100 | 3,600 |
| 8 | 1,300 | 4,900 |
| 9 | 1,500 | 6,400 |
| 10 | 1,700 | 8,100 |
| 15 | 2,900 | 22,500 |
| 20 | 4,100 | 40,000 |
| 30 | 6,900 | 90,000 |
| 50 | 12,500 | 250,000 |

---

## 3. Achievement Definitions

### 3.1 Achievement Categories

| Category | Icon | Focus |
|----------|------|-------|
| **Collection** | 📚 | Unlocking total number of unique plants |
| **Rarity** | 💎 | Unlocking plants of specific rarity tiers |
| **Exploration** | 🔭 | Total scans (including duplicates) |
| **Streak** | 🔥 | Consecutive days of scanning |
| **Special** | 🎯 | Unique one-off challenges (hidden) |

### 3.2 Complete Achievement List

#### Collection Milestones

| ID | Name EN | Name KH | Requirement | XP Reward | Icon |
|----|---------|---------|-------------|-----------|------|
| `first_plant` | First Discovery | ការរកឃើញដំបូង | Unlock 1 plant | 50 | 🏅 |
| `collector_5` | Budding Collector | អ្នកប្រមូលថ្មីថ្មោង | Unlock 5 plants | 100 | 🌱 |
| `collector_10` | Plant Collector | អ្នកប្រមូលរុក្ខជាតិ | Unlock 10 plants | 150 | 🌿 |
| `collector_25` | Botanical Collector | អ្នកប្រមូលរុក្ខសាស្ត្រ | Unlock 25 plants | 250 | 🌳 |
| `collector_50` | Master Collector | ម្ចាស់ការប្រមូល | Unlock 50 plants | 500 | 🏆 |
| `collector_100` | Grand Collector | អ្នកប្រមូលដ៏អស្ចារ្យ | Unlock 100 plants | 1000 | 👑 |

#### Rarity Milestones

| ID | Name EN | Name KH | Requirement | XP Reward | Icon |
|----|---------|---------|-------------|-----------|------|
| `rare_1` | Rare Find | ការរកឃើញដ៏កម្រ | Unlock 1 Rare plant | 100 | 💠 |
| `rare_5` | Rare Hunter | អ្នកប្រមាញ់រុក្ខជាតិកម្រ | Unlock 5 Rare plants | 250 | 💎 |
| `rare_10` | Rare Collector | អ្នកប្រមូលរុក្ខជាតិកម្រ | Unlock 10 Rare plants | 500 | 🌟 |
| `special_1` | Special Discovery | ការរកឃើញពិសេស | Unlock 1 Special Rare plant | 300 | ✨ |
| `special_3` | Special Hunter | អ្នកប្រមាញ់រុក្ខជាតិពិសេស | Unlock 3 Special Rare plants | 750 | 💫 |
| `special_5` | Legendary Collector | អ្នកប្រមូលរឿងព្រេង | Unlock 5 Special Rare plants | 1500 | 🏆 |

#### Exploration (Total Scans)

| ID | Name EN | Name KH | Requirement | XP Reward | Icon |
|----|---------|---------|-------------|-----------|------|
| `scans_10` | Curious Observer | អ្នកសង្កេតការណ៍ចង់ដឹង | 10 total scans | 50 | 👀 |
| `scans_50` | Active Explorer | អ្នករុករកសកម្ម | 50 total scans | 150 | 🔍 |
| `scans_100` | Dedicated Naturalist | អ្នកធម្មជាតិវិទ្យាដែលខិតខំ | 100 total scans | 300 | 🔬 |
| `scans_500` | Field Researcher | អ្នកស្រាវជ្រាវវាល | 500 total scans | 750 | 🎓 |
| `scans_1000` | Plant Photographer | អ្នកថតរូបរុក្ខជាតិ | 1000 total scans | 1500 | 📸 |

#### Streaks (Daily Usage)

| ID | Name EN | Name KH | Requirement | XP Reward | Icon |
|----|---------|---------|-------------|-----------|------|
| `streak_3` | Getting Started | ការចាប់ផ្តើម | 3-day scan streak | 50 | 🔥 |
| `streak_7` | Weekly Explorer | អ្នករុករកប្រចាំសប្តាហ៍ | 7-day scan streak | 150 | 🔥 |
| `streak_14` | Fortnight Botanist | អ្នករុក្ខសាស្ត្រពីរសប្តាហ៍ | 14-day scan streak | 300 | 🔥🔥 |
| `streak_30` | Monthly Master | ម្ចាស់ប្រចាំខែ | 30-day scan streak | 750 | 🔥🔥🔥 |
| `streak_60` | Dedicated Discoverer | អ្នករកឃើញដែលខិតខំ | 60-day scan streak | 1500 | 💪 |
| `streak_100` | Unstoppable | មិនអាចបញ្ឈប់បាន | 100-day scan streak | 3000 | 🌋 |

#### Special (Hidden/One-Off)

| ID | Name EN | Name KH | Requirement | XP Reward | Icon | Hidden? |
|----|---------|---------|-------------|-----------|------|---------|
| `first_duplicate` | Familiar Face | មុខដែលធ្លាប់ស្គាល់ | Scan the same plant 5 times | 100 | 👋 | No |
| `all_three_rarities` | Trifecta | ត្រីភាគី | Unlock at least 1 Normal, 1 Rare, and 1 Special Rare | 200 | 🎪 | No |
| `ten_families` | Family Reunion | ការជួបជុំគ្រួសារ | Unlock plants from 10 different plant families | 300 | 👨‍👩‍👧 | No |
| `night_owl` | Night Owl | សត្វទីទុយពេលយប់ | Scan a plant between 12 AM - 4 AM | 50 | 🦉 | Yes |
| `around_the_world` | Around the World | ជុំវិញពិភពលោក | Unlock plants originating from 5 different continents | 500 | 🌍 | No |
| `khmer_treasure` | Khmer Treasure | កំណប់ខ្មែរ | Unlock 10 plants native to Cambodia/Southeast Asia | 300 | 🇰🇭 | No |
| `weekend_warrior` | Weekend Warrior | អ្នកចម្បាំងចុងសប្តាហ៍ | Scan 20 plants on a Saturday or Sunday | 200 | ⚔️ | Yes |

---

## 4. Achievement Evaluation Logic (Cloud Function)

```typescript
// In functions/src/achievements.ts

interface AchievementEvalResult {
  earned_achievements: {
    achievement_id: string;
    name: string;
    xp_reward: number;
  }[];
  total_bonus_xp: number;
}

async function evaluateAchievements(
  userId: string,
  scanResult: ScanResult
): Promise<AchievementEvalResult> {
  const earned: AchievementEvalResult = { earned_achievements: [], total_bonus_xp: 0 };
  
  // 1. Get user's current stats
  const userDoc = await db.collection('users').doc(userId).get();
  const userStats = userDoc.data();
  
  // 2. Get all achievement definitions
  const allAchievements = await db.collection('achievements').get();
  
  // 3. Get user's already-earned achievements
  const userAchievements = await db.collection('user_achievements')
    .where('user_id', '==', userId)
    .where('earned', '==', true)
    .get();
  const earnedIds = new Set(userAchievements.docs.map(d => d.data().achievement_id));
  
  // 4. Check each achievement
  for (const ach of allAchievements.docs) {
    const achData = ach.data();
    if (earnedIds.has(ach.id)) continue; // Already earned
    
    let progress = 0;
    let target = achData.requirement_value;
    let met = false;
    
    switch (achData.requirement_type) {
      case 'plants_unlocked':
        progress = userStats.plants_unlocked;
        met = progress >= target;
        break;
      case 'rarity_count':
        // Special handling: rarity_count_normal, rarity_count_rare, rarity_count_special_rare
        // Parsed from achievement ID or extra field
        progress = userStats[`${achData.rarity}_count`] || 0;
        met = progress >= target;
        break;
      case 'total_scans':
        progress = userStats.total_scans;
        met = progress >= target;
        break;
      case 'streak_days':
        progress = userStats.current_streak || 0;
        met = progress >= target;
        break;
      case 'special':
        // Complex logic per special achievement
        met = await evaluateSpecialAchievement(userId, ach.id);
        progress = met ? target : 0;
        break;
    }
    
    // Update progress tracking doc
    await db.collection('user_achievements').doc(`${userId}_${ach.id}`).set({
      user_id: userId,
      achievement_id: ach.id,
      earned: met,
      earned_at: met ? admin.firestore.Timestamp.now() : null,
      progress: progress,
      progress_target: target,
      xp_earned_at_unlock: met ? achData.xp_reward : 0,
      updated_at: admin.firestore.Timestamp.now(),
    }, { merge: true });
    
    if (met) {
      earned.earned_achievements.push({
        achievement_id: ach.id,
        name: achData.name_en, // Client will localize
        xp_reward: achData.xp_reward,
      });
      earned.total_bonus_xp += achData.xp_reward;
    }
  }
  
  return earned;
}

// Daily streak calculation (called by identifyPlant)
function updateStreak(userId: string): number {
  // Get last scan date
  // If yesterday → increment streak
  // If today → no change
  // If gap > 1 day → reset streak to 1
  // Update user doc with current_streak and longest_streak
}
```

---

## 5. XP Transaction Log

All XP changes are tracked in the `scans` collection for auditability. The `user.total_xp` is denormalized for fast reads but can be recalculated from scans if needed.

```typescript
// XP transaction recorded in each scan doc:
{
  "xp_earned": 100,                              // Base XP
  "achievement_ids_earned": ["first_plant"],     // Achievements triggered
  "total_xp_this_scan": 150                      // Base + achievement XP
}
```

---

## 6. Client-Side Achievement Display

### 6.1 Achievement Card States

| State | Visual | Behavior |
|-------|--------|----------|
| **Earned** | Full color, colored left border, checkmark, "Earned {date}" | Tap → show achievement detail (when/where/how) |
| **In Progress** | Partial color, blue left border, progress bar showing current/target | Tap → show progress detail |
| **Locked (visible)** | Gray, no progress, lock icon | Tap → show requirement hint |
| **Locked (hidden)** | Gray, "???" for name and description, "🔒" icon | Tap → "Keep exploring to unlock this secret achievement!" |

### 6.2 Earned Notification

When an achievement is earned (detected during `identifyPlant` response):
1. Toast/banner slides down from top: "🏆 Achievement Unlocked!" / "🏆 សមិទ្ធផលបានដោះសោ!"
2. Achievement name + icon displayed
3. "+{xp} XP" badge
4. Duration: 3s, then auto-dismiss
5. Stack multiple achievements if several earned at once (e.g., first plant + trifecta)
6. Added to profile achievements wall immediately

---

## 7. Admin Management of Rarity & Achievements

### 7.1 Setting Plant Rarity (Admin Portal)
- Dropdown selector: Normal / Rare / Special Rare
- Preview of card appearance at each rarity
- Bulk edit: select multiple plants → set rarity
- Warning if plant distribution drifts too far from target ratios (dashboard indicator)

### 7.2 Creating/Editing Achievements
- Full CRUD via admin portal
- Fields: ID, names (EN/KH), descriptions (EN/KH), requirement type, requirement value, XP reward, category, sort order, hidden flag
- Icon upload (SVG, 96x96dp recommended)
- Preview card showing how it looks to users (earned/in-progress/locked)
- Cannot delete achievements that have been earned by users (disable instead)

---

## 8. Future Expansion: Rarity Events

Post-MVP feature idea: Limited-time events where certain plants have boosted/enhanced rarity for a weekend, encouraging exploration.

Example: "Khmer New Year Event — All Cambodian native plants are Special Rare this weekend!"