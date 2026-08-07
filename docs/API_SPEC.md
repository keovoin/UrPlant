# UrPlant — API Specification

> **Version**: 1.0.0 · **Last Updated**: 2026-08-06
>
> Complete API specification for all Cloud Functions endpoints, external AI integrations, request/response schemas, and error handling.

---

## 1. Cloud Functions Endpoints

All endpoints are callable Cloud Functions (HTTP triggers) hosted at:
- Production: `https://{REGION}-{PROJECT_ID}.cloudfunctions.net/{functionName}`
- Local (emulator): `http://127.0.0.1:5001/{PROJECT_ID}/{REGION}/{functionName}`

### 1.1 Authentication
All authenticated endpoints require a Firebase ID Token in the `Authorization` header:
```
Authorization: Bearer <firebase_id_token>
```
Cloud Functions validate this token automatically via `firebase-admin` auth. Guest (anonymous) users use the anonymous Firebase Auth token.

---

## 2. Function: `identifyPlant`

**Purpose**: The core endpoint — accept a plant photo, identify via Plant.id, check against DB, handle unlock logic.

**Trigger**: HTTP POST (multipart/form-data)

**Endpoint**: `POST /identifyPlant`

### Request

| Field | Type | Required | Description |
|-------|------|----------|-------------|
| `image` | File (multipart) | Yes | JPEG/WebP image, max 4MB |
| `exif_data` | JSON string | Yes | EXIF metadata extracted client-side |
| `location` | JSON string | No | `{ "lat": 11.5564, "lng": 104.9282 }` (optional, user-granted) |
| `device_model` | string | No | e.g., "iPhone 15 Pro" |
| `app_version` | string | No | e.g., "1.0.0" |

### EXIF Data Format (client-side extraction)
```json
{
  "make": "Apple",
  "model": "iPhone 15 Pro",
  "software": "17.1",
  "date_time_original": "2026:08:06 10:30:00",
  "image_width": 4032,
  "image_height": 3024,
  "has_exif": true,
  "source_type": "camera"
}
```

### AI Provider Architecture (Model-Agnostic)

The `identifyPlant` function is **provider-agnostic**. It calls a unified `identifyPlantImage()` dispatcher that routes to whichever AI is configured via Firebase Remote Config.

```
identifyPlantImage(imageBuffer)
    │
    ├── Remote Config: ai_provider = "self_hosted_vlm"
    │   └──→ POST http://YOUR_SERVER:11434/api/generate  (Ollama + Qwen2-VL)
    │
    ├── Remote Config: ai_provider = "plantid"
    │   └──→ POST https://api.plant.id/v3/identification
    │
    └── All return unified: { species, common_names, confidence, taxonomy, provider }
```

### Processing Flow (Server-Side)
```
1. Validate request (Zod schema)
2. Check daily scan limit (free tier: 5/day)
3. Anti-spoofing check (EXIF validation) → if flagged, still proceed but mark scan
4. Compress image to WebP (sharp)
5. Upload to Firebase Storage: /user_photos/{uid}/{scanId}.webp
6. Convert image to base64 for AI processing
7. Call identifyPlantImage(imageBase64) — dispatches to configured AI provider:
   a. Self-Hosted VLM (default): POST to Ollama with Qwen2-VL
   b. Plant.id API (production): POST to plant.id/v3
8. Parse unified response → species, confidence, taxonomy, common_names
9. If confidence < 0.6: return error response (no unlock)
10. If confidence >= 0.6:
   a. Search Firestore `plants` by scientific_name (case-insensitive)
   b. If MATCH found:
      - Check user_plants: has user unlocked this?
      - NEW UNLOCK: create user_plant doc with rarity from plant.rarity, award 100 XP
      - DUPLICATE: update sighting_count, award 50 XP
   c. If NO MATCH:
      - Check/create unverified_plants entry
      - Return "unmatched" response (plant waits admin review)
11. Update user stats (total_xp, total_scans, etc.)
12. Evaluate achievements (if thresholds crossed)
13. Create scan audit log doc (including provider name + raw_response)
14. Fire async `enrichInfo` function (if new plant or missing enrichment)
15. Return response
```

