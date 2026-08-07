# 🌿 UrPlant — Plant Recognition App

**Discover · Identify · Collect**

UrPlant is a bilingual (English & Khmer) mobile app that uses AI to identify real-world plants through your phone's camera. Build your personal plant encyclopedia, unlock rare species, earn achievements, and explore rich botanical knowledge.

---

## 📱 App Features

- 🔍 **AI Plant Recognition** — Snap a photo in-app and identify plants instantly with Plant.id AI
- 🏆 **Rarity System** — Normal (70%), Rare (25%), Special Rare (5%) plants with unique celebration animations
- 📚 **Personal Encyclopedia** — Unlock plants by finding them in real life; locked plants show as mysterious silhouettes
- 🎯 **Achievements** — 26 achievements across Collection, Rarity, Exploration, Streak, and Special categories
- 🌍 **Bilingual** — Full English & Khmer (ភាសាខ្មែរ) support — all UI, plant names, descriptions, care guides
- 📷 **In-App Camera Only** — No gallery uploads or internet photos allowed; anti-spoofing validation
- 🎨 **Beautiful UX** — Material 3 design, confetti celebrations, haptic feedback, rarity-based animations
- 🛡️ **Admin Portal** — Web dashboard for plant database management, photo review, user management, analytics

---

## 🏗️ Architecture

```
Mobile App (Flutter)     Backend (Firebase)        Admin Portal (React)
     │                       │                          │
     ├─ Camera capture ──→ Cloud Functions ──→ Plant.id API
     │                       │                  Self-hosted AI
     ├─ Encyclopedia  ←── Firestore ←─── Admin CRUD
     │                       │
     ├─ Achievements  ←── Cloud Functions
     │                       │
     └─ Profile        ←── Firebase Auth
```

---

## 📂 Project Structure

| Directory | Purpose |
|-----------|---------|
| [`docs/`](docs/) | **Memory Bank** — complete technical blueprint (9 documents) |
| [`mobile/`](mobile/) | Flutter mobile app (Android + iOS) |
| [`functions/`](functions/) | Firebase Cloud Functions (Node.js/TypeScript) |
| [`admin/`](admin/) | Admin web portal (React + Vite + Tailwind) |

---

## 📚 Memory Bank (Documentation Blueprint)

The `docs/` directory contains the complete **MB (Memory Bank)** — a full technical specification for building UrPlant from scratch using AI coding assistants (Cline, Copilot, etc.).

| # | Document | Contents |
|---|----------|----------|
| 1 | **[MB.md](docs/MB.md)** | Master index, architecture diagram, data flow, naming conventions, quick reference |
| 2 | **[PRD.md](docs/PRD.md)** | Product requirements, user stories, functional/non-functional specs, KPIs |
| 3 | **[TECH_STACK.md](docs/TECH_STACK.md)** | Complete technology stack with versions, rationale, dependencies, costs |
| 4 | **[DATABASE_SCHEMA.md](docs/DATABASE_SCHEMA.md)** | Firestore collections, schemas, indexes, security rules, query patterns |
| 5 | **[API_SPEC.md](docs/API_SPEC.md)** | Cloud Functions endpoints, Plant.id integration, request/response schemas, anti-spoofing |
| 6 | **[UX_SPEC.md](docs/UX_SPEC.md)** | Screen-by-screen UX/UI: 13 screens, animations, colors, typography, empty states |
| 7 | **[RARITY_ACHIEVEMENTS.md](docs/RARITY_ACHIEVEMENTS.md)** | Rarity system (Normal/Rare/Special Rare), XP/level mechanics, 26 achievement definitions |
| 8 | **[LOCALIZATION.md](docs/LOCALIZATION.md)** | EN/KH bilingual strategy, complete ARB files (~150 keys each), font setup, AI translation |
| 9 | **[ADMIN_PORTAL.md](docs/ADMIN_PORTAL.md)** | Admin web app: 10+ pages, component tree, API integration, auth/security |
| 10 | **[SETUP_GUIDE.md](docs/SETUP_GUIDE.md)** | Step-by-step from blank machine to running app (Firebase, Flutter, Functions, Admin, CI/CD) |

---

## 🚀 Quick Start

### Prerequisites
- Node.js 20+, Flutter 3.24+, Firebase CLI
- Plant.id API account
- Firebase project with Blaze plan

### Setup
```bash
# 1. Clone
git clone https://github.com/keovoin/UrPlant.git
cd UrPlant

# 2. Follow the full setup guide
# Open docs/SETUP_GUIDE.md for the complete step-by-step

# 3. Quick overview:
# Firebase init
firebase init

# Flutter mobile
cd mobile && flutter pub get && flutter run

# Cloud Functions
cd functions && npm install && npm run build
cd .. && firebase deploy --only functions

# Admin Portal
cd admin && npm install && npm run dev
```

---

## 💰 Estimated Monthly Cost (MVP Scale)

| Service | Cost |
|---------|------|
| Firebase (Spark + Blaze) | $0-5 |
| Plant.id API (500 credits) | ~$25 |
| Self-hosted AI | $0 (existing) |
| Apple Developer | $99/yr |
| Google Play | $25 (one-time) |
| **Total** | **~$34/mo** |

---

## 🛠️ Tech Stack

- **Mobile**: Flutter 3.24+, Riverpod, Camera Plugin, Material 3
- **Backend**: Firebase Cloud Functions (Node.js 20/TypeScript), Firestore, Storage, Auth
- **AI**: Plant.id API (identification) + Self-hosted AI (DeepSeek/OpenAI gateway — enrichment & KH translation)
- **Admin**: React 18, Vite 5, Tailwind CSS 3.4, TanStack Query, Recharts
- **CI/CD**: GitHub Actions

---

## 📊 MVP Scope

| Phase | Timeline | Deliverables |
|-------|----------|-------------|
| Phase 1 | Week 1-2 | Flutter scaffold, Firebase setup, Auth, Localization |
| Phase 2 | Week 3-4 | Camera, Cloud Functions, Plant.id integration |
| Phase 3 | Week 5-6 | Plant DB, Encyclopedia, Collection/Unlock, Rarity system |
| Phase 4 | Week 7 | Achievements, Celebrations, Profile |
| Phase 5 | Week 8 | Admin Portal |
| Phase 6 | Week 9-10 | KH polish, Testing, App Store submission |

---

## 📄 License

Proprietary — All rights reserved.

---

*Built with ❤️ for plant lovers in Cambodia and beyond.* 🇰🇭 🌏