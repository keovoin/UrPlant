# UrPlant — Database Schema (Firestore)

> **Version**: 1.0.0 · **Last Updated**: 2026-08-06
>
> Complete Firestore NoSQL schema: collections, document structures, indexes, security rules, and data access patterns.

---

## 1. Collection Overview

```
plants/                     ← Master plant catalog (admin-managed)
users/                      ← User profiles (auto-created on signup)
user_plants/                ← User's unlocked plants (junction)
user_achievements/          ← User's earned achievements (junction)
achievements/               ← Achievement definitions (admin-managed)
scans/                      ← All identification attempts (audit log)
unverified_plants/          ← AI-identified but not in plants/ yet
flagged_photos/             ← Photos flagged for admin review
```

---

## 2. Collection: `plants`

**Purpose**: Master catalog of all known plant species. Managed by admin via portal.

**Document ID**: Auto-generated Firestore ID (e.g., `abc123xyz`)

### Schema

```typescript
interface Plant {
  // --- Names (EN/KH bilingual) ---
  name_en: string;                    // Common name in English, e.g., "Aloe Vera"
  name_kh: string;                    // Common name in Khmer, e.g., "យក្ខព្រឹក្ស"
  scientific_name: string;            // e.g., "Aloe vera" (italicized in UI)
  
  // --- Taxonomy ---
  kingdom: string;                    // e.g., "Plantae"
  family: string;                     // e.g., "Asphodelaceae"
  genus: string;                      // e.g., "Aloe"
  species: string;                    // e.g., "vera"
  
  // --- Rarity ---
  rarity: 'normal' | 'rare' | 'special_rare';  // Assigned by admin
  // Note: Rarity is PRE-ASSIGNED per plant, not random per user unlock
  // This ensures a plant is always the same rarity for all users
  
  // --- Rich Content (EN) ---
  description_en: string;             // 2-3 paragraph description
  origin_en: string;                  // Native region/origin
  care_en: {                          // Care guide
    water: string;
    sunlight: string;
    soil: string;
    temperature: string;
    humidity: string;
  };
  fun_facts_en: string[];             // 3+ fun facts
  
  // --- Rich Content (KH) ---
  description_kh: string;
  origin_kh: string;
  care_kh: {
    water: string;
    sunlight: string;
    soil: string;
    temperature: string;
    humidity: string;
  };
  fun_facts_kh: string[];
  
  // --- Images ---
  image_urls: string[];               // Firebase Storage URLs (reference photos)
  thumbnail_url: string;              // Compressed thumbnail (200x200 WebP)
  
  // --- External References ---
  plant_id_external: number | null;   // Plant.id API species ID (for matching)
  
  // --- Metadata ---
  verified: boolean;                  // true = admin-approved, false = unverified
  created_by: string;                 // Admin UID who created this
  created_at: Timestamp;
  updated_at: Timestamp;
  
  // --- Stats (computed/denormalized) ---
  total_unlocks: number;              // How many users have unlocked this (updated by CF)
  search_keywords: string[];          // Denormalized: [name_en, name_kh, scientific_name] (lowercased, for search)
}

// Example document:
// plants/abc123
{
  "name_en": "Aloe Vera",
  "name_kh": "យក្ខព្រឹក្ស",
  "scientific_name": "Aloe vera",
  "kingdom": "Plantae",
  "family": "Asphodelaceae",
  "genus": "Aloe",
  "species": "vera",
  "rarity": "normal",
  "description_en": "Aloe vera is a succulent plant species...",
  "description_kh": "យក្ខព្រឹក្សគឺជារុក្ខជាតិទឹកដម...",
  "origin_en": "Arabian Peninsula",
  "origin_kh": "ឧបទ្វីបអារ៉ាប់",
  "care_en": {
    "water": "Low — water every 2-3 weeks",
    "sunlight": "Bright indirect light",
    "soil": "Well-draining cactus mix",
    "temperature": "13-27°C (55-80°F)",
    "humidity": "Low to moderate"
  },
  "care_kh": {
    "water": "ទាប — ស្រោចទឹករៀងរាល់ ២-៣ សប្តាហ៍",
    "sunlight": "ពន្លឺភ្លឺដោយប្រយោល",
    "soil": "ដីដាំដើមត្រសក់ដែលបង្ហូរទឹកបានល្អ",
    "temperature": "១៣-២៧°C",
    "humidity": "ទាបទៅមធ្យម"
  },
  "fun_facts_en": [
    "Aloe vera gel is 99% water",
    "It has been used medicinally for over 6,000 years",
    "Aloe can flower with tall yellow spikes when mature"
  ],
  "fun_facts_kh": [
    "ជែលយក្ខព្រឹក្សមានទឹក ៩៩%",
    "វាត្រូវបានប្រើជាឱសថអស់រយៈពេលជាង ៦០០០ ឆ្នាំ",
    "យក្ខព្រឹក្សអាចចេញផ្កាពណ៌លឿងនៅពេលពេញវ័យ"
  ],
  "image_urls": ["https://firebasestorage.../aloe_vera_1.webp"],
  "thumbnail_url": "https://firebasestorage.../aloe_vera_thumb.webp",
  "plant_id_external": 789012,
  "verified": true,
  "created_by": "admin_uid_xyz",
  "created_at": "2026-08-06T00:00:00Z",
  "updated_at": "2026-08-06T00:00:00Z",
  "total_unlocks": 42,
  "search_keywords": ["aloe vera", "យក្ខព្រឹក្ស", "aloe", "barbados aloe", "true aloe"]
}
```

