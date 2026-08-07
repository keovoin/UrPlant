# UrPlant — Technology Stack

> **Version**: 1.0.0 · **Last Updated**: 2026-08-06
>
> This document specifies every technology, library, and service used in the UrPlant project, with version pins and rationale.

---

## 1. Technology Decisions Overview

```
Layer               │ Technology             │ Version/Plan
────────────────────┼────────────────────────┼─────────────────────────
Mobile App          │ Flutter                │ 3.24+ (stable)
Language            │ Dart                   │ 3.5+
Backend (Hosting)   │ Firebase Cloud Func    │ Node.js 20 LTS (TS 5.x)
Database            │ Firestore              │ NoSQL (native mode)
Storage             │ Firebase Storage       │ Standard tier
Auth                │ Firebase Auth          │ Email/Google/Apple
Admin Portal        │ React + Vite           │ React 18, Vite 5
Admin Styling       │ Tailwind CSS           │ 3.4+
AI (Identification) │ Self-Hosted VLM        │ Ollama + Qwen2-VL / LLaVA
AI (Fallback ID)    │ Plant.id API           │ v3 REST (production upgrade)
AI (Enrichment)     │ Self-Hosted AI Gateway │ DeepSeek/OpenAI-compatible endpoint
CI/CD               │ GitHub Actions         │ (or Firebase CI)
Monitoring          │ Firebase Crashlytics   │ Flutter + Functions
Analytics           │ Firebase Analytics     │ Flutter
```

---

## 2. Mobile App (Flutter)

### 2.1 Core Framework

| Component | Version | Purpose |
|-----------|---------|---------|
| **Flutter SDK** | ≥3.24.0 | Cross-platform mobile framework |
| **Dart** | ≥3.5.0 | Programming language |
| **Android min SDK** | 24 (Android 7.0) | Broad device coverage |
| **iOS min** | 15.0 | Covers 95%+ active devices |

### 2.2 Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  
  # Firebase
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.0
  cloud_firestore: ^5.4.0
  firebase_storage: ^12.3.0
  firebase_analytics: ^11.3.0
  firebase_crashlytics: ^4.1.0
  firebase_remote_config: ^5.1.0
  
  # Camera
  camera: ^0.11.0             # In-app camera control
  image_picker: ^1.1.0        # Used ONLY for camera source (gallery disabled in code)
  
  # State Management
  flutter_riverpod: ^2.5.0    # Riverpod for DI + state management
  
  # Networking
  dio: ^5.7.0                 # HTTP client for Cloud Functions calls
  connectivity_plus: ^6.0.0   # Network status detection
  
  # Localization
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0               # Internationalization (ARB support)
  
  # UI Components
  cached_network_image: ^3.4.0  # Offline image caching
  shimmer: ^3.0.0               # Loading skeleton effects
  confetti: ^0.8.0              # Celebration animations
  lottie: ^3.1.0                # Lottie animations (loading, celebrations)
  flutter_svg: ^2.0.0           # SVG icon support
  google_fonts: ^6.2.0          # Easy font management (Noto Sans Khmer)
  
  # Storage
  shared_preferences: ^2.3.0    # Local key-value storage
  hive_flutter: ^1.1.0          # Local DB for offline plant cache (if needed)
  
  # Utilities
  image: ^4.2.0                 # Image compression/resize before upload
  uuid: ^4.5.0                  # Generate unique IDs
  intl_phone_field: ^3.2.0      # Phone input (future)
  url_launcher: ^6.3.0          # Open external links
  
  # Permissions
  permission_handler: ^11.3.0   # Camera permissions

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^5.0.0
  mockito: ^5.4.0
  build_runner: ^2.4.0
  riverpod_generator: ^2.6.0
  json_serializable: ^6.8.0
