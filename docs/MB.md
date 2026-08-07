 a# UrPlant — Memory Bank Master Index

> **Status**: Pre-MVP · **Last Updated**: 2026-08-06 · **Phase**: 0 (Documentation)
>
> This Memory Bank (MB) is the single source of truth for the entire UrPlant project. Every AI coding assistant (Cline, Copilot, etc.) should read this file first, then drill into referenced docs.

---

## 1. Project Summary

**UrPlant** is a mobile plant-recognition app (Android + iOS) that uses AI + the device camera to identify real-world plants captured in-app. Users unlock plants into their personal encyclopedia, earn rarity-based achievements, and explore rich plant knowledge in both English (EN) and Khmer (KH). An admin portal allows content managers to curate the plant database and monitor usage.

### Core Pillars
| Pillar | Description |
|--------|-------------|
| **In-App Camera Only** | Photos must be taken live through the app. No gallery upload, no internet images, no digital screenshots. Server-side anti-spoofing validation. |
| **AI Identification** | Plant.id API (species-level identification) + self-hosted AI (DeepSeek/OpenAI gateway) for knowledge enrichment + KH translation. |
| **Rarity + Achievements** | Normal (70%), Rare (25%), Special Rare (5%). Unlocking a plant the FIRST time counts; duplicates add XP. Celebrations: confetti, badge reveal, haptic feedback. |
| **EN/KH Bilingual** | Full localization — UI, plant names, descriptions, care tips. Noto Sans Khmer for KH text. |
| **Admin Portal** | Web dashboard — CRUD plants, assign rarity, manage achievements, review flagged photos, view user analytics. |
| **Subscription-Ready** | Data model supports free/trial/subscription tiers; payment integration deferred to post-MVP. |

---

## 2. Document Map

| # | Document | Purpose | Status |
|---|----------|---------|--------|
| 1 | [PRD.md](./PRD.md) | Full product requirements, user stories, feature list | ✅ |
| 2 | [TECH_STACK.md](./TECH_STACK.md) | Chosen technologies, versions, rationale | ✅ |
| 3 | [DATABASE_SCHEMA.md](./DATABASE_SCHEMA.md) | Firestore collections, models, indexes, security rules | ✅ |
| 4 | [API_SPEC.md](./API_SPEC.md) | Cloud Functions endpoints, Plant.id integration, AI enrichment | ✅ |
| 5 | [UX_SPEC.md](./UX_SPEC.md) | Screen-by-screen UX/UI spec, animations, flows | ✅ |
| 6 | [RARITY_ACHIEVEMENTS.md](./RARITY_ACHIEVEMENTS.md) | Rarity probability pools, XP system, achievement definitions | ✅ |
| 7 | [LOCALIZATION.md](./LOCALIZATION.md) | EN/KH strategy, ARB files, font setup | ✅ |
| 8 | [ADMIN_PORTAL.md](./ADMIN_PORTAL.md) | Admin web app spec (React + Vite + Tailwind) | ✅ |
| 9 | [SETUP_GUIDE.md](./SETUP_GUIDE.md) | Step-by-step from zero to running app | ✅ |

---

## 3. High-Level Architecture