### Indexes

| Index | Fields | Purpose |
|-------|--------|---------|
| `rarity_verified` | rarity (asc), verified (asc) | Filter encyclopedia by rarity |
| `name_en_asc` | name_en (asc) | A-Z sort English |
| `name_kh_asc` | name_kh (asc) | A-Z sort Khmer |
| `total_unlocks_desc` | total_unlocks (desc) | Popular plants |

### Query Patterns

```dart
// All verified plants
db.collection('plants').where('verified', isEqualTo: true)

// Filter by rarity
db.collection('plants')
  .where('verified', isEqualTo: true)
  .where('rarity', isEqualTo: 'rare')

// Search by keyword (array-contains)
db.collection('plants')
  .where('search_keywords', arrayContains: 'aloe')

// Sort A-Z English
db.collection('plants')
  .where('verified', isEqualTo: true)
  .orderBy('name_en')

// Most popular
db.collection('plants')
  .where('verified', isEqualTo: true)
  .orderBy('total_unlocks', descending: true)
  .limit(20)
```

---

## 3. Collection: `users`

**Purpose**: User profiles, stats, preferences.

**Document ID**: Firebase Auth UID (e.g., `user_abc123`)

### Schema

```typescript
interface User {
  // --- Profile ---
  display_name: string;
  email: string;
  photo_url: string | null;           // Avatar URL (Firebase Storage or Google)
  
  // --- Language ---
  language: 'en' | 'kh';              // Preferred language
  
  // --- Subscription (future) ---
  tier: 'free' | 'trial' | 'premium'; // default: 'free'
  trial_ends_at: Timestamp | null;
  daily_scans_limit: number;          // default: 5 (free), -1 (unlimited premium)
  daily_scans_used: number;           // reset daily by scheduled function
  
  // --- Stats (denormalized for fast reads) ---
  total_xp: number;                   // Accumulated experience points
  level: number;                      // Computed: floor(sqrt(total_xp / 100))
  total_scans: number;                // Total identification attempts
  plants_unlocked: number;            // Unique plants in collection
  normal_count: number;               // Normal rarity plants unlocked
  rare_count: number;                 // Rare rarity plants unlocked
  special_rare_count: number;         // Special Rare plants unlocked
  achievements_earned: number;        // Total achievements
  
  // --- Metadata ---
  created_at: Timestamp;
  last_active: Timestamp;
  deleted_at: Timestamp | null;       // Soft delete (GDPR)
}

// Example:
// users/user_abc123
{
  "display_name": "Rithy",
  "email": "rithy@example.com",
  "photo_url": null,
  "language": "kh",
  "tier": "free",
  "trial_ends_at": null,
  "daily_scans_limit": 5,
  "daily_scans_used": 3,
  "total_xp": 1250,
  "level": 3,
  "total_scans": 15,
  "plants_unlocked": 8,
  "normal_count": 5,
  "rare_count": 2,
  "special_rare_count": 1,
  "achievements_earned": 3,
  "created_at": "2026-08-01T00:00:00Z",
  "last_active": "2026-08-06T10:30:00Z",
  "deleted_at": null
}
```

### Security: Daily Scan Reset
A scheduled Cloud Function runs at midnight UTC to reset `daily_scans_used` to 0 for all users (or incrementally via on-read check).

---

## 4. Collection: `user_plants`

**Purpose**: Junction collection — which plants a user has unlocked, with rarity and user's photo.

**Document ID**: `{uid}_{plantId}` (e.g., `user_abc123_plant_xyz789`)

### Schema