```

### 2.3 Why Each Major Choice

| Library | Why |
|---------|-----|
| **Riverpod** | Type-safe, testable, no BuildContext dependency for DI. Better than Provider for complex state. |
| **camera (plugin)** | Official Flutter camera plugin — full control, tap-to-focus, flash. No gallery mode. |
| **Dio** | Multipart upload support for image upload to Cloud Functions. Interceptors for auth tokens. |
| **CachedNetworkImage** | Offline viewing of previously loaded plant images. Essential for spotty connectivity. |
| **Confetti + Lottie** | Unlock celebrations need to feel joyful. Confetti for Normal, Lottie for Rare/Special Rare. |
| **google_fonts** | Noto Sans Khmer bundled via google_fonts — ensures correct Khmer rendering on all devices. |

---

## 3. Backend (Firebase Cloud Functions)

### 3.1 Runtime & Language

| Component | Specification |
|-----------|---------------|
| **Runtime** | Node.js 20 (LTS) |
| **Language** | TypeScript 5.x |
| **Framework** | firebase-functions v6.x |
| **Package Manager** | npm (or yarn) |

### 3.2 Dependencies (functions/package.json)

```json
{
  "dependencies": {
    "firebase-functions": "^6.0.0",
    "firebase-admin": "^12.0.0",
    "axios": "^1.7.0",
    "sharp": "^0.33.0",
    "exifreader": "^4.0.0",
    "uuid": "^10.0.0",
    "zod": "^3.23.0",
    "express": "^4.21.0",
    "cors": "^2.8.0"
  },
  "devDependencies": {
    "typescript": "^5.6.0",
    "@types/node": "^20.0.0",
    "firebase-functions-test": "^3.0.0",
    "eslint": "^9.0.0"
  }
}
```

### 2.3 Library Rationale

| Library | Purpose |
|---------|---------|
| **sharp** | Server-side image resizing/WebP conversion before Storage upload |
| **exifreader** | Parse EXIF metadata from uploaded images for anti-spoofing |
| **axios** | HTTP calls to Plant.id API + self-hosted AI gateway |
| **zod** | Request validation schemas — prevents bad data from reaching Plant.id |
| **firebase-admin** | Server-side Firestore/Storage/Auth operations |

---

## 4. AI Services

### 4.1 AI Provider Architecture (Model-Agnostic)

The `identifyPlant` Cloud Function uses a **swappable AI provider pattern** — the same code works regardless of which AI identifies the plant. Switch via Firebase Remote Config, zero code changes.

```
identifyPlant Cloud Function
    │
    ├──→ AI Provider Interface: identifyPlantImage(imageBase64)
    │
    ├── 1️⃣ Self-Hosted VLM (Ollama + Qwen2-VL)  ← MVP / TESTING
    │       └── POST http://YOUR_SERVER:11434/api/generate
    │
    ├── 2️⃣ Self-Hosted via OpenAI-compatible vision gateway
    │       └── POST https://YOUR_GATEWAY/v1/chat/completions
    │
    └── 3️⃣ Plant.id API  ← PRODUCTION UPGRADE (when accuracy matters)
            └── POST https://api.plant.id/v3/identification
```

**Remote Config key**: `ai_provider` = `"self_hosted_vlm"` | `"openai_vision_gateway"` | `"plantid"`

**All three providers return a unified response**:
```typescript
interface AIIdentificationResult {
  species: string;              // Scientific name, e.g., "Aloe vera"
  common_names: string[];       // e.g., ["Aloe", "Barbados aloe"]
  confidence: number;           // 0.0 - 1.0 (normalized across providers)
  taxonomy: {
    kingdom: string;
    family: string;
    genus: string;
    species: string;
  };
  raw_response: string;         // JSON string of full provider response (audit)
  provider: string;             // Which AI was used
}
```

### 4.2 Self-Hosted VLM — Ollama + Qwen2-VL (Primary / MVP)

**This is the recommended AI for testing and MVP.** Runs on your existing self-hosted server. Zero per-call cost.

| Detail | Value |
|--------|-------|
| **Platform** | Ollama (local LLM/VLM runner) |
| **Model** | `qwen2-vl:7b` or `llava:13b` |
| **Setup** | `ollama pull qwen2-vl:7b` |
| **Endpoint** | `http://YOUR_SERVER_IP:11434/api/generate` |
| **Cost** | $0 (your hardware) |
| **Accuracy** | 50-75% on common plants; weaker on rare/look-alike species |
| **Latency** | 3-8s (depends on GPU) |
| **Caveat** | Generic VLMs are NOT trained specifically on plants — expect more "low confidence" results than Plant.id. Our app flow handles this gracefully with "Try again" and tips. |

#### Ollama Setup (on your AI server)
```bash
# Install Ollama (Linux/macOS)
curl -fsSL https://ollama.com/install.sh | sh

# Pull a vision model
ollama pull qwen2-vl:7b     # ~4.5GB, balanced accuracy/speed
# OR
ollama pull llava:13b        # ~7.4GB, slightly better

# Expose to your Cloud Function (if on same network)
# Default port: 11434
# For remote access, use nginx reverse proxy or SSH tunnel
```