```
┌──────────────────────────────────────────────────────────┐
│                    MOBILE APP (Flutter)                    │
│  ┌──────────┐ ┌───────────┐ ┌───────────┐ ┌────────────┐ │
│  │ Auth UI  │ │ Camera UI │ │Encyclopedia│ │ Profile    │ │
│  │ (Firebase│ │(camera _  │ │ (unlocked  │ │(stats,     │ │
│  │  Auth)   │ │ plugin)   │ │ + locked)  │ │achievements│ │
│  └──────────┘ └─────┬─────┘ └───────────┘ └────────────┘ │
│                     │ capture + metadata                   │
└─────────────────────┼────────────────────────────────────┘
                      │ HTTPS (multipart)
                      ▼
┌──────────────────────────────────────────────────────────┐
│         CLOUD FUNCTIONS — Firebase Hosting (Node.js/TS)    │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐ │
│  │ identifyPlant│  │ enrichInfo   │  │ adminApi        │ │
│  │ → AiProvider │  │ → Self-hosted│  │ → Firestore CRUD│ │
│  │ → anti-spoof │  │   AI gateway  │  │ → User mgmt     │ │
│  │ → rarity     │  │ → KH translate│  │ → Analytics     │ │
│  └──────┬───────┘  └──────────────┘  └─────────────────┘ │
│         │ Remote Config: ai_provider                      │
│         ▼                                                 │
│  ┌──────────────────────────────────────────────────┐    │
│  │         AI Provider Abstraction Layer              │    │
│  │  1️⃣ Self-Hosted VLM (Ollama + Qwen2-VL) ← MVP    │    │
│  │  2️⃣ Plant.id API ← Production upgrade             │    │
│  │  3️⃣ OpenAI-compatible vision gateway               │    │
│  └──────────────────────────────────────────────────┘    │
└─────────────────────┬────────────────────────────────────┘
                      │
                      ▼
┌──────────────────────────────────────────────────────────┐
│              FIREBASE SERVICES                             │
│  ┌─────────┐ ┌───────────┐ ┌──────────┐ ┌────────────┐  │
│  │  Auth   │ │ Firestore │ │ Storage  │ │Remote Config│  │
│  │(Email/  │ │(plants,   │ │(images)  │ │(ai_provider,│  │
│  │Google/  │ │users,     │ │          │ │rarity odds) │  │
│  │Apple)   │ │achievements│ │         │ │            │  │
│  └─────────┘ └───────────┘ └──────────┘ └────────────┘  │
└──────────────────────────────────────────────────────────┘
                      │
                      ▼
┌──────────────────────────────────────────────────────────┐
│              EXTERNAL / SELF-HOSTED AI                     │
│  ┌──────────────────┐  ┌──────────────────────────────┐  │
│  │ Self-Hosted VLM   │  │ Self-Hosted AI Gateway       │  │
│  │ Ollama + Qwen2-VL │  │ DeepSeek/OpenAI-compatible   │  │
│  │ (identification)  │  │ (enrichment + KH translation)│  │
│  │ Cost: $0          │  │ Cost: $0                     │  │
│  └──────────────────┘  └──────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────┐
│              ADMIN PORTAL (React + Vite + Tailwind)       │
│  ┌────────────┐ ┌────────────┐ ┌────────────────────┐    │
│  │ Plant CRUD │ │ User Mgmt  │ │ Analytics Dashboard │    │
│  └────────────┘ └────────────┘ └────────────────────┘    │
│  Deployed to Firebase Hosting                             │
└──────────────────────────────────────────────────────────┘
```

---

## 4. Data Flow: Plant Identification

```
User opens app → Camera screen (in-app camera only, no gallery picker)
  ↓
Captures photo → sent to Cloud Function identifyPlant (multipart)
  ↓
Cloud Function:
  1. Validate EXIF/camera metadata (anti-spoofing step 1)
  2. Send to Plant.id API
  3. Parse taxonomy result (species, family, genus, common names)
  4. If confidence < 60% → return "Try again" (no unlock)
  5. If confidence ≥ 60%:
     a. Check Firestore: does this plant_id exist in DB?
        - YES → return matched plant + rarity
        - NO → create "unverified" plant entry for admin review
     b. Check user's collection: has user unlocked this plant?
        - NO → apply rarity roll, create unlock doc, trigger achievement eval
        - YES (duplicate) → add XP, increment sightings
     c. Trigger async Cloud Function enrichInfo:
        → Self-hosted AI generates: description, origin, care guide, fun facts
        → Self-hosted AI translates to KH
        → Update Firestore plant doc with enriched info
  6. Return result to client (plant data + unlock status + rarity badge + XP earned)
  ↓
Client: Show result screen → plant detail → celebration if new unlock
```

---

## 5. Project Directory Structure

```
UrPlant/
├── docs/                          ← Memory Bank (this directory)
│   ├── MB.md
│   ├── PRD.md
│   ├── TECH_STACK.md
│   ├── DATABASE_SCHEMA.md
│   ├── API_SPEC.md
│   ├── UX_SPEC.md
│   ├── RARITY_ACHIEVEMENTS.md
│   ├── LOCALIZATION.md
│   ├── ADMIN_PORTAL.md
│   └── SETUP_GUIDE.md
├── mobile/                        ← Flutter app
│   ├── lib/
│   │   ├── main.dart
│   │   ├── app.dart
│   │   ├── config/
│   │   │   ├── theme.dart
│   │   │   ├── routes.dart
│   │   │   └── firebase_options.dart
│   │   ├── core/
│   │   │   ├── constants/
│   │   │   ├── errors/
│   │   │   ├── network/
│   │   │   └── utils/
│   │   ├── data/
│   │   │   ├── models/
│   │   │   ├── repositories/
│   │   │   └── services/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   └── usecases/
│   │   ├── presentation/
│   │   │   ├── auth/
│   │   │   ├── camera/
│   │   │   ├── result/
│   │   │   ├── plant_detail/
│   │   │   ├── encyclopedia/
│   │   │   ├── profile/
│   │   │   ├── achievements/
│   │   │   └── widgets/
│   │   └── l10n/
│   │       ├── app_en.arb
│   │       └── app_kh.arb
│   ├── assets/
│   │   ├── fonts/
│   │   │   └── NotoSansKhmer/
│   │   ├── images/
│   │   ├── animations/
│   │   └── audio/
│   ├── test/
│   ├── pubspec.yaml
│   └── analysis_options.yaml
├── functions/                     ← Firebase Cloud Functions
│   ├── src/
│   │   ├── index.ts
│   │   ├── identifyPlant.ts
│   │   ├── enrichInfo.ts
│   │   ├── adminApi.ts
│   │   ├── achievements.ts
│   │   ├── antiSpoofing.ts
│   │   └── utils/
│   │       ├── plantIdClient.ts
│   │       ├── aiGateway.ts
│   │       ├── firestore.ts
│   │       └── rarityRoll.ts
│   ├── package.json
│   ├── tsconfig.json
│   └── .env.example
├── admin/                         ← Admin portal (React + Vite)
│   ├── src/
│   │   ├── App.tsx
│   │   ├── main.tsx
│   │   ├── pages/
│   │   │   ├── Dashboard.tsx
│   │   │   ├── Plants.tsx
│   │   │   ├── PlantForm.tsx
│   │   │   ├── Users.tsx
│   │   │   ├── Achievements.tsx
│   │   │   └── Login.tsx
│   │   ├── components/
│   │   ├── hooks/
│   │   ├── services/
│   │   └── store/
│   ├── package.json
│   ├── vite.config.ts
│   ├── tailwind.config.js
│   └── index.html
├── firestore.rules
├── firebase.json
├── .gitignore
└── README.md
```