```typescript
interface UserPlant {
  // --- References ---
  user_id: string;                    // Firebase Auth UID
  plant_id: string;                   // Firestore doc ID of plants/{plantId}
  
  // --- Unlock Data ---
  unlocked_at: Timestamp;             // When first identified
  rarity: 'normal' | 'rare' | 'special_rare';  // Rarity AT TIME OF UNLOCK
  
  // --- User's Photo ---
  photo_url: string;                  // Firebase Storage URL of user's capture
  thumbnail_url: string;              // Compressed thumbnail
  
  // --- Location (optional, user-granted) ---
  first_seen_location: GeoPoint | null;  // Lat/Lng of first unlock
  first_seen_city: string | null;        // Reverse-geocoded city
  
  // --- Stats ---
  sighting_count: number;             // How many times scanned (includes duplicates)
  last_seen_at: Timestamp;            // Last scan timestamp
  
  // --- Metadata ---
  created_at: Timestamp;
  updated_at: Timestamp;
}

// Example:
// user_plants/user_abc123_plant_xyz789
{
  "user_id": "user_abc123",
  "plant_id": "abc123",
  "unlocked_at": "2026-08-06T10:30:00Z",
  "rarity": "rare",
  "photo_url": "https://firebasestorage.../user_abc123/aloe_20260806.webp",
  "thumbnail_url": "https://firebasestorage.../user_abc123/aloe_20260806_thumb.webp",
  "first_seen_location": null,
  "first_seen_city": null,
  "sighting_count": 3,
  "last_seen_at": "2026-08-06T14:00:00Z",
  "created_at": "2026-08-06T10:30:00Z",
  "updated_at": "2026-08-06T14:00:00Z"
}
```

### Indexes

| Index | Fields | Purpose |
|-------|--------|---------|
| `user_rarity` | user_id (asc), rarity (asc) | Filter user's collection by rarity |
| `user_unlocked` | user_id (asc), unlocked_at (desc) | Recently unlocked (profile) |

### Query Patterns

```dart
// All user's unlocked plants
db.collection('user_plants')
  .where('user_id', isEqualTo: uid)

// User's rare plants
db.collection('user_plants')
  .where('user_id', isEqualTo: uid)
  .where('rarity', isEqualTo: 'rare')

// Check if user has specific plant
db.collection('user_plants')
  .doc('${uid}_${plantId}')
  .get()
```

---

## 5. Collection: `achievements`

**Purpose**: Achievement definitions. Managed by admin.

**Document ID**: Snake_case identifier (e.g., `first_plant`, `collector_10`)

### Schema

```typescript
interface Achievement {
  // --- Names ---
  name_en: string;                    // e.g., "First Discovery"
  name_kh: string;                    // e.g., "ការរកឃើញដំបូង"
  description_en: string;             // e.g., "Unlock your first plant"
  description_kh: string;             // e.g., "ដោះសោរុក្ខជាតិដំបូងរបស់អ្នក"
  
  // --- Visual ---
  icon_url: string;                   // Badge icon (Firebase Storage)
  
  // --- Requirements ---
  requirement_type: 'plants_unlocked' | 'rarity_count' | 'total_scans' 
    | 'streak_days' | 'special';      // What to track
  requirement_value: number;          // Threshold to earn (e.g., 10, 25, 50)
  
  // --- Rewards ---
  xp_reward: number;                  // XP awarded when earned
  
  // --- Display ---
  category: 'collection' | 'rarity' | 'exploration' | 'special';
  sort_order: number;                 // Display order on achievement wall
  
  // --- Metadata ---
  is_hidden: boolean;                  // Show requirement before earning?
  created_at: Timestamp;
}

// Example:
// achievements/first_plant
{
  "name_en": "First Discovery",
  "name_kh": "ការរកឃើញដំបូង",
  "description_en": "Unlock your first plant",
  "description_kh": "ដោះសោរុក្ខជាតិដំបូងរបស់អ្នក",
  "icon_url": "https://firebasestorage.../badges/first_plant.svg",
  "requirement_type": "plants_unlocked",
  "requirement_value": 1,
  "xp_reward": 50,
  "category": "collection",
  "sort_order": 1,
  "is_hidden": false,
  "created_at": "2026-08-06T00:00:00Z"
}
```

---

## 6. Collection: `user_achievements`

**Purpose**: Which achievements a user has earned + progress toward locked ones.

**Document ID**: `{uid}_{achievementId}`

### Schema