#### Identification Prompt (sent to VLM)
```
You are a plant identification expert. Identify this plant from the photo.
Respond ONLY with valid JSON, no markdown, no explanation:

{
  "scientific_name": "Genus species",
  "common_names": ["common name 1", "common name 2"],
  "confidence": 0.0 to 1.0,
  "taxonomy": {
    "kingdom": "Plantae",
    "family": "Family name",
    "genus": "Genus",
    "species": "species"
  }
}

If you cannot identify the plant, set confidence to 0 and use "Unknown" for names.
```

#### Cloud Function Integration (`functions/src/utils/aiProvider.ts`)
```typescript
// AI Provider abstraction
import axios from 'axios';

interface IdentificationResult {
  species: string;
  common_names: string[];
  confidence: number;
  taxonomy: { kingdom: string; family: string; genus: string; species: string };
  raw_response: string;
  provider: string;
}

async function identifyWithOllama(imageBase64: string): Promise<IdentificationResult> {
  const response = await axios.post(`${OLLAMA_URL}/api/generate`, {
    model: 'qwen2-vl:7b',
    prompt: PLANT_IDENTIFICATION_PROMPT,
    images: [imageBase64],
    stream: false,
    format: 'json',
  }, { timeout: 30000 });

  const parsed = JSON.parse(response.data.response);
  
  return {
    species: parsed.scientific_name || 'Unknown',
    common_names: parsed.common_names || [],
    confidence: parsed.confidence || 0,
    taxonomy: parsed.taxonomy || {},
    raw_response: JSON.stringify(parsed),
    provider: 'ollama_qwen2_vl',
  };
}

// Master dispatcher — reads Remote Config to pick provider
export async function identifyPlantImage(imageBase64: string): Promise<IdentificationResult> {
  const provider = await getRemoteConfig('ai_provider'); // "self_hosted_vlm" | "plantid"

  switch (provider) {
    case 'plantid':
      return identifyWithPlantId(imageBase64);
    case 'self_hosted_vlm':
    default:
      return identifyWithOllama(imageBase64);
  }
}
```

### 4.3 Plant.id API (Future Production Upgrade)

Switching to Plant.id requires only changing the Remote Config flag — no code change.

| Detail | Value |
|--------|-------|
| **API** | Plant.id v3 REST API |
| **Endpoint** | `https://api.plant.id/v3/identification` |
| **Auth** | API Key in header `Api-Key: <key>` |
| **Pricing** | Free tier: ~10 credits/month. Startup: ~$25/mo (500 credits). Growth: ~$50/mo (2000 credits). |
| **Accuracy** | 80-95% species-level (purpose-trained) |
| **Why later** | Costs money per call. Self-hosted VLM is free for testing. Switch when your user base grows or accuracy becomes critical. |

### 4.4 Self-Hosted AI Gateway — DeepSeek/OpenAI (Enrichment + KH Translation)

**Separate from identification.** This is a text-only LLM for generating descriptions, care guides, fun facts, and Khmer translations.

| Detail | Value |
|--------|-------|
| **Interface** | OpenAI-compatible `/v1/chat/completions` endpoint |
| **Models** | DeepSeek-V3 or via your OpenAI gateway |
| **Endpoint** | Your self-hosted URL (Cloud Function env var `SELF_HOSTED_AI_URL`) |
| **Auth** | API Key header (env var `SELF_HOSTED_AI_KEY`) |

#### Enrichment Prompt Template
```
You are a botanist assistant. Given the following plant information, generate:
1. A 2-3 sentence description in English (engaging, educational)
2. Native origin/region (where this plant naturally grows)
3. Care guide with 5 fields: water needs, sunlight, soil type, temperature range, humidity preference
4. 3 fun facts (interesting, surprising)
5. All of the above translated into Khmer (ភាសាខ្មែរ)

Plant: {plant_name}
Taxonomy: {taxonomy}
Confidence: {confidence}

Respond in JSON format:
{
  "en": {
    "description": "...",
    "origin": "...",
    "care": { "water": "...", "sunlight": "...", "soil": "...", "temperature": "...", "humidity": "..." },
    "fun_facts": ["...", "...", "..."]
  },
  "kh": {
    "description": "...",
    "origin": "...",
    "care": { "water": "...", "sunlight": "...", "soil": "...", "temperature": "...", "humidity": "..." },
    "fun_facts": ["...", "...", "..."]
  }
}
```