---

## 6. Key Decisions Log

| Date | Decision | Rationale | Alternatives Considered |
|------|----------|-----------|------------------------|
| 2026-08-06 | Flutter | Single codebase for Android + iOS, best UI rendering, excellent camera plugin, native Khmer font support | React Native (weaker camera, JS bridge), Native (2x dev effort) |
| 2026-08-06 | Plant.id API for identification | Purpose-trained, 80-95% accuracy, clear pricing | PlantNet (non-commercial only), self-trained (too slow), generic vision AI (poor species accuracy) |
| 2026-08-06 | Self-hosted AI (DeepSeek/OpenAI gateway) for enrichment | Cost-effective content generation + KH translation, leverages existing infra | Claude/Gemini API (per-call cost would exceed self-hosted) |
| 2026-08-06 | Firebase | Managed auth, Firestore NoSQL matches plant data shape, Cloud Functions for server-side logic, free tier for MVP | Supabase (PostgreSQL but less mature mobile auth), custom backend (more dev time) |
| 2026-08-06 | Firestore NoSQL | Flexible schema for varied plant data, real-time listeners for encyclopedia updates, scales to millions of docs | PostgreSQL/SQL (rigid schema, more complex setup for rapid plant data iteration) |
| 2026-08-06 | Plant.id > confidence 60% | Below 60% = unreliable species ID; "try again" flow prevents bad unlocks | 70% (too strict, many rare plants excluded), 50% (too loose, wrong IDs) |

---

## 7. Naming Conventions

| Context | Convention | Example |
|---------|------------|---------|
| Dart files | snake_case | `plant_detail_screen.dart` |
| Dart classes | PascalCase | `PlantDetailScreen` |
| Dart variables | camelCase | `isUnlocked` |
| Firestore collections | snake_case | `user_plants` |
| Firestore document IDs | auto-generated or kebab-case | `aloe-vera` |
| Cloud Functions | camelCase | `identifyPlant` |
| React components | PascalCase | `PlantForm.tsx` |
| ARB keys | snake_case | `camera_capture_hint` |
| Git branches | kebab-case prefix/category-description | `feat/camera-ui`, `fix/auth-token-refresh` |

---

## 8. Work Log (Auto-Updated by AI Assistant)

| Date | What Changed | Scope |
|------|-------------|-------|
| 2026-08-06 | MB initialized, Phase 0 docs generated | Full project |

---

## Quick Reference for AI Assistants

**"I need to add a new achievement"**
→ Read `docs/RARITY_ACHIEVEMENTS.md` for achievement definitions
→ Modify `functions/src/achievements.ts` for server-side logic
→ Update `mobile/lib/presentation/achievements/` for UI
→ Add achievement doc to Firestore `achievements` collection

**"I need to change the camera UI"**
→ Read `docs/UX_SPEC.md` Camera Screen section
→ Edit `mobile/lib/presentation/camera/`
→ Ensure no gallery/file picker is accidentally introduced

**"I need to add a new language"**
→ Read `docs/LOCALIZATION.md`
→ Add new ARB file in `mobile/lib/l10n/`
→ Update `pubspec.yaml` localized locales

**"I need to update the rarity pool"**
→ Read `docs/RARITY_ACHIEVEMENTS.md`
→ Update `functions/src/utils/rarityRoll.ts`
→ Update Remote Config values in Firebase console

**"I need to switch AI identification providers"**
→ Read `docs/TECH_STACK.md` Section 4 (AI Provider Architecture)
→ Update Remote Config `ai_provider` value (zero code changes)
→ Options: `self_hosted_vlm` → `plantid` → `openai_vision_gateway`