```typescript
interface UserAchievement {
  user_id: string;
  achievement_id: string;             // Ref to achievements/{id}
  
  earned: boolean;
  earned_at: Timestamp | null;
  progress: number;                   // Current progress toward requirement_value
  progress_target: number;            // Copied from achievement.requirement_value (denormalized)
  xp_earned_at_unlock: number;        // XP awarded
  
  updated_at: Timestamp;
}
```

---

## 7. Collection: `scans`

**Purpose**: Complete audit log of every identification attempt. Useful for analytics, anti-spoofing review, user stats recalculation.

**Document ID**: Auto-generated

### Schema

```typescript
interface Scan {
  user_id: string;
  photo_url: string;                  // Firebase Storage URL
  thumbnail_url: string;
  
  // --- PLant.id Result ---
  plant_id_external: number | null;   // Plant.id species ID
  plant_name: string | null;          // Top suggestion name
  confidence: number;                 // 0.0 - 1.0
  suggestions_json: string;           // Full Plant.id response (JSON string)
  
  // --- Match Result ---
  matched_plant_id: string | null;    // Firestore plants/{id} if matched
  is_new_unlock: boolean;             // Was this a first-time unlock?
  rarity_rolled: string | null;       // Rarity assigned (if new unlock)
  
  // --- Rewards ---
  xp_earned: number;
  achievement_ids_earned: string[];   // Achievements triggered by this scan
  
  // --- Anti-Spoofing ---
  exif_valid: boolean;                // Did EXIF pass validation?
  spoofing_flags: string[];           // Why flagged (if any), e.g., ["no_exif", "screenshot_resolution"]
  is_flagged: boolean;
  
  // --- Client Metadata ---
  device_model: string | null;
  app_version: string | null;
  
  // --- Timestamps ---
  created_at: Timestamp;
  
  // --- Location ---
  location: GeoPoint | null;
}
```

### Indexes

| Index | Fields | Purpose |
|-------|--------|---------|
| `user_created` | user_id (asc), created_at (desc) | User scan history |
| `flagged` | is_flagged (asc), created_at (desc) | Admin flagged review queue |
| `unmatched` | matched_plant_id (null), created_at (desc) | Unverified plants review |

---

## 8. Collection: `unverified_plants`

**Purpose**: Plants identified by AI but not yet in the `plants` catalog. Admin review queue.

**Document ID**: Auto-generated

### Schema

```typescript
interface UnverifiedPlant {
  plant_id_external: number;          // Plant.id species ID
  plant_name: string;                 // Top suggestion name
  scientific_name: string;
  suggestions_json: string;           // Full Plant.id response
  common_names: string[];             // All common names from Plant.id
  taxonomy_json: string;              // Taxonomy from Plant.id
  
  user_ids: string[];                 // Users who've found this (can accumulate)
  photo_urls: string[];               // Sample photos from users
  
  status: 'pending' | 'approved' | 'rejected';
  approved_plant_id: string | null;   // plants/{id} after approval
  
  reviewed_by: string | null;         // Admin UID
  reviewed_at: Timestamp | null;
  
  created_at: Timestamp;
  updated_at: Timestamp;
}
```

---

## 9. Collection: `flagged_photos`

**Purpose**: Photos flagged by anti-spoofing for manual review.

**Document ID**: Auto-generated

### Schema

```typescript
interface FlaggedPhoto {
  scan_id: string;                    // Ref to scans/{id}
  user_id: string;
  photo_url: string;
  
  flags: string[];                    // e.g., ["screenshot_detected", "low_resolution"]
  confidence: number;                  // Anti-spoofing confidence (0=definitely spoofed)
  
  status: 'pending' | 'cleared' | 'confirmed_spoof';
  reviewed_by: string | null;
  reviewed_at: Timestamp | null;
  
  created_at: Timestamp;
}
```

---