### Success Response (200)

```typescript
interface IdentifyPlantResponse {
  success: true;
  
  // --- Plant Data ---
  plant: {
    id: string;                       // Firestore plant ID
    name_en: string;
    name_kh: string;
    scientific_name: string;
    family: string;
    genus: string;
    species: string;
    rarity: 'normal' | 'rare' | 'special_rare';
    
    // Content (in user's preferred language + fallback)
    description: string;              // Localized to user's language
    origin: string;
    care: {
      water: string;
      sunlight: string;
      soil: string;
      temperature: string;
      humidity: string;
    };
    fun_facts: string[];
    
    image_url: string;                // Plant reference image
    thumbnail_url: string;
  } | null;                           // null if unmatched or enrichment pending
  
  // --- Unlock Status ---
  is_new_unlock: boolean;
  is_duplicate: boolean;
  
  // --- User's Photo ---
  user_photo_url: string;             // The photo user just took (Storage URL)
  
  // --- Rewards ---
  xp_earned: number;
  achievements_earned: {
    id: string;
    name: string;                     // Localized
    icon_url: string;
    xp_reward: number;
  }[];
  
  // --- Stats ---
  user_stats: {
    total_xp: number;
    level: number;
    total_scans: number;
    plants_unlocked: number;
  };
  
  // --- Match Info ---
  confidence: number;                 // 0.0-1.0
  match_status: 'matched' | 'unmatched' | 'low_confidence';
  
  // --- Flags ---
  is_flagged: boolean;                // Anti-spoofing flagged
}

// Example: New unlock (Aloe Vera, Rare)
{
  "success": true,
  "plant": {
    "id": "abc123",
    "name_en": "Aloe Vera",
    "name_kh": "យក្ខព្រឹក្ស",
    "scientific_name": "Aloe vera",
    "family": "Asphodelaceae",
    "genus": "Aloe",
    "species": "vera",
    "rarity": "rare",
    "description": "Aloe vera is a succulent plant species...",
    "origin": "Arabian Peninsula",
    "care": {
      "water": "Low — water every 2-3 weeks",
      "sunlight": "Bright indirect light",
      "soil": "Well-draining cactus mix",
      "temperature": "13-27°C (55-80°F)",
      "humidity": "Low to moderate"
    },
    "fun_facts": ["Aloe vera gel is 99% water", "..."],
    "image_url": "https://storage.../plant_images/abc123.webp",
    "thumbnail_url": "https://storage.../plant_images/abc123_thumb.webp"
  },
  "is_new_unlock": true,
  "is_duplicate": false,
  "user_photo_url": "https://storage.../user_photos/uid/scan_123.webp",
  "xp_earned": 100,
  "achievements_earned": [
    {
      "id": "first_plant",
      "name": "First Discovery",
      "icon_url": "https://storage.../badges/first_plant.svg",
      "xp_reward": 50
    }
  ],
  "user_stats": {
    "total_xp": 150,
    "level": 1,
    "total_scans": 1,
    "plants_unlocked": 1
  },
  "confidence": 0.95,
  "match_status": "matched",
  "is_flagged": false
}
```

### Error Responses

#### Low Confidence (422)
```json
{
  "success": false,
  "error": "low_confidence",
  "message_en": "Couldn't identify this plant clearly. Try a closer, well-lit photo.",
  "message_kh": "មិនអាចកំណត់អត្តសញ្ញាណរុក្ខជាតិនេះបានច្បាស់ទេ។ សូមសាកល្បងថតរូបឱ្យជិត និងមានពន្លឺគ្រប់គ្រាន់។",
  "confidence": 0.42,
  "suggestions": ["Try better lighting", "Focus on leaves/flowers", "Avoid blur"]
}
```