---

## 5. Firebase Services

### 5.1 Service Matrix

| Service | Tier | Purpose |
|---------|------|---------|
| **Firebase Auth** | Spark (free) | User auth — Email/Password, Google, Apple, Anonymous (guest) |
| **Cloud Firestore** | Spark (free) | Primary database — plants, user data, achievements |
| **Firebase Storage** | Spark (free, 5GB) | Plant images, user photos |
| **Cloud Functions** | Blaze (pay-as-you-go) | Server-side logic (free tier: 2M invocations/month) |
| **Firebase Hosting** | Spark (free, 10GB) | Admin portal hosting |
| **Remote Config** | Spark (free) | Rarity odds, feature flags |
| **Crashlytics** | Spark (free) | Crash reporting |
| **Analytics** | Spark (free) | User behavior tracking |

### 5.2 Firestore Structure
Defined in detail in [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md).

Collection overview:
```
plants/                     ← Plant catalog
  {plantId}/
    name_en, name_kh, scientific_name, family, genus, species
    rarity: "normal"|"rare"|"special_rare"
    description_en, description_kh
    origin_en, origin_kh
    care_en, care_kh
    fun_facts_en[], fun_facts_kh[]
    image_urls[], verified: bool
    plant_id_external: number  ← Plant.id reference

users/                      ← User profiles
  {uid}/
    display_name, email, photo_url, language: "en"|"kh"
    total_xp, level, total_scans, plants_unlocked
    created_at, last_active

user_plants/                ← User's unlocked plants
  {uid}_{plantId}/
    plant_id (ref), unlocked_at, rarity, sighting_count
    photo_url (user's photo), first_seen_location

user_achievements/          ← User's earned achievements
  {uid}_{achievementId}/
    achievement_id (ref), earned_at, progress

achievements/               ← Achievement definitions
  {achievementId}/
    name_en, name_kh, description_en, description_kh
    icon_url, requirement_type, requirement_value
    xp_reward

unverified_plants/          ← AI-identified but not in DB
  {autoId}/
    plant_id_external, suggestions_json, user_id, photo_url
    status: "pending"|"approved"|"rejected"
    created_at

scans/                      ← All identification attempts
  {autoId}/
    user_id, photo_url, plant_id (nullable)
    confidence, result_json, is_new_unlock, xp_earned
    created_at
```

---

## 6. Admin Portal (React + Vite)

### 6.1 Stack

| Component | Version | Purpose |
|-----------|---------|---------|
| **React** | 18.x | UI framework |
| **Vite** | 5.x | Build tool + dev server |
| **TypeScript** | 5.x | Type safety |
| **Tailwind CSS** | 3.4+ | Utility-first styling |
| **React Router** | 6.x | Client-side routing |
| **Firebase Admin SDK** | (via Cloud Functions API) | Backend data access |
| **Zustand** | 4.x | Lightweight state management |
| **TanStack Query** | 5.x | Server state + caching |
| **React Hook Form** | 7.x | Form handling |
| **Zod** | 3.x | Form validation |
| **Recharts** | 2.x | Analytics charts |
| **Lucide React** | Latest | Icon library |

### 6.2 Dependencies (admin/package.json)

```json
{
  "dependencies": {
    "react": "^18.3.0",
    "react-dom": "^18.3.0",
    "react-router-dom": "^6.28.0",
    "firebase": "^10.14.0",
    "axios": "^1.7.0",
    "zustand": "^4.5.0",
    "@tanstack/react-query": "^5.60.0",
    "react-hook-form": "^7.53.0",
    "@hookform/resolvers": "^3.9.0",
    "zod": "^3.23.0",
    "recharts": "^2.13.0",
    "lucide-react": "^0.460.0",
    "react-hot-toast": "^2.4.0",
    "date-fns": "^4.1.0"
  },
  "devDependencies": {
    "@vitejs/plugin-react": "^4.3.0",
    "typescript": "^5.6.0",
    "vite": "^5.4.0",
    "tailwindcss": "^3.4.0",
    "postcss": "^8.4.0",
    "autoprefixer": "^10.4.0",
    "@types/react": "^18.3.0",
    "@types/react-dom": "^18.3.0"
  }
}
```

---