## 10. Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // ====================
    // HELPER FUNCTIONS
    // ====================
    function isAuthenticated() {
      return request.auth != null;
    }
    function isAdmin() {
      return request.auth.token.admin == true;
    }
    function isOwner(userId) {
      return request.auth.uid == userId;
    }

    // ====================
    // PLANTS (public read, admin write)
    // ====================
    match /plants/{plantId} {
      allow read: if true;  // Public — anyone can read plant catalog
      allow create, update, delete: if isAdmin();
    }

    // ====================
    // USERS (owner read/write, admin read)
    // ====================
    match /users/{userId} {
      allow read: if isOwner(userId) || isAdmin();
      allow create: if isOwner(userId);
      allow update: if isOwner(userId) || isAdmin();
      allow delete: if isOwner(userId);
    }

    // ====================
    // USER_PLANTS (owner read/write)
    // ====================
    match /user_plants/{docId} {
      allow read: if isAuthenticated() && 
        resource.data.user_id == request.auth.uid;
      allow create: if isAuthenticated() && 
        request.resource.data.user_id == request.auth.uid;
      allow update: if isAuthenticated() && 
        resource.data.user_id == request.auth.uid;
      allow delete: if false;  // Users cannot delete unlocks (only via account deletion)
    }

    // ====================
    // ACHIEVEMENTS (public read, admin write)
    // ====================
    match /achievements/{achievementId} {
      allow read: if true;
      allow write: if isAdmin();
    }

    // ====================
    // USER_ACHIEVEMENTS (owner read)
    // ====================
    match /user_achievements/{docId} {
      allow read: if isAuthenticated() && 
        resource.data.user_id == request.auth.uid;
      allow write: if false;  // Only Cloud Functions can write
    }

    // ====================
    // SCANS (owner read, function write)
    // ====================
    match /scans/{scanId} {
      allow read: if isAuthenticated() && 
        (resource.data.user_id == request.auth.uid || isAdmin());
      allow create: if isAuthenticated() && 
        request.resource.data.user_id == request.auth.uid;
      allow update: if isAdmin();
      allow delete: if false;
    }

    // ====================
    // UNVERIFIED_PLANTS (admin only)
    // ====================
    match /unverified_plants/{docId} {
      allow read, write: if isAdmin();
      allow create: if isAuthenticated();  // CF can create
    }

    // ====================
    // FLAGGED_PHOTOS (admin only)
    // ====================
    match /flagged_photos/{docId} {
      allow read, write: if isAdmin();
    }
  }
}
```

---

## 11. Firebase Storage Structure & Rules

### Storage Paths

```
/user_photos/{userId}/{scanId}.webp          ← User's plant captures
/user_photos/{userId}/{scanId}_thumb.webp    ← Thumbnails (200x200)
/plant_images/{plantId}.webp                 ← Admin-uploaded reference photos
/plant_images/{plantId}_thumb.webp           ← Thumbnails
/achievement_badges/{achievementId}.svg      ← Achievement badge icons
/user_avatars/{userId}.webp                  ← User profile avatars
```

### Storage Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // User photos: owner upload/read, admin read
    match /user_photos/{userId}/{fileName} {
      allow read: if request.auth != null && 
        (request.auth.uid == userId || request.auth.token.admin == true);
      allow create: if request.auth != null && 
        request.auth.uid == userId &&
        request.resource.size < 5 * 1024 * 1024 &&  // 5MB max
        request.resource.contentType.matches('image/webp');
      allow delete: if request.auth.uid == userId;
    }
    
    // Plant images: admin write, public read
    match /plant_images/{fileName} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // Achievement badges: admin write, public read
    match /achievement_badges/{fileName} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.token.admin == true;
    }
    
    // User avatars: owner upload, public read
    match /user_avatars/{fileName} {
      allow read: if true;
      allow create: if request.auth != null &&
        request.resource.size < 2 * 1024 * 1024;
    }
  }
}
```

---

## 12. Data Access Patterns Summary

| Use Case | Read/Write | Collection(s) | Pattern |
|----------|-----------|---------------|---------|
| Browse encyclopedia | Read | `plants` | Query verified, optional rarity filter, paginated |
| Search plants | Read | `plants` | Array-contains on `search_keywords` |
| View plant detail | Read | `plants` + `user_plants` | Get plant + check if user unlocked |
| User's collection | Read | `user_plants` | Query by user_id, join with plants |
| Identify plant | Write | `scans`, `user_plants`, `user_achievements`, `users`, `unverified_plants` | Transaction/batch write in Cloud Function |
| Update profile | Read/Write | `users` | Get/update own user doc |
| Achievement wall | Read | `achievements` + `user_achievements` | Left join: all achievements + user progress |
| Admin CRUD plant | Read/Write | `plants` | Direct doc operations |
| Admin review queue | Read/Write | `unverified_plants`, `flagged_photos` | Query by status |
| Daily scan reset | Write | `users` | Scheduled function: batch update daily_scans_used = 0 |

---

## 13. Migration & Seed Data Strategy

### Initial Seed
- Admin manually creates first 50-100 verified plants via admin portal
- Achievement definitions created via admin portal or Firestore console import
- No automated migration needed (greenfield project)

### Future Migrations
- Use Firestore `firebase admin` SDK scripts in `functions/scripts/`
- Add new fields: no migration needed (schema-less)
- Rename fields: read old, write new, deprecate old in Cloud Functions