#### Unmatched (200)
```json
{
  "success": true,
  "plant": null,
  "is_new_unlock": false,
  "is_duplicate": false,
  "user_photo_url": "https://storage.../user_photos/uid/scan_456.webp",
  "xp_earned": 10,
  "achievements_earned": [],
  "user_stats": { ... },
  "confidence": 0.78,
  "match_status": "unmatched",
  "message_en": "Plant identified but not yet in our database. Our team will review it soon!",
  "message_kh": "រុក្ខជាតិត្រូវបានកំណត់អត្តសញ្ញាណ ប៉ុន្តែមិនទាន់មានក្នុងមូលដ្ឋានទិន្នន័យរបស់យើងទេ។ ក្រុមការងាររបស់យើងនឹងពិនិត្យឡើងវិញក្នុងពេលឆាប់ៗនេះ!",
  "is_flagged": false
}
```

#### Daily Limit Reached (429)
```json
{
  "success": false,
  "error": "daily_limit_reached",
  "message_en": "You've reached your daily scan limit (5/5). Upgrade to Premium for unlimited scans.",
  "message_kh": "អ្នកបានឈានដល់ដែនកំណត់ស្កេនប្រចាំថ្ងៃ (៥/៥)។ ដំឡើងទៅ Premium សម្រាប់ការស្កេនគ្មានដែនកំណត់។",
  "scans_used": 5,
  "scans_limit": 5
}
```

#### Auth Error (401)
```json
{
  "success": false,
  "error": "unauthenticated",
  "message_en": "Please log in to scan plants."
}
```

---

## 3. Function: `enrichInfo` (Async/Fire-and-Forget)

**Purpose**: Called asynchronously from `identifyPlant` — enriches plant data via self-hosted AI and translates to Khmer. Updates Firestore when complete.

**Trigger**: Pub/Sub or direct HTTP (called internally)

**Endpoint**: `POST /enrichInfo` (or PubSub)

### Request
```json
{
  "plant_id": "abc123",               // Firestore plant doc ID
  "plant_name": "Aloe vera",
  "scientific_name": "Aloe vera",
  "taxonomy": {
    "kingdom": "Plantae",
    "family": "Asphodelaceae",
    "genus": "Aloe",
    "species": "vera"
  },
  "confidence": 0.95
}
```

### Processing
```
1. Build enrichment prompt (see TECH_STACK.md Section 4.2)
2. Call self-hosted AI gateway (OpenAI-compatible endpoint)
3. Parse JSON response (validate with Zod)
4. Update Firestore plant doc with en/kh fields
5. Update search_keywords array
```

### Enrichment Response (Added to Firestore plant doc)
```json
{
  "description_en": "Aloe vera is a succulent plant species...",
  "description_kh": "យក្ខព្រឹក្សគឺជារុក្ខជាតិទឹកដម...",
  "origin_en": "Arabian Peninsula",
  "origin_kh": "ឧបទ្វីបអារ៉ាប់",
  "care_en": { "water": "...", "sunlight": "...", ... },
  "care_kh": { "water": "...", "sunlight": "...", ... },
  "fun_facts_en": ["Fact 1", "Fact 2", "Fact 3"],
  "fun_facts_kh": ["ការពិត ១", "ការពិត ២", "ការពិត ៣"]
}
```

---

## 4. Admin API (`adminApi`)

**Purpose**: All admin operations behind a single Express-based Cloud Function with custom auth claim check.

**Endpoint**: `POST /adminApi`

**Auth**: Bearer token + user must have `admin: true` custom claim.

### Request Wrapper
```typescript
interface AdminApiRequest {
  action: string;                     // Operation name (see below)
  payload: Record<string, any>;       // Action-specific payload
}
```

### Actions

