# UrPlant — Setup Guide (From Scratch to Running App)

> **Version**: 1.0.0 · **Last Updated**: 2026-08-06
>
> Step-by-step guide to set up the UrPlant project from a blank machine to a running app (mobile, backend, admin). Follow in order. Estimated time: 2-4 hours for full setup.

---

## 0. Prerequisites

### Required Accounts (create before starting)
- [ ] Google Account (for Firebase)
- [ ] GitHub Account
- [ ] Apple Developer Account ($99/year — for iOS deployment only; not needed for Android dev)
- [ ] Plant.id Account (https://plant.id — sign up, get API key from dashboard)

### Required Software (install first)

| Tool | Version | Install |
|------|---------|---------|
| **Node.js** | 20 LTS | https://nodejs.org |
| **Flutter SDK** | ≥3.24 | https://flutter.dev/docs/get-started/install |
| **Firebase CLI** | Latest | `npm install -g firebase-tools` |
| **Git** | Latest | https://git-scm.com |
| **VS Code** | Latest | https://code.visualstudio.com |
| **Xcode** | Latest | Mac App Store (iOS only) |
| **Android Studio** | Latest | https://developer.android.com/studio |
| **Java JDK** | 17 | Included with Android Studio |

### Verify Installations

```bash
node --version    # Should be v20.x
npm --version     # Should be 10.x
flutter doctor    # Should show all green checks
firebase --version # Should be 13.x+
git --version
```

---

## 1. Firebase Project Setup

### 1.1 Create Firebase Project

1. Go to https://console.firebase.google.com
2. Click **"Add Project"**
3. Project name: `urplant-app` (or your preferred name)
4. Enable Google Analytics (recommended)
5. Choose or create a Google Analytics account
6. Click **"Create Project"**

### 1.2 Enable Services

In Firebase Console, go to **Build** → enable:

- [ ] **Authentication**
  - Sign-in method: Email/Password ✓
  - Sign-in method: Google ✓ (configure OAuth consent)
  - Sign-in method: Apple ✓ (requires Apple Developer account)
  - Sign-in method: Anonymous ✓ (for guest mode)

- [ ] **Cloud Firestore**
  - Create database (choose location closest to users: e.g., `asia-southeast1` for Cambodia)
  - Start in **production mode** (we'll set rules later)

- [ ] **Storage**
  - Set up (default settings are fine)

- [ ] **Hosting**
  - Set up (for admin portal)

- [ ] **Cloud Functions** (automatically enabled when you first deploy)

### 1.3 Upgrade to Blaze Plan

Cloud Functions require the Blaze (pay-as-you-go) plan:
1. Firebase Console → ⚙️ → **Usage and billing**
2. Click **"Modify plan"** → Select **Blaze**
3. Set a budget alert (e.g., $25/month) to prevent unexpected charges
4. Free tier includes 2M function invocations/month — you likely won't exceed this at MVP

### 1.4 Firebase CLI Login

```bash
firebase login
# Follow browser prompts to authenticate
```

---

## 2. Project Scaffold

### 2.1 Clone Repository (or Initialize)

```bash
# If starting from GitHub:
git clone https://github.com/keovoin/UrPlant.git
cd UrPlant

# Or initialize fresh:
mkdir UrPlant && cd UrPlant
git init
```

### 2.2 Create Directory Structure

```bash
mkdir -p docs
mkdir -p mobile/lib/{config,core/{constants,errors,network,utils},data/{models,repositories,services},domain/{entities,usecases},presentation/{auth,camera,result,plant_detail,encyclopedia,profile,achievements,widgets},l10n}
mkdir -p mobile/assets/{fonts/NotoSansKhmer,images,animations,audio}
mkdir -p mobile/test
mkdir -p functions/src/utils
mkdir -p admin/src/{pages,components,hooks,services,store}
```

### 2.3 Firebase Init

```bash
# In project root:
firebase init

# Select features (space to select):
# ◯ Firestore
# ◯ Functions
# ◯ Hosting
# ◯ Storage
# ◯ Emulators

# For Functions:
# - Language: TypeScript
# - ESLint: Yes
# - Install dependencies: Yes

# For Hosting:
# - Public directory: admin/dist
# - Single-page app: Yes
# - GitHub deploys: No

# For Emulators:
# - Firestore, Functions, Hosting, Storage, Auth
# - Ports: default
# - Download emulators: Yes
```

This creates:
- `firebase.json`
- `firestore.rules`
- `storage.rules`
- `functions/package.json`
- `functions/tsconfig.json`
- `functions/src/index.ts`

---

## 3. Flutter Mobile App Setup

### 3.1 Create Flutter Project

```bash
flutter create mobile --org com.urplant --project-name urplant
cd mobile
```

### 3.2 Add Firebase to Flutter

```bash
# Install flutterfire CLI
dart pub global activate flutterfire_cli

# Configure Firebase (follow prompts)
flutterfire configure --project=urplant-app

# This generates:
# lib/firebase_options.dart
# android/app/google-services.json
# ios/Runner/GoogleService-Info.plist
```

### 3.3 Add Dependencies

Copy the dependencies from `docs/TECH_STACK.md` Section 2.2 into `mobile/pubspec.yaml`:

```bash
cd mobile
flutter pub add firebase_core firebase_auth cloud_firestore firebase_storage \
  firebase_analytics firebase_crashlytics firebase_remote_config \
  camera image_picker flutter_riverpod dio connectivity_plus \
  flutter_localizations intl cached_network_image shimmer confetti lottie \
  flutter_svg google_fonts shared_preferences image uuid permission_handler \
  json_annotation freezed_annotation

flutter pub add -d flutter_lints mockito build_runner riverpod_generator \
  json_serializable freezed
```

### 3.4 Configure ARB Localization

Create `mobile/lib/l10n/app_en.arb` and `mobile/lib/l10n/app_kh.arb` with the content from `docs/LOCALIZATION.md`.

Update `pubspec.yaml`:

```yaml
flutter:
  generate: true  # Enable ARB code generation
  
  fonts:
    - family: Poppins
      fonts:
        - asset: assets/fonts/Poppins-Regular.ttf
        - asset: assets/fonts/Poppins-Medium.ttf
          weight: 500
        - asset: assets/fonts/Poppins-SemiBold.ttf
          weight: 600
        - asset: assets/fonts/Poppins-Bold.ttf
          weight: 700
    - family: NotoSansKhmer
      fonts:
        - asset: assets/fonts/NotoSansKhmer/NotoSansKhmer-Regular.ttf
        - asset: assets/fonts/NotoSansKhmer/NotoSansKhmer-Bold.ttf
          weight: 700
```

Download font files:
```bash
# Download Noto Sans Khmer from Google Fonts:
# https://fonts.google.com/noto/specimen/Noto+Sans+Khmer
# Place in assets/fonts/NotoSansKhmer/
```

### 3.5 Generate Localization Code

```bash
flutter gen-l10n
# Generates: .dart_tool/flutter_gen/gen_l10n/app_localizations.dart
#           .dart_tool/flutter_gen/gen_l10n/app_localizations_en.dart
#           .dart_tool/flutter_gen/gen_l10n/app_localizations_kh.dart
```

### 3.6 iOS Camera Permission

Edit `mobile/ios/Runner/Info.plist` and add:

```xml
<key>NSCameraUsageDescription</key>
<string>UrPlant needs camera access to identify plants in real time. Only live photos — no gallery uploads.</string>
<key>NSLocationWhenInUseUsageDescription</key>
<string>Optionally tag where you found your plants on the map.</string>
```

### 3.7 Android Camera Permission

Edit `mobile/android/app/src/main/AndroidManifest.xml` and ensure:

```xml
<uses-permission android:name="android.permission.CAMERA" />
<uses-feature android:name="android.hardware.camera" android:required="true" />
```

### 3.8 Verify Flutter Build

```bash
flutter clean
flutter pub get
flutter run  # Run on connected device/emulator
# Should see default Flutter counter app (we'll replace with UrPlant screens)
```

---

## 4. Cloud Functions Setup

### 4.1 Install Dependencies

```bash
cd functions
npm install firebase-functions firebase-admin axios sharp exifreader uuid zod cors
npm install -D typescript @types/node firebase-functions-test
```

### 4.2 Set Up Self-Hosted VLM (Ollama + Qwen2-VL)

**This is your PRIMARY AI for plant identification. Runs on your existing server. Zero cost.**

On your AI server:
```bash
# 1. Install Ollama
curl -fsSL https://ollama.com/install.sh | sh

# 2. Pull a vision-language model (choose one)
ollama pull qwen2-vl:7b     # ~4.5GB — recommended, balanced accuracy/speed
# OR
ollama pull llava:13b        # ~7.4GB — slightly better accuracy, heavier

# 3. Test the model
ollama run qwen2-vl:7b
# → paste an image path and ask "What plant is this?"
# → should respond with a plant name

# 4. Expose Ollama to the internet (so Cloud Functions can reach it)
# Option A: nginx reverse proxy (recommended)
# Option B: SSH tunnel from Cloud Function
# Option C: If your server has a public IP, just open port 11434 with firewall rules

# Verify it's accessible:
curl http://YOUR_SERVER_IP:11434/api/tags
# Should return: {"models":[{"name":"qwen2-vl:7b",...}]}
```

### 4.3 Set Cloud Functions Environment Variables

```bash
firebase functions:config:set \
  ollama.url="http://YOUR_SERVER_IP:11434" \
  ollama.model="qwen2-vl:7b" \
  selfhosted.ai_url="YOUR_AI_GATEWAY_URL" \
  selfhosted.ai_key="YOUR_AI_GATEWAY_KEY" \
  selfhosted.ai_model="deepseek-chat"

# Plant.id (optional — set later for production upgrade):
# firebase functions:config:set plantid.api_key="YOUR_KEY" plantid.api_url="https://api.plant.id/v3"
```

### 4.4 Set Remote Config (AI Provider Selection)

In Firebase Console → Remote Config, add parameter:
- **Key**: `ai_provider`
- **Value**: `self_hosted_vlm` (default for MVP)
- Later change to `plantid` when you upgrade to Plant.id for production — no code changes needed

### 4.3 Create Function Files

Create the TypeScript source files as specified in:
- `docs/API_SPEC.md` for endpoint implementations
- `docs/DATABASE_SCHEMA.md` for Firestore data models

Key files to create:

```bash
touch functions/src/identifyPlant.ts
touch functions/src/enrichInfo.ts
touch functions/src/adminApi.ts
touch functions/src/achievements.ts
touch functions/src/antiSpoofing.ts
touch functions/src/utils/plantIdClient.ts
touch functions/src/utils/aiGateway.ts
touch functions/src/utils/firestore.ts
touch functions/src/utils/rarityRoll.ts
```

### 4.4 Update index.ts

```typescript
// functions/src/index.ts
import * as functions from 'firebase-functions';
export { identifyPlant } from './identifyPlant';
export { enrichInfo } from './enrichInfo';
export { adminApi } from './adminApi';
// Scheduled functions
export { resetDailyScans } from './scheduled';
```

### 4.5 Deploy Functions

```bash
cd functions
npm run build  # TypeScript → JavaScript
cd ..
firebase deploy --only functions
```

---

## 5. Admin Portal Setup

### 5.1 Create React + Vite Project

```bash
cd admin
npm create vite@latest . -- --template react-ts
npm install
```

### 5.2 Install Dependencies

```bash
npm install react-router-dom firebase axios zustand @tanstack/react-query \
  react-hook-form @hookform/resolvers zod recharts lucide-react \
  react-hot-toast date-fns
npm install -D tailwindcss postcss autoprefixer @types/react @types/react-dom
npx tailwindcss init -p
```

### 5.3 Configure Tailwind

Edit `tailwind.config.js`:

```javascript
/** @type {import('tailwindcss').Config} */
export default {
  content: ['./index.html', './src/**/*.{js,ts,jsx,tsx}'],
  theme: {
    extend: {
      colors: {
        primary: { DEFAULT: '#1B5E20', light: '#4CAF50', dark: '#0D3B0F' },
        rarity: { normal: '#4CAF50', rare: '#2196F3', special: '#FFD700' },
        background: '#FAF3E3',
      },
    },
  },
  plugins: [],
};
```

### 5.4 Set Environment Variable

Create `admin/.env`:

```bash
VITE_ADMIN_API_URL=https://us-central1-urplant-app.cloudfunctions.net/adminApi
VITE_FIREBASE_API_KEY=your_firebase_web_api_key
VITE_FIREBASE_PROJECT_ID=urplant-app
```

### 5.5 Build & Deploy

```bash
cd admin
npm run build
cd ..
firebase deploy --only hosting
```

---

## 6. Firestore Security Rules

### 6.1 Deploy Security Rules

Copy the rules from `docs/DATABASE_SCHEMA.md` Section 10 into `firestore.rules`:

```bash
firebase deploy --only firestore:rules
```

### 6.2 Storage Rules

Copy the rules from `docs/DATABASE_SCHEMA.md` Section 11 into `storage.rules`:

```bash
firebase deploy --only storage
```

---

## 7. First Admin User Setup

### 7.1 Create Admin User

1. In Firebase Console → Authentication → Users → **"Add user"**
2. Enter admin email and password
3. Copy the User UID

### 7.2 Set Admin Claim

```bash
# Via Firebase CLI shell
firebase functions:shell
> const admin = require('firebase-admin');
> admin.initializeApp();
> admin.auth().setCustomUserClaims('PASTE_ADMIN_UID_HERE', { admin: true });
> // Press Ctrl+C twice to exit

# Or via Node.js script:
node -e "
const admin = require('firebase-admin');
admin.initializeApp();
admin.auth().setCustomUserClaims('UID_HERE', { admin: true })
  .then(() => console.log('Admin claim set!'))
  .catch(console.error);
"
```

### 7.3 Verify Admin Access

1. Open admin portal URL (from Firebase Hosting)
2. Log in with admin email/password
3. Should see Dashboard — if redirected to login, check custom claim

---

## 8. Seed Data

### 8.1 Create Initial Achievement Definitions

Use the admin portal (Achievements → New Achievement) or Firestore console to create the initial 26 achievements defined in `docs/RARITY_ACHIEVEMENTS.md` Section 3.2.

Or use Firebase Admin SDK:

```javascript
// functions/scripts/seed-achievements.js
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

const achievements = [
  { id: 'first_plant', name_en: 'First Discovery', name_kh: 'ការរកឃើញដំបូង', /* ... all fields */ },
  // ... all 26 achievements
];

async function seed() {
  const batch = db.batch();
  for (const ach of achievements) {
    const ref = db.collection('achievements').doc(ach.id);
    batch.set(ref, ach);
  }
  await batch.commit();
  console.log('Achievements seeded!');
}
seed();
```

```bash
node functions/scripts/seed-achievements.js
```

### 8.2 Create Initial Plants

Use the admin portal to create the first 20-50 plants manually, or import via a seed script. This gives your encyclopedia initial content before users start scanning.

---

## 9. Local Development Workflow

### 9.1 Start Firebase Emulators

```bash
firebase emulators:start
```

Runs locally at:
- Firestore: `http://127.0.0.1:4000/firestore`
- Functions: `http://127.0.0.1:5001`
- Auth: `http://127.0.0.1:9099`
- Emulator UI: `http://127.0.0.1:4000`

### 9.2 Connect Flutter to Emulators

In `mobile/lib/main.dart`, add for debug builds:

```dart
if (kDebugMode) {
  await FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  await FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
  await FirebaseFunctions.instance.useFunctionsEmulator('localhost', 5001);
}
```

### 9.3 Admin Portal with Emulators

Set `VITE_ADMIN_API_URL=http://127.0.0.1:5001/urplant-app/us-central1/adminApi` in `.env.local`.

---

## 10. CI/CD Setup (GitHub Actions)

### 10.1 Create GitHub Secrets

In GitHub → Repository → Settings → Secrets and variables → Actions:

| Secret | Value |
|--------|-------|
| `FIREBASE_TOKEN` | `firebase login:ci` output |
| `PLANT_ID_API_KEY` | Plant.id API key |

### 10.2 Create Workflow File

Copy `.github/workflows/ci.yml` from `docs/TECH_STACK.md` Section 7.3.

```bash
mkdir -p .github/workflows
# Create .github/workflows/ci.yml with the YAML content
```

---

## 11. App Store Preparation

### 11.1 Google Play

1. Create developer account: https://play.google.com/console ($25 one-time)
2. Create app → fill store listing (name, description, screenshots, icon 512x512)
3. Upload signed APK/AAB (Flutter: `flutter build appbundle`)
4. Complete Data Safety section (camera usage, optional location)
5. Add Privacy Policy URL
6. Submit for review

### 11.2 Apple App Store

1. Enroll in Apple Developer Program: https://developer.apple.com ($99/year)
2. Create App ID in Certificates, Identifiers & Profiles
3. In Xcode: set Bundle Identifier, Team, Signing
4. Create app in App Store Connect
5. Fill App Store listing (description, screenshots 6.7" and 5.5", icon 1024x1024)
6. Complete App Privacy labels
7. Build: `flutter build ipa`
8. Upload via Xcode or Transporter
9. Submit for review

---

## 12. Verification Checklist

### Mobile App
- [ ] App launches without crash on Android emulator/device
- [ ] App launches without crash on iOS simulator/device
- [ ] Firebase Auth: email sign up works
- [ ] Firebase Auth: Google sign in works
- [ ] Firebase Auth: Apple sign in works (iOS only)
- [ ] Guest mode works (anonymous auth)
- [ ] Camera opens (permission granted)
- [ ] **No gallery/file picker visible anywhere**
- [ ] Photo capture works
- [ ] Plant identification works (returns result)
- [ ] New unlock celebration plays
- [ ] Duplicate identification works
- [ ] Low confidence shows error screen
- [ ] Encyclopedia loads from Firestore
- [ ] Search works in EN and KH
- [ ] Rarity filters work
- [ ] Plant detail screen shows all sections
- [ ] Language toggle works (EN ↔ KH, instant switch)
- [ ] Khmer text renders correctly (no boxes, no cut-off)
- [ ] Achievements wall shows progress
- [ ] Profile shows correct stats
- [ ] Logout works

### Cloud Functions
- [ ] `identifyPlant` returns correct response for known plant
- [ ] `identifyPlant` handles low confidence
- [ ] `identifyPlant` handles unmatched plant
- [ ] `identifyPlant` enforces daily scan limit
- [ ] `identifyPlant` writes scan audit log
- [ ] `enrichInfo` generates EN + KH content
- [ ] `adminApi` returns 403 for non-admin users
- [ ] `adminApi` CRUD operations work for admin
- [ ] `achievements` evaluation triggers correctly
- [ ] Anti-spoofing flags screenshots

### Admin Portal
- [ ] Login works with admin account
- [ ] Non-admin account rejected
- [ ] Dashboard shows stats
- [ ] Create/Edit/Delete plant works
- [ ] Image upload works
- [ ] Translate to Khmer button works
- [ ] User list shows all users
- [ ] User detail shows collection
- [ ] Ban/Unban user works
- [ ] Achievements CRUD works
- [ ] Unverified review queue works
- [ ] Flagged photo review works

### Security
- [ ] Firestore rules: cannot read other user's data
- [ ] Firestore rules: cannot write to admin-only collections
- [ ] Storage rules: cannot upload to other user's path
- [ ] API keys not exposed in Flutter app bundle
- [ ] Admin Cloud Function validates admin claim

---

## 13. Troubleshooting

| Issue | Solution |
|-------|----------|
| `flutter doctor` shows Android license not accepted | `flutter doctor --android-licenses` |
| Firebase iOS build fails | `cd mobile/ios && pod install --repo-update` |
| Cloud Functions deploy fails | Check `firebase-debug.log`; ensure Blaze plan is active |
| Plant.id returns 401 | Verify API key in `firebase functions:config:get` |
| Khmer text shows boxes | Ensure Noto Sans Khmer font is bundled in assets and referenced in pubspec.yaml |
| Camera plugin crashes on Android | Set `minSdkVersion 24` in `android/app/build.gradle` |
| Firestore permission denied | Deploy firestore rules: `firebase deploy --only firestore:rules` |
| Admin portal blank page | Check `admin/dist/` exists; run `npm run build` |
| Emulators not connecting | Kill any running emulators: `kill $(lsof -t -i:4000)` then restart |

---

## 14. Useful Commands Quick Reference

```bash
# Flutter
flutter clean && flutter pub get          # Reset dependencies
flutter run                                # Launch on device
flutter build appbundle                    # Android release build
flutter build ipa                          # iOS release build (macOS only)
flutter gen-l10n                           # Regenerate ARB localization

# Firebase
firebase emulators:start                   # Local development
firebase deploy --only functions           # Deploy functions
firebase deploy --only firestore:rules     # Deploy security rules
firebase deploy --only hosting             # Deploy admin portal
firebase functions:config:get              # View env vars
firebase functions:log                     # View function logs

# Admin Portal
cd admin && npm run dev                    # Dev server (localhost:5173)
cd admin && npm run build                  # Production build

# Git
git add . && git commit -m "feat: initial scaffold"
git push origin main