## 7. Development Tools & CI/CD

### 7.1 Local Development

| Tool | Purpose |
|------|---------|
| **VS Code** | Primary IDE |
| **Flutter extension** | Dart/Flutter tooling |
| **Firebase CLI** | `firebase emulators:start` for local backend |
| **Android Studio** | Android emulator |
| **Xcode** | iOS simulator (macOS only) |
| **Postman/Bruno** | API testing |

### 7.2 Version Control

| Detail | Value |
|--------|-------|
| **Platform** | GitHub |
| **Branching** | Trunk-based: `main` is always deployable. Feature branches: `feat/name`, `fix/name` |
| **PR Required** | Yes — at least 1 review before merge |
| **Conventional Commits** | `feat:`, `fix:`, `docs:`, `chore:`, `refactor:` |

### 7.3 CI/CD (GitHub Actions)

```yaml
# .github/workflows/ci.yml
name: CI
on: [push, pull_request]
jobs:
  flutter-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
      - run: cd mobile && flutter pub get && flutter test
  
  functions-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: cd functions && npm ci && npm test
  
  admin-build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: cd admin && npm ci && npm run build

  deploy-functions:
    if: github.ref == 'refs/heads/main'
    needs: [flutter-test, functions-test, admin-build]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: cd functions && npm ci
      - run: npx firebase deploy --only functions --token ${{ secrets.FIREBASE_TOKEN }}

  deploy-admin:
    if: github.ref == 'refs/heads/main'
    needs: [flutter-test, functions-test, admin-build]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: cd admin && npm ci && npm run build
      - run: npx firebase deploy --only hosting --token ${{ secrets.FIREBASE_TOKEN }}
```

---

## 8. Environment Variables & Secrets

### 8.1 Cloud Functions (.env)

```bash
# Self-Hosted VLM (Ollama — primary identification)
OLLAMA_URL=http://YOUR_SERVER_IP:11434
OLLAMA_MODEL=qwen2-vl:7b

# Self-Hosted AI Gateway (text enrichment + KH translation — separate from VLM)
SELF_HOSTED_AI_URL=https://your-ai-gateway.com/v1/chat/completions
SELF_HOSTED_AI_KEY=your_api_key
SELF_HOSTED_AI_MODEL=deepseek-chat

# Plant.id (future production upgrade — optional for MVP)
# PLANT_ID_API_KEY=your_plant_id_api_key
# PLANT_ID_API_URL=https://api.plant.id/v3

# Firebase (auto-configured via firebase-admin)
# GCLOUD_PROJECT=urplant-app

# Admin
ADMIN_ALLOWED_DOMAINS=yourdomain.com
```

### 8.2 Flutter App
No API keys stored client-side. All secrets live in Cloud Functions env vars. Firebase config is auto-generated via `flutterfire` CLI.

---

## 9. App Store Requirements Checklist

### Google Play
- [ ] Privacy policy URL
- [ ] Data safety section (camera, location optional)
- [ ] Target API level 34+
- [ ] App signing by Google Play

### Apple App Store
- [ ] Privacy nutrition labels
- [ ] Camera usage description (`NSCameraUsageDescription`) — "UrPlant needs camera access to identify plants in real time"
- [ ] Location usage description (`NSLocationWhenInUseUsageDescription`) — "Optionally tag where you found your plants"
- [ ] App Tracking Transparency (if Analytics used)
- [ ] Sign in with Apple (required if other social sign-ins offered)

---

## 10. Cost Estimate (Monthly at MVP Scale)

| Service | Tier | Est. Monthly Cost |
|---------|------|-------------------|
| Firebase Spark (Auth, Firestore, Storage, Hosting, Remote Config) | Free | $0 |
| Firebase Blaze (Cloud Functions) | Free tier (2M invocations) | $0 (likely free at MVP) |
| Self-Hosted VLM (Ollama — identification) | Your hardware | $0 (already owned) |
| Self-Hosted AI Gateway (enrichment + KH) | Your hardware | $0 (already owned) |
| Apple Developer Program | Annual | $99/yr ≈ $8.25/mo |
| Google Play Console | One-time | $25 (one-time) |
| Domain (optional) | Annual | ~$12/yr ≈ $1/mo |
| **Total (MVP)** | | **~$9.25/mo** |
| Plant.id API (optional upgrade, ~$25/mo) | When accuracy matters | +$0-25 (future) |