#### 4.1 `createPlant`
```typescript
payload: {
  name_en: string;
  name_kh: string;
  scientific_name: string;
  kingdom?: string;
  family?: string;
  genus?: string;
  species?: string;
  rarity: 'normal' | 'rare' | 'special_rare';
  description_en?: string;
  description_kh?: string;
  origin_en?: string;
  origin_kh?: string;
  care_en?: CareGuide;
  care_kh?: CareGuide;
  fun_facts_en?: string[];
  fun_facts_kh?: string[];
  plant_id_external?: number;
  verified: boolean;
}
response: { success: true, plant_id: string }
```

#### 4.2 `updatePlant`
```typescript
payload: {
  plant_id: string;
  // ... same fields as createPlant (partial)
}
response: { success: true }
```

#### 4.3 `deletePlant`
```typescript
payload: { plant_id: string }
response: { success: true }
```

#### 4.4 `listUsers`
```typescript
payload: {
  page_size?: number;                 // default: 20
  page_token?: string;                // cursor for pagination
  search?: string;                    // search by email or display_name
}
response: {
  users: User[];
  next_page_token: string | null;
  total_count: number;
}
```

#### 4.5 `getUserDetail`
```typescript
payload: { user_id: string }
response: { user: User, plants: UserPlant[], achievements: UserAchievement[] }
```

#### 4.6 `banUser`
```typescript
payload: { user_id: string, reason: string }
response: { success: true }
```

#### 4.7 `reviewUnverified`
```typescript
payload: {
  unverified_id: string;
  action: 'approve' | 'reject';
  // If approve:
  plant_data?: Partial<Plant>;        // Optional: override plant data
}
response: { success: true, plant_id?: string }
```

#### 4.8 `reviewFlaggedPhoto`
```typescript
payload: {
  flagged_id: string;
  action: 'clear' | 'confirm_spoof';
}
response: { success: true }
```

#### 4.9 `getAnalytics`
```typescript
payload: {
  metric: 'total_users' | 'total_scans' | 'total_unlocks' | 'popular_plants' | 'daily_active';
  period: '7d' | '30d' | '90d' | 'all';
}
response: {
  metric: string;
  value: number | AnalyticsDataPoint[];
}
```

#### 4.10 `createAchievement` / `updateAchievement`
```typescript
payload: {
  achievement_id?: string;           // For update
  name_en: string;
  name_kh: string;
  description_en: string;
  description_kh: string;
  icon_url?: string;
  requirement_type: string;
  requirement_value: number;
  xp_reward: number;
  category: string;
  sort_order: number;
}
response: { success: true, achievement_id: string }
```

---

## 5. Mobile Client API (Public Read APIs)

These are direct Firestore reads (no Cloud Function needed) via `cloud_firestore` SDK.

### 5.1 Get Encyclopedia (Paginated)
```dart
// Direct Firestore query
FirebaseFirestore.instance
  .collection('plants')
  .where('verified', isEqualTo: true)
  .orderBy('name_en')
  .limit(20)
  .get();
```

### 5.2 Get Plant Detail
```dart
// Direct Firestore get
FirebaseFirestore.instance.collection('plants').doc(plantId).get();
// + check user_plants for unlock status
FirebaseFirestore.instance.collection('user_plants').doc('${uid}_${plantId}').get();
```

### 5.3 Get User's Collection
```dart
FirebaseFirestore.instance
  .collection('user_plants')
  .where('user_id', isEqualTo: uid)
  .get();
```

### 5.4 Get Achievement Wall
```dart
// All achievements + user progress
// Can be done via caching: fetch all achievements, then user_achievements, join client-side
```

---

## 6. Scheduled Cloud Functions

### 6.1 `resetDailyScans`
**Schedule**: Every day at 00:00 UTC
```typescript
// Bulk update all users: daily_scans_used = 0
// Or: use on-read check (if last_active != today, reset)
// Better approach: store last_scan_date, compare on each scan
```

### 6.2 `cleanupUnverifiedPlants`
**Schedule**: Every week on Sunday
**Action**: Delete unverified plants with 0 user submissions older than 30 days.

---

## 7. Anti-Spoofing Implementation

