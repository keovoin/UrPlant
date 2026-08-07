# UrPlant — Product Requirements Document (PRD)

> **Version**: 1.0.0 · **Status**: Draft · **Last Updated**: 2026-08-06
>
> This document defines the complete product requirements, user stories, feature list, and acceptance criteria for UrPlant MVP.

---

## 1. Product Vision & Goals

### Vision
UrPlant empowers anyone—from curious children to seasoned botanists—to discover, learn about, and collect the plants around them using only their phone camera. By turning real-world plant discovery into a gamified, bilingual experience (English & Khmer), UrPlant makes nature accessible, educational, and fun.

### MVP Goals
| # | Goal | Success Metric |
|---|------|----------------|
| G1 | Accurately identify 100+ common plant species via in-app camera | ≥80% identification accuracy |
| G2 | Deliver a polished EN/KH bilingual experience | 100% UI + plant content in both languages |
| G3 | Create a compelling collection & achievement loop | 30% Day-7 retention |
| G4 | Provide rich plant knowledge (taxonomy, origin, care) | Average session >2 min on plant detail |
| G5 | Ensure only real-world photos are used (anti-spoofing) | <5% flagged spoofed uploads |
| G6 | Admin can manage plant database without code | All plant CRUD via admin portal |

---

## 2. User Personas

| Persona | Description | Key Need |
|---------|-------------|----------|
| **Casual Explorer (Rithy)** | 22, university student, curious about plants on campus. Uses KH primarily. | Quick ID, simple encyclopedia, fun unlocks |
| **Plant Enthusiast (Sophea)** | 35, home gardener, wants care tips. Uses EN + KH. | Detailed plant info, care guides, tracking collection |
| **Nature Educator (John)** | 28, NGO worker, uses app to teach kids about local flora. EN primary. | Bilingual content, offline-friendly, easy sharing |
| **Admin (Dara)** | 30, content manager, botanist background. Manages plant DB. | Easy plant CRUD, photo review, analytics |

---

## 3. Functional Requirements

### FR1: Authentication & Onboarding
| ID | Requirement | Priority |
|----|-------------|----------|
| FR1.1 | Email/password registration and login via Firebase Auth | P0 |
| FR1.2 | Google Sign-In (one-tap) | P1 |
| FR1.3 | Apple Sign-In (iOS requirement) | P0 (iOS) |
| FR1.4 | Guest mode — limited scans (3/day), full feature preview | P1 |
| FR1.5 | Onboarding carousel (3 slides): Discover → Identify → Collect | P0 |
| FR1.6 | Language picker on first launch (EN/KH), changeable in settings | P0 |
| FR1.7 | Password reset via email | P1 |
| FR1.8 | Account deletion (GDPR compliance) | P1 |

### FR2: Camera & Capture
| ID | Requirement | Priority |
|----|-------------|----------|
| FR2.1 | Full-screen in-app camera view with viewfinder overlay | P0 |
| FR2.2 | Tap-to-focus, pinch-to-zoom | P1 |
| FR2.3 | Capture button (circular, animated press) | P0 |
| FR2.4 | Flash toggle (auto/on/off) | P1 |
| FR2.5 | **NO gallery/file picker** — camera only | P0 (hard req) |
| FR2.6 | Frame guide overlay (leaf icon silhouette) to help users frame plant properly | P1 |
| FR2.7 | Camera permission handling with rationale dialog | P0 |
| FR2.8 | Image captured at device resolution, compressed before upload (max 4MB) | P0 |
| FR2.9 | EXIF metadata preserved and sent to server | P0 |
| FR2.10 | "Retake" / "Use Photo" confirmation after capture | P0 |

### FR3: AI Identification Flow
| ID | Requirement | Priority |
|----|-------------|----------|
| FR3.1 | Upload image to Cloud Function `identifyPlant` | P0 |
| FR3.2 | Loading state: animated leaf pulse with "Identifying..." text (EN/KH) | P0 |
| FR3.3 | Server-side anti-spoofing validation (EXIF check, metadata, heuristics) | P0 |
| FR3.4 | Identification via Plant.id API | P0 |
| FR3.5 | Confidence threshold ≥60% for positive ID | P0 |
| FR3.6 | Below threshold: "Couldn't identify — try a clearer photo" UI | P0 |
| FR3.7 | Match identified species to Firestore plant DB | P0 |
| FR3.8 | Unmatched species: create "unverified" entry, notify admin | P1 |
| FR3.9 | Async enrichment via self-hosted AI (description, origin, care, KH translation) | P1 |
| FR3.10 | Progress indicator per enrichment step ("Generating description...", "Translating...") | P2 |

### FR4: Plant Unlock & Rarity
| ID | Requirement | Priority |
|----|-------------|----------|
| FR4.1 | First identification of a plant = UNLOCK | P0 |
| FR4.2 | Rarity roll on unlock: Normal 70%, Rare 25%, Special Rare 5% | P0 |
| FR4.3 | Celebration animation: confetti + rarity badge reveal + haptic feedback | P0 |
| FR4.4 | Celebration intensity scales with rarity (Normal: subtle pulse, Rare: confetti burst, Special Rare: full-screen confetti + sound + glow) | P0 |
| FR4.5 | Duplicate identification (already unlocked): +50 XP, increment sighting counter | P0 |
| FR4.6 | "Already collected!" banner on duplicate with XP earned toast | P0 |
| FR4.7 | Rarity badge displayed on plant detail + encyclopedia card | P0 |
| FR4.8 | Rarity badge colors: Normal = Green (#4CAF50), Rare = Blue (#2196F3), Special Rare = Gold (#FFD700) | P0 |

### FR5: Plant Detail Screen
| ID | Requirement | Priority |
|----|-------------|----------|
| FR5.1 | Hero image: user's captured photo at top | P0 |
| FR5.2 | Plant name: scientific name (italic), common name EN, common name KH | P0 |
| FR5.3 | Rarity badge (colored, positioned top-right of hero) | P0 |
| FR5.4 | Taxonomy section: Kingdom, Family, Genus, Species | P1 |
| FR5.5 | Origin / native region with mini map or text | P1 |
| FR5.6 | Care guide (expandable accordion): Water, Sunlight, Soil, Temperature, Humidity | P1 |
| FR5.7 | Fun facts (1-3 bullet points) | P1 |
| FR5.8 | Discovery info: date unlocked, location (if permission granted), sighting count | P1 |
| FR5.9 | Language toggle on detail screen (tap to switch EN/KH for this plant) | P0 |
| FR5.10 | Share plant card (generates image with plant photo + name + rarity badge) | P2 |
| FR5.11 | "View in Encyclopedia" link back to full list | P1 |

### FR6: Encyclopedia
| ID | Requirement | Priority |
|----|-------------|----------|
| FR6.1 | Grid/list view of all plants in database | P0 |
| FR6.2 | Unlocked plants: full-color card with photo, name, rarity badge | P0 |
| FR6.3 | Locked plants: dark silhouette with "?" and hint text ("Find this plant to unlock") | P0 |
| FR6.4 | Rarity filter chips: All / Normal / Rare / Special Rare | P0 |
| FR6.5 | Search bar: search by EN or KH name, scientific name | P0 |
| FR6.6 | Sort options: A-Z, Rarity, Recently Unlocked | P1 |
| FR6.7 | Collection stats header: "X/Total unlocked" with progress bar | P0 |
| FR6.8 | Pull-to-refresh (syncs with Firestore for newly added plants) | P1 |
| FR6.9 | Empty state: "Start exploring! Take a photo of a plant to begin your collection." | P1 |

### FR7: Achievements
| ID | Requirement | Priority |
|----|-------------|----------|
| FR7.1 | Achievement types: Collection milestones, Rarity milestones, Streaks, Special | P0 |
| FR7.2 | Achievement notification: toast + badge in profile when earned | P0 |
| FR7.3 | Achievement wall in Profile: grid of earned + locked badges | P0 |
| FR7.4 | Locked achievements show grayed-out icon + progress bar + requirement text | P0 |
| FR7.5 | XP system: unlock plant = 100 XP, duplicate = 50 XP, achievement = bonus XP | P0 |
| FR7.6 | Level system tied to total XP (Level 1-50) | P1 |
| FR7.7 | Full achievement list defined in [RARITY_ACHIEVEMENTS.md](./RARITY_ACHIEVEMENTS.md) | P0 |

### FR8: Profile & Settings
| ID | Requirement | Priority |
|----|-------------|----------|
| FR8.1 | Profile header: avatar, display name, level, XP bar | P0 |
| FR8.2 | Stats: total scans, plants unlocked, achievements earned, rare plants found | P0 |
| FR8.3 | Achievement wall (see FR7) | P0 |
| FR8.4 | Settings: language toggle (EN/KH), notification prefs, account management | P0 |
| FR8.5 | Theme toggle (light/dark) — post-MVP stretch | P3 |
| FR8.6 | Logout | P0 |
| FR8.7 | Delete account (see FR1.8) | P1 |

### FR9: Admin Portal
| ID | Requirement | Priority |
|----|-------------|----------|
| FR9.1 | Secure admin login (Firebase Auth + admin claim) | P0 |
| FR9.2 | Plant CRUD: create, edit, delete plants with all fields | P0 |
| FR9.3 | Upload plant photos (for reference images) | P0 |
| FR9.4 | Assign/change plant rarity | P0 |
| FR9.5 | Review "unverified" plants (identified but not in DB) | P1 |
| FR9.6 | Flagged photo review queue | P1 |
| FR9.7 | User management: list users, view collections, ban users | P1 |
| FR9.8 | Achievement management: create/edit achievement definitions | P1 |
| FR9.9 | Analytics dashboard: total users, scans, unlocks, popular plants | P2 |
| FR9.10 | Bulk import plants via CSV/JSON | P2 |

### FR10: Localization
| ID | Requirement | Priority |
|----|-------------|----------|
| FR10.1 | All UI strings in both EN and KH via ARB files | P0 |
| FR10.2 | Plant names, descriptions, care tips in both EN and KH | P0 |
| FR10.3 | Dynamic KH translation via self-hosted AI for new/unverified plants | P1 |
| FR10.4 | Noto Sans Khmer font for all KH text | P0 |
| FR10.5 | Language switch updates UI instantly (no app restart) | P0 |
| FR10.6 | RTL-aware layout (KH is LTR, but ensure proper rendering) | P0 |

---

## 4. Non-Functional Requirements

| ID | Category | Requirement |
|----|----------|-------------|
| NFR1 | Performance | Camera opens in <1.5s from cold start |
| NFR2 | Performance | Image upload + identification response in <8s (90th percentile) |
| NFR3 | Performance | Encyclopedia loads 50 plants in <2s (paginated) |
| NFR4 | Reliability | 99.5% uptime for Cloud Functions |
| NFR5 | Security | All API keys stored server-side only (Cloud Functions env vars) |
| NFR6 | Security | Firestore security rules enforce user isolation |
| NFR7 | Security | Admin functions restricted by Firebase Auth custom claims |
| NFR8 | UX | App works offline for browsing unlocked plants (cached data) |
| NFR9 | UX | Photo uploads compressed client-side, max 4MB |
| NFR10 | Accessibility | Minimum contrast ratio 4.5:1 for all text |
| NFR11 | Accessibility | Touch targets minimum 48x48dp |
| NFR12 | Storage | Plant images in Firebase Storage, optimized to WebP format |
| NFR13 | Cost | Firestore reads optimized: paginated queries, client-side caching |

---

## 5. User Stories (MVP Scope)

### Epic 1: Onboarding & Auth
- **US-1.1**: As a new user, I can sign up with email so I can track my plant collection.
- **US-1.2**: As a returning user, I can log in with Google so I don't need a new password.
- **US-1.3**: As a curious visitor, I can try the app in guest mode before committing.
- **US-1.4**: As a Khmer speaker, I can choose KH on first launch so the app is in my language.

### Epic 2: Camera & Identification
- **US-2.1**: As a user, I can open the in-app camera and take a photo of a plant.
- **US-2.2**: As a user, I see "Identifying..." animation while the AI works.
- **US-2.3**: As a user, I'm told to retake if the plant couldn't be identified clearly.
- **US-2.4**: As a user, I can only use the camera to capture (no gallery upload).

### Epic 3: Plant Unlock & Collection
- **US-3.1**: As a user, I unlock a plant in my encyclopedia when first identified.
- **US-3.2**: As a user, I see a celebration animation when I unlock a plant.
- **US-3.3**: As a user, I earn XP when I scan plants (even duplicates).
- **US-3.4**: As a user, I can see my collection with rarity badges.

### Epic 4: Plant Knowledge
- **US-4.1**: As a user, I can view detailed plant info after unlocking.
- **US-4.2**: As a user, I can read plant info in both English and Khmer.
- **US-4.3**: As a user, I can learn care tips for plants I've discovered.

### Epic 5: Encyclopedia
- **US-5.1**: As a user, I can browse all plants (unlocked or locked).
- **US-5.2**: As a user, I can search plants by EN or KH name.
- **US-5.3**: As a user, I can filter by rarity.

### Epic 6: Achievements
- **US-6.1**: As a user, I earn achievements as I collect more plants.
- **US-6.2**: As a user, I can view my achievement progress in my profile.

### Epic 7: Admin
- **US-7.1**: As an admin, I can add/edit/delete plants in the database.
- **US-7.2**: As an admin, I can review unverified plants from user scans.

---

## 6. Out of Scope (Post-MVP)

| Feature | Reason Deferred |
|---------|-----------------|
| Social features (friends, leaderboard) | Increase engagement before adding social |
| Offline identification | Requires on-device ML model, significant engineering |
| Subscription/payment integration | Data model ready, Stripe/RevenueCat later |
| Plant health diagnosis (disease/pest) | Separate ML model, different API |
| AR mode (plant overlay in camera) | Complex, low MVP priority |
| Community-submitted plant entries | Moderation complexity |
| Dark mode | Nice-to-have, not blocking |
| Widget (iOS/Android home screen) | Post-MVP polish |
| Multi-language beyond EN/KH | Future expansion |

---

## 7. Success Metrics (KPIs)

| Metric | Target | Measurement |
|--------|--------|-------------|
| D1 Retention | ≥40% | Firebase Analytics |
| D7 Retention | ≥30% | Firebase Analytics |
| D30 Retention | ≥20% | Firebase Analytics |
| Avg scans per user (D7) | ≥5 | Cloud Function logs |
| Identification accuracy | ≥80% | Plant.id confidence + user feedback |
| KH language usage | ≥40% of users | Remote Config / Analytics user property |
| Encyclopedia browse time | ≥2 min avg session | Firebase Analytics screen time |
| Admin portal adoption | 100% plant management via portal | Admin action logs |

---

## 8. Glossary

| Term | Definition |
|------|------------|
| **Unlock** | The first time a user identifies a specific plant species, it becomes "unlocked" in their encyclopedia |
| **Sighting** | Any plant identification (including duplicates); increments a counter |
| **Rarity** | Normal (70%), Rare (25%), Special Rare (5%) — assigned randomly on first unlock |
| **XP** | Experience points earned from scanning plants and completing achievements |
| **Anti-Spoofing** | Server-side validation that a photo was taken with a real camera, not uploaded from gallery/internet |
| **Enrichment** | AI-generated content (description, origin, care tips, KH translation) added to plant records |
| **Unverified Plant** | A species identified by Plant.id but not yet in the Firestore plant database |
| **ARB** | Application Resource Bundle — Flutter's localization file format (.arb) |