### Client-Side
```dart
// Extract EXIF from captured image
// Use the 'image' package to read EXIF metadata
// Send 'has_exif', 'make', 'model', 'software', 'image_width', 'image_height'

// NO gallery picker in UI at all — camera only
// The camera controller is opened directly, never with ImageSource.gallery
```

### Server-Side Heuristics
```typescript
// In antiSpoofing.ts
function validateImage(imageBuffer: Buffer, exifData: ExifData): SpoofingResult {
  const flags: string[] = [];
  
  // 1. EXIF must exist (real camera photos have EXIF)
  if (!exifData.has_exif) {
    flags.push('no_exif');
  }
  
  // 2. Source must be "camera" (not screenshot or downloaded)
  if (exifData.source_type !== 'camera') {
    flags.push('non_camera_source');
  }
  
  // 3. Resolution must be modern smartphone resolution (min 8MP equivalent)
  const megapixels = (exifData.image_width * exifData.image_height) / 1_000_000;
  if (megapixels < 2) {
    flags.push('low_resolution');
  }
  
  // 4. Image dimensions shouldn't match common screen resolutions
  const screenResolutions = [
    { w: 1170, h: 2532 },  // iPhone screen
    { w: 1080, h: 2400 },  // Android screen
    { w: 750, h: 1334 },   // iPhone SE screen
    { w: 1284, h: 2778 },  // iPhone 12 Pro Max screen
  ];
  const matchesScreen = screenResolutions.some(
    r => Math.abs(r.w - exifData.image_width) < 5 && 
         Math.abs(r.h - exifData.image_height) < 5
  );
  if (matchesScreen) {
    flags.push('screenshot_resolution');
  }
  
  // 5. Software string shouldn't indicate screenshot
  if (exifData.software && 
      /screenshot|photoshop|preview/i.test(exifData.software)) {
    flags.push('suspicious_software');
  }
  
  const isFlagged = flags.length >= 2; // At least 2 red flags to flag
  return { isFlagged, flags, confidence: isFlagged ? 0.3 : 0.95 };
}
```

**Note**: Anti-spoofing is a best-effort system. Even if flagged, the scan still proceeds but is marked for admin review. This prevents false positives from blocking legitimate users (e.g., some Android devices may strip EXIF). Admin can clear false flags.

---

## 8. Error Codes Reference

| HTTP Status | Error Code | Description |
|-------------|-----------|-------------|
| 200 | (success) | Normal response |
| 200 | unmatched | Plant not in database |
| 400 | invalid_request | Missing/wrong parameters |
| 401 | unauthenticated | No valid auth token |
| 403 | forbidden | User doesn't have permission (e.g., non-admin trying admin action) |
| 422 | low_confidence | Plant.id confidence below threshold |
| 429 | daily_limit_reached | Free tier daily scan cap |
| 429 | rate_limited | Too many requests (general) |
| 500 | internal_error | Unexpected server error |
| 503 | plantid_unavailable | Plant.id API is down |

---

## 9. Performance Targets

| Operation | Target (P90) | Notes |
|-----------|-------------|-------|
| `identifyPlant` (end-to-end, self-hosted VLM) | <10s | Includes VLM processing (3-8s on GPU) + DB writes |
| `identifyPlant` (end-to-end, Plant.id API) | <8s | Network + Plant.id processing |
| Self-Hosted VLM call (Ollama) | 3-8s | Depends on GPU; 7B model ~4-6s on mid-range GPU |
| Image upload + compression | <2s | 4MB → WebP ~500KB |
| `enrichInfo` (async) | <10s | Self-hosted AI text response |
| Admin CRUD operations | <500ms | Direct Firestore |
| Encyclopedia query (20 items) | <1s | Firestore query |

---

## 10. Versioning & Deprecation

- API version in URL: `/v1/identifyPlant` (post-MVP; MVP uses no version prefix)
- Cloud Functions support multiple versions deployed simultaneously
- Deprecation: 3-month notice before removing old version
- Breaking changes require new version number