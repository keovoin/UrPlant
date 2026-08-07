# UrPlant — Admin Portal Specification

> **Version**: 1.0.0 · **Last Updated**: 2026-08-06
>
> Complete specification for the admin web portal: React + Vite + Tailwind CSS + Firebase. Used by content managers to curate the plant database, review flagged content, manage users, and view analytics.

---

## 1. Overview

### 1.1 Tech Stack

```
Tech: React 18 + TypeScript + Vite 5 + Tailwind CSS 3.4
State: Zustand (client) + TanStack Query (server)
Forms: React Hook Form + Zod validation
Charts: Recharts
Icons: Lucide React
Auth: Firebase Auth (email/password) + custom admin claim
Deploy: Firebase Hosting
```

### 1.2 Access Control

- Admin users must have `admin: true` Firebase Auth custom claim
- Claims set via Firebase Admin SDK (CLI or Cloud Function)
- All admin API calls routed through `adminApi` Cloud Function which validates the claim
- Login page checks for admin claim before granting access
- Session timeout: 8 hours (Firebase default)

### 1.3 URL Routes

| Route | Page | Description |
|-------|------|-------------|
| `/login` | LoginPage | Admin login (email/password) |
| `/` | DashboardPage | Overview analytics, quick stats |
| `/plants` | PlantsPage | Plant list/grid with search, filter, sort |
| `/plants/new` | PlantFormPage | Create new plant |
| `/plants/:id/edit` | PlantFormPage | Edit existing plant |
| `/plants/:id` | PlantDetailPage | View plant details (preview) |
| `/users` | UsersPage | User list with search, filter |
| `/users/:id` | UserDetailPage | User profile, collection, bans |
| `/achievements` | AchievementsPage | Achievement definitions list |
| `/achievements/new` | AchievementFormPage | Create achievement |
| `/achievements/:id/edit` | AchievementFormPage | Edit achievement |
| `/review/unverified` | UnverifiedReviewPage | Review queue: unverified plants |
| `/review/flagged` | FlaggedReviewPage | Review queue: flagged photos |
| `/settings` | SettingsPage | Admin account, preferences |

---

## 2. Page-by-Page Spec

### 2.1 Login Page

```
┌──────────────────────────────────────────┐
│                                          │
│            🍃 UrPlant Admin              │
│            ────────────────              │
│                                          │
│  ┌────────────────────────────────────┐  │
│  │  Email                             │  │
│  │  ┌──────────────────────────────┐  │  │
│  │  │ admin@urplant.com            │  │  │
│  │  └──────────────────────────────┘  │  │
│  │                                    │  │
│  │  Password                          │  │
│  │  ┌──────────────────────────────┐  │  │
│  │  │ ●●●●●●●●●●          👁       │  │  │
│  │  └──────────────────────────────┘  │  │
│  │                                    │  │
│  │  [      Sign In       ]           │  │  ← Green button, full-width
│  │                                    │  │
│  │  Forgot password?                 │  │
│  └────────────────────────────────────┘  │
│                                          │
└──────────────────────────────────────────┘
```

- Green brand colors consistent with mobile app
- Error states: "Invalid credentials", "Not an admin account" (if user lacks admin claim)
- Redirect to Dashboard on success

### 2.2 Layout Shell (Authenticated)

```
┌──────────────────────────────────────────────────────────┐
│ 🍃 UrPlant Admin           🔔  Admin Dara  👤 ▾  │ ← Top bar
├──────────┬───────────────────────────────────────────────┤
│ Sidebar  │                                               │
│          │                                               │
│ 📊 Dash │           Page Content                         │
│ 🌿 Plants│                                               │
│ 👥 Users │                                               │
│ 🏆 Achiev│                                               │
│ 📋 Review│                                               │
│   ├─ 🌱 U│                                               │
│   └─ 🚩 F│                                               │
│ ⚙️ Setting│                                               │
│          │                                               │
│          │                                               │
├──────────┴───────────────────────────────────────────────┤
│ v1.0.0  ·  UrPlant Admin  ·  © 2026                      │ ← Footer
└──────────────────────────────────────────────────────────┘
```

**Sidebar navigation**:
- Collapsible on mobile (hamburger menu)
- Active item highlighted with green left border
- Badge counts on Review items (pending count)

### 2.3 Dashboard Page

```
┌──────────────────────────────────────────────────────────┐
│ Dashboard                                                 │
├──────────────────────────────────────────────────────────┤
│ ┌─────────┐ ┌─────────┐ ┌─────────┐ ┌───────────────┐  │
│ │ 👤      │ │ 📸      │ │ 🌿      │ │ ⚠️            │  │  ← Stat cards
│ │  1,234  │ │  5,678  │ │   892   │ │   12          │  │
│ │  Users  │ │  Scans  │ │ Plants  │ │ Pending       │  │
│ └─────────┘ └─────────┘ └─────────┘ └───────────────┘  │
│                                                          │
│ ┌─────────────────────────┐ ┌─────────────────────────┐  │
│ │ 📈 Scans per Day (30d)  │ │ 🥧 Plant Distribution   │  │  ← Charts
│ │   (Recharts line)       │ │   (Recharts pie)        │  │
│ │                         │ │   Normal: 70%           │  │
│ │   ╱╲  ╱╲               │ │   Rare: 25%             │  │
│ │  ╱  ╲╱  ╲╱╲            │ │   Special: 5%           │  │
│ │ ╱            ╲          │ │                         │  │
│ └─────────────────────────┘ └─────────────────────────┘  │
│                                                          │
│ ┌────────────────────────────────────────────────────┐   │
│ │ 🔥 Most Popular Plants                             │   │  ← Table
│ │ ┌───────────────┬─────────┬──────────┬──────────┐  │   │
│ │ │ Plant         │ Rarity  │ Unlocks  │ Scans    │  │   │
│ │ ├───────────────┼─────────┼──────────┼──────────┤  │   │
│ │ │ Aloe Vera     │ Normal  │    156   │   423    │  │   │
│ │ │ Bougainvillea │ Normal  │    142   │   389    │  │   │
│ │ │ Orchid        │ Rare    │     89   │   201    │  │   │
│ │ │ Lotus         │ Special │     45   │   112    │  │   │
│ │ │ Mango Tree    │ Normal  │     38   │    95    │  │   │
│ │ └───────────────┴─────────┴──────────┴──────────┘  │   │
│ └────────────────────────────────────────────────────┘   │
│                                                          │
│ ┌──────────────────────┐ ┌────────────────────────────┐  │
│ │ 🆕 Recent Activity   │ │ 📋 Quick Actions           │  │
│ │ • New user: Rithy    │ │ [+ Add Plant]              │  │
│ │ • Scan: Aloe Vera    │ │ [Review Unverified (3)]    │  │
│ │ • Unlock: Lotus (SR) │ │ [Review Flagged (2)]       │  │
│ │ • Flagged photo #45  │ │ [Export Data]              │  │
│ └──────────────────────┘ └────────────────────────────┘  │
└──────────────────────────────────────────────────────────┘
```

### 2.4 Plants Page

```
┌──────────────────────────────────────────────────────────┐
│ 🌿 Plants                            [+ Add Plant]       │
├──────────────────────────────────────────────────────────┤
│ 🔍 Search plants...     [All ▾] [Normal] [Rare] [Special]│  ← Search + rarity filter
│ Sort: [A-Z ▾]                              Total: 892    │
├──────────────────────────────────────────────────────────┤
│ ┌─────────────────────────┐ ┌─────────────────────────┐  │
│ │ 🖼️                     │ │ 🖼️                     │  │  ← Grid cards
│ │                         │ │                         │  │
│ │ Aloe Vera        ★     │ │ Rafflesia       ✦✦    │  │
│ │ Aloe vera              │ │ Rafflesia arnoldii     │  │
│ │ យក្ខព្រឹក្ស              │ │ រហ្វ្លេស៊ី               │  │
│ │                         │ │                         │  │
│ │ Family: Asphodelaceae  │ │ Family: Rafflesiaceae  │  │
│ │ Unlocks: 156           │ │ Unlocks: 3             │  │
│ │ Verified: ✅           │ │ Verified: ✅           │  │
│ │ [Edit] [Delete]        │ │ [Edit] [Delete]        │  │
│ └─────────────────────────┘ └─────────────────────────┘  │
│                                                          │
│ ┌─────────────────────────┐ ┌─────────────────────────┐  │
│ │ 🖼️                     │ │ ⚠️                      │  │
│ │                         │ │  Unverified             │  │
│ │ Mango Tree      ★      │ │                         │  │
│ │ Mangifera indica       │ │ Unknown Plant #47       │  │
│ │ ស្វាយ                    │ │                         │  │
│ │                         │ │ Confidence: 78%        │  │
│ │ Family: Anacardiaceae  │ │ Found by: 2 users      │  │
│ │ Unlocks: 38            │ │ [Review →]              │  │
│ │ Verified: ✅           │ │                         │  │
│ │ [Edit] [Delete]        │ └─────────────────────────┘  │
│ └─────────────────────────┘                              │
│                                                          │
│  ← 1  2  3  4  ...  45  →                               │  ← Pagination
└──────────────────────────────────────────────────────────┘
```

**Actions on each card**:
- **Edit**: Opens PlantFormPage in edit mode (pre-filled)
- **Delete**: Confirmation dialog → soft delete or hard delete
- **Review** (unverified): Opens UnverifiedReviewPage

### 2.5 Plant Form Page (Create/Edit)

```
┌──────────────────────────────────────────────────────────┐
│ ← Back    {New Plant / Edit: Aloe Vera}     [Save] [Cancel]│
├──────────────────────────────────────────────────────────┤
│ ┌─ Basic Info ──────────────────────────────────────┐    │
│ │ English Name:   [Aloe Vera                  ]      │    │
│ │ Khmer Name:     [យក្ខព្រឹក្ស                   ]      │    │
│ │ Scientific Name:[Aloe vera                  ]      │    │
│ │                                                   │    │
│ │ Rarity:  [Normal ▾]  (Normal / Rare / Special Rare)│    │
│ │ Verified:[✅ Verified]  📸 Reference Image:       │    │
│ │ Plant.id ID:[789012               ] (optional)     │    │
│ └───────────────────────────────────────────────────┘    │
│                                                          │
│ ┌─ Taxonomy ────────────────────────────────────────┐    │
│ │ Kingdom:  [Plantae                         ]      │    │
│ │ Family:   [Asphodelaceae                   ]      │    │
│ │ Genus:    [Aloe                            ]      │    │
│ │ Species:  [vera                            ]      │    │
│ └───────────────────────────────────────────────────┘    │
│                                                          │
│ ┌─ Content (English) ───────────────────────────────┐    │
│ │ Description:                                       │    │
│ │ ┌──────────────────────────────────────────────┐  │    │
│ │ │ Aloe vera is a succulent plant species...    │  │    │
│ │ │                                              │  │    │
│ │ └──────────────────────────────────────────────┘  │    │
│ │ Origin:       [Arabian Peninsula            ]     │    │
│ │                                                   │    │
│ │ Care Guide:                                       │    │
│ │ Water:       [Low - water every 2-3 weeks  ]     │    │
│ │ Sunlight:    [Bright indirect light         ]     │    │
│ │ Soil:        [Well-draining cactus mix      ]     │    │
│ │ Temperature: [13-27°C                       ]     │    │
│ │ Humidity:    [Low to moderate               ]     │    │
│ │                                                   │    │
│ │ Fun Facts (one per line):                         │    │
│ │ ┌──────────────────────────────────────────────┐  │    │
│ │ │ Aloe vera gel is 99% water                  │  │    │
│ │ │ Used medicinally for over 6,000 years        │  │    │
│ │ │ Can flower with tall yellow spikes          │  │    │
│ │ │ [+ Add Fact]                                │  │    │
│ │ └──────────────────────────────────────────────┘  │    │
│ └───────────────────────────────────────────────────┘    │
│                                                          │
│ ┌─ Content (Khmer) ────────────────────────────────┐    │
│ │ [🤖 Translate from English]  ← Calls self-hosted AI│    │
│ │                                                   │    │
│ │ Description:                                       │    │
│ │ ┌──────────────────────────────────────────────┐  │    │
│ │ │ យក្ខព្រឹក្សគឺជារុក្ខជាតិទឹកដម...                │  │    │
│ │ └──────────────────────────────────────────────┘  │    │
│ │ ... (same fields as English)                     │    │
│ └───────────────────────────────────────────────────┘    │
│                                                          │
│ ┌─ Reference Images ───────────────────────────────┐    │
│ │ [Upload Image]  Max 5 images, recommended 800x600 │    │
│ │ ┌───┐ ┌───┐ ┌───┐                                │    │
│ │ │ 🖼️│ │ 🖼️│ │ 📤│                                │    │
│ │ │   │ │   │ │Add│                                │    │
│ │ └───┘ └───┘ └───┘                                │    │
│ └───────────────────────────────────────────────────┘    │
│                                                          │
│ [Save Draft]  [Save & Publish]  [Cancel]                 │
└──────────────────────────────────────────────────────────┘
```

**Features**:
- "Translate from English" button auto-fills KH fields via self-hosted AI
- Rarity preview: shows badge color/icon based on selection
- Image upload with drag-and-drop, auto-compress to WebP
- Auto-resize reference images to 800x600
- Validation: English name + scientific name required
- Duplicate scientific name check (warns if exists)

### 2.6 Users Page

```
┌──────────────────────────────────────────────────────────┐
│ 👥 Users                                    🔍 Search... │
├──────────────────────────────────────────────────────────┤
│ Filter: [All ▾] [Free] [Trial] [Premium]  [Banned]      │
│ Sort: [Recently Active ▾]                                │
├──────────────────────────────────────────────────────────┤
│ ┌────────────────────────────────────────────────────┐   │
│ │ 👤 │ Name   │ Email          │ Lang │ Plants │ Last Active │ Actions │
│ ├────┼────────┼────────────────┼──────┼────────┼─────────────┼─────────┤
│ │ 🟢 │ Rithy  │ rithy@...      │ KH   │    8   │ 2 mins ago  │ 👁️ 🚫  │
│ │ 🟡 │ Sophea │ sophea@...     │ EN   │   25   │ 1 hour ago  │ 👁️ 🚫  │
│ │ 🟢 │ John   │ john@...       │ EN   │   12   │ 5 hours ago │ 👁️ 🚫  │
│ │ 🔴 │ Spam   │ spam@...       │ EN   │    0   │ 3 days ago  │ 👁️ ✅  │
│ └────────────────────────────────────────────────────┘   │
│                                                          │
│  ← 1  2  3  ...  62  →                                 │
└──────────────────────────────────────────────────────────┘
```

- 🟢 Active today, 🟡 Active this week, 🔴 Inactive
- 👁️ View user detail
- 🚫 Ban user (with reason dialog)
- ✅ Unban user

### 2.7 User Detail Page

```
┌──────────────────────────────────────────────────────────┐
│ ← Users    User: Rithy                                   │
├──────────────────────────────────────────────────────────┤
│ ┌─── Profile ───────────────────────────────────────┐    │
│ │ 👤 Rithy                                [Ban User] │    │
│ │ rithy@example.com    Language: KH                 │    │
│ │ Level 3 · Plant Scout · 750/1000 XP              │    │
│ │ Joined: Aug 1, 2026    Last Active: 2 mins ago    │    │
│ │ Tier: Free    Daily Scans: 3/5                   │    │
│ └──────────────────────────────────────────────────┘    │
│                                                          │
│ ┌─── Stats ─────────────────────────────────────────┐    │
│ │ Total Scans: 15    Plants Unlocked: 8              │    │
│ │ Normal: 5    Rare: 2    Special Rare: 1            │    │
│ │ Achievements: 3                                    │    │
│ └──────────────────────────────────────────────────┘    │
│                                                          │
│ ┌─── Collection ────────────────────────────────────┐    │
│ │ 🌵 Aloe Vera (Rare) · Aug 6, 2026 · 3 sightings    │    │
│ │ 🌻 Sunflower (Normal) · Aug 5, 2026 · 1 sighting   │    │
│ │ 🌴 Palm Tree (Normal) · Aug 4, 2026 · 2 sightings  │    │
│ │ ... (7 more)                                       │    │
│ └──────────────────────────────────────────────────┘    │
│                                                          │
│ ┌─── Achievements ──────────────────────────────────┐    │
│ │ 🏅 First Discovery · Earned Aug 6                  │    │
│ │ 🌱 Budding Collector · Earned Aug 6                │    │
│ │ 🔥 Getting Started · In Progress (2/3 days)        │    │
│ └──────────────────────────────────────────────────┘    │
│                                                          │
│ ┌─── Recent Scans ──────────────────────────────────┐    │
│ │ 📸 Aloe Vera · Confidence 95% · Aug 6, 10:30 AM    │    │
│ │ 📸 Unknown · Confidence 42% · Aug 6, 10:15 AM      │    │
│ │ 📸 Sunflower · Confidence 88% · Aug 5, 3:00 PM     │    │
│ │ ... (View All)                                     │    │
│ └──────────────────────────────────────────────────┘    │
│                                                          │
│ [Ban User]  [Delete Account (GDPR)]                     │
└──────────────────────────────────────────────────────────┘
```

### 2.8 Achievements Page

```
┌──────────────────────────────────────────────────────────┐
│ 🏆 Achievements                    [+ New Achievement]   │
├──────────────────────────────────────────────────────────┤
│ Category: [All ▾] [Collection] [Rarity] [Exploration] [Streak]│
├──────────────────────────────────────────────────────────┤
│ ┌─────────────────────────────────────────────────────┐  │
│ │ 🏅 │ First Discovery │ plants_unlocked: 1 │ 50 XP │  │  ← Table view
│ │    │ Unlock 1 plant  │ Collection         │ [Edit]│  │
│ ├────┼─────────────────┼────────────────────┼───────┤  │
│ │ 🌱 │ Budding Collect │ plants_unlocked: 5 │100 XP │  │
│ │    │ Unlock 5 plants │ Collection         │ [Edit]│  │
│ ├────┼─────────────────┼────────────────────┼───────┤  │
│ │ 💎 │ Rare Hunter     │ rarity_count: 5    │250 XP │  │
│ │    │ Unlock 5 Rare   │ Rarity             │ [Edit]│  │
│ ├────┼─────────────────┼────────────────────┼───────┤  │
│ │ 🔥 │ Weekly Explorer │ streak_days: 7     │150 XP │  │
│ │    │ 7-day streak    │ Streak             │ [Edit]│  │
│ └─────────────────────────────────────────────────────┘  │
│                                                          │
│ Total: 26 achievements                                   │
└──────────────────────────────────────────────────────────┘
```

### 2.9 Achievement Form Page

```
┌──────────────────────────────────────────────────────────┐
│ ← Back    {New / Edit} Achievement          [Save]       │
├──────────────────────────────────────────────────────────┤
│ ID (slug):        [first_plant                  ]        │
│ English Name:     [First Discovery              ]        │
│ Khmer Name:       [ការរកឃើញដំបូង               ]        │
│ English Desc:     [Unlock your first plant     ]        │
│ Khmer Desc:       [ដោះសោរុក្ខជាតិដំបូង        ]        │
│                                                          │
│ Category:         [Collection ▾]                         │
│ Requirement Type: [plants_unlocked ▾]                    │
│ Requirement Value:[1                          ]          │
│ XP Reward:        [50                         ]          │
│ Sort Order:       [1                          ]          │
│                                                          │
│ ☐ Hidden Achievement (requirement shown as "???")        │
│                                                          │
│ Badge Icon:                                              │
│ [Upload SVG]  Recommended 96x96px                        │
│ ┌────┐                                                   │
│ │ 🏅│  Preview                                           │
│ └────┘                                                   │
│                                                          │
│ [Save] [Cancel]                                          │
└──────────────────────────────────────────────────────────┘
```

### 2.10 Review: Unverified Plants

```
┌──────────────────────────────────────────────────────────┐
│ 📋 Review → Unverified Plants         12 pending          │
├──────────────────────────────────────────────────────────┤
│ ┌────────────────────────────────────────────────────┐   │
│ │ 🌱 Unknown Plant #47                               │   │
│ │ ────────────────────────────────────────────────   │   │
│ │ Plant.id: Mangifera indica (Confidence: 78%)       │   │
│ │ Common names: Mango, Indian mango                  │   │
│ │ Taxonomy: Anacardiaceae family                     │   │
│ │                                                    │   │
│ │ Found by: 2 users                                  │   │
│ │ User Photos:                                       │   │
│ │ ┌─────┐ ┌─────┐                                   │   │
│ │ │ 📸1 │ │ 📸2 │                                   │   │
│ │ └─────┘ └─────┘                                   │   │
│ │                                                    │   │
│ │ Action:                                            │   │
│ │ ┌─ Approve ────────────────────────────────────┐  │   │
│ │ │ Quick: [✓ Mango Tree] (auto-fill from Plant.id)│  │   │
│ │ │ or [Create Full Plant Entry →]                │  │   │
│ │ └──────────────────────────────────────────────┘  │   │
│ │ ┌─ Reject ─────────────────────────────────────┐  │   │
│ │ │ [✗ Not a plant]  [✗ Duplicate]  [✗ Low qual]  │  │   │
│ │ └──────────────────────────────────────────────┘  │   │
│ └────────────────────────────────────────────────────┘   │
│                                                          │
│ ┌────────────────────────────────────────────────────┐   │
│ │ 🌿 Unknown Plant #48                               │   │
│ │ ... (similar layout)                               │   │
│ └────────────────────────────────────────────────────┘   │
│                                                          │
│  ← 1  2  →                                              │
└──────────────────────────────────────────────────────────┘
```

### 2.11 Review: Flagged Photos

```
┌──────────────────────────────────────────────────────────┐
│ 📋 Review → Flagged Photos               5 pending        │
├──────────────────────────────────────────────────────────┤
│ ┌────────────────────────────────────────────────────┐   │
│ │ 🚩 Flag #45                                        │   │
│ │ ────────────────────────────────────────────────   │   │
│ │ User: Rithy (user_abc123)                          │   │
│ │ Date: Aug 6, 2026, 10:30 AM                        │   │
│ │ Flags: no_exif, screenshot_resolution              │   │
│ │                                                    │   │
│ │ ┌────────────────────┐                             │   │
│ │ │                    │                             │   │
│ │ │    [User Photo]    │                             │   │
│ │ │                    │                             │   │
│ │ └────────────────────┘                             │   │
│ │                                                    │   │
│ │ EXIF: Make: n/a, Model: n/a, 1080x2400             │   │
│ │ Plant Result: Aloe Vera (95%)                      │   │
│ │                                                    │   │
│ │ [✓ Clear Flag]  [✗ Confirm Spoof]                 │   │
│ └────────────────────────────────────────────────────┘   │
└──────────────────────────────────────────────────────────┘
```

---

## 3. Component Architecture

### 3.1 Component Tree

```
App
├── AuthProvider (context)
├── QueryClientProvider (TanStack)
├── Router
│   ├── LoginPage
│   ├── AdminLayout
│   │   ├── Sidebar
│   │   ├── TopBar
│   │   ├── DashboardPage
│   │   │   ├── StatCard (×4)
│   │   │   ├── ScansChart (Recharts Line)
│   │   │   ├── DistributionChart (Recharts Pie)
│   │   │   ├── PopularPlantsTable
│   │   │   └── RecentActivityList
│   │   ├── PlantsPage
│   │   │   ├── SearchBar
│   │   │   ├── RarityFilterChips
│   │   │   ├── PlantCard (×N)
│   │   │   └── Pagination
│   │   ├── PlantFormPage
│   │   │   ├── BasicInfoSection
│   │   │   ├── TaxonomySection
│   │   │   ├── ContentSection (EN/KH tabs)
│   │   │   ├── ImageUploader
│   │   │   └── TranslateButton
│   │   ├── UsersPage
│   │   │   └── UsersTable
│   │   ├── UserDetailPage
│   │   ├── AchievementsPage
│   │   │   └── AchievementsTable
│   │   ├── AchievementFormPage
│   │   ├── UnverifiedReviewPage
│   │   │   └── UnverifiedCard (×N)
│   │   ├── FlaggedReviewPage
│   │   │   └── FlaggedCard (×N)
│   │   └── SettingsPage
│   └── NotFoundPage
```

### 3.2 Shared Components

| Component | Props | Usage |
|-----------|-------|-------|
| `SearchBar` | `value`, `onChange`, `placeholder` | Search across pages |
| `RarityBadge` | `rarity: 'normal'\|'rare'\|'special_rare'`, `size` | Consistent rarity display |
| `Pagination` | `page`, `totalPages`, `onPageChange` | Table/grid pagination |
| `ConfirmDialog` | `title`, `message`, `onConfirm`, `onCancel` | Delete/ban confirmations |
| `EmptyState` | `icon`, `title`, `description`, `action?` | Empty tables/lists |
| `LoadingSpinner` | `size` | Loading states |
| `ImageUploader` | `images`, `onAdd`, `onRemove`, `max` | Image management |
| `PlantCard` | `plant: Plant`, `onEdit`, `onDelete` | Plant grid item |
| `StatCard` | `icon`, `label`, `value`, `change?` | Dashboard stats |

---

## 4. API Integration

### 4.1 API Client (services/adminApi.ts)

```typescript
import axios from 'axios';
import { getAuth } from 'firebase/auth';

const API_BASE = import.meta.env.VITE_ADMIN_API_URL; 
// e.g., https://us-central1-urplant.cloudfunctions.net/adminApi

const adminApi = axios.create({
  baseURL: API_BASE,
  headers: { 'Content-Type': 'application/json' },
});

// Auto-attach Firebase ID token
adminApi.interceptors.request.use(async (config) => {
  const auth = getAuth();
  const user = auth.currentUser;
  if (user) {
    const token = await user.getIdToken();
    config.headers.Authorization = `Bearer ${token}`;
  }
  return config;
});

export async function adminRequest(action: string, payload: any = {}) {
  const response = await adminApi.post('/', { action, payload });
  return response.data;
}

// Typed API functions
export const plantsApi = {
  list: (params: PlantListParams) => adminRequest('listPlants', params),
  get: (plantId: string) => adminRequest('getPlant', { plant_id: plantId }),
  create: (data: PlantInput) => adminRequest('createPlant', data),
  update: (plantId: string, data: Partial<PlantInput>) => 
    adminRequest('updatePlant', { plant_id: plantId, ...data }),
  delete: (plantId: string) => adminRequest('deletePlant', { plant_id: plantId }),
};

// ... similar for usersApi, achievementsApi, reviewApi, analyticsApi
```

### 4.2 TanStack Query Hooks

```typescript
// hooks/usePlants.ts
export function usePlants(params: PlantListParams) {
  return useQuery({
    queryKey: ['plants', params],
    queryFn: () => plantsApi.list(params),
    staleTime: 5 * 60 * 1000, // 5 min cache
  });
}

export function useCreatePlant() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: plantsApi.create,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ['plants'] });
      toast.success('Plant created!');
    },
    onError: (error) => {
      toast.error('Failed to create plant');
    },
  });
}
```

---

## 5. Auth & Security

### 5.1 Admin Claim Setup (Firebase CLI / Cloud Function)

```bash
# Via Firebase CLI
firebase functions:shell
> admin.auth().setCustomUserClaims('admin_uid_xyz', { admin: true });
```

### 5.2 Auth Provider

```typescript
// providers/AuthProvider.tsx
function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [isAdmin, setIsAdmin] = useState(false);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    const auth = getAuth();
    const unsubscribe = onAuthStateChanged(auth, async (firebaseUser) => {
      if (firebaseUser) {
        const token = await firebaseUser.getIdTokenResult();
        const isAdmin = token.claims.admin === true;
        
        if (!isAdmin) {
          await auth.signOut();
          setUser(null);
          setIsAdmin(false);
        } else {
          setUser(firebaseUser);
          setIsAdmin(true);
        }
      } else {
        setUser(null);
        setIsAdmin(false);
      }
      setLoading(false);
    });
    return unsubscribe;
  }, []);

  if (loading) return <LoadingSpinner />;
  
  return (
    <AuthContext.Provider value={{ user, isAdmin }}>
      {children}
    </AuthContext.Provider>
  );
}
```

---

## 6. Deployment

### 6.1 Firebase Hosting Config

```json
// firebase.json (admin section)
{
  "hosting": {
    "public": "admin/dist",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css|svg|png|webp|woff2)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "public, max-age=31536000, immutable"
          }
        ]
      }
    ]
  }
}
```

### 6.2 Build & Deploy

```bash
cd admin
npm run build        # Vite builds to admin/dist/
firebase deploy --only hosting
```

---

## 7. Future Enhancements (Post-MVP)

- Bulk import plants via CSV/JSON upload
- Image moderation AI (auto-detect inappropriate photos)
- Multi-admin roles (super admin, content editor, reviewer)
- Activity audit log (which admin changed what)
- Email notifications for new unverified plants
- Export user data (GDPR compliance)
- Dark mode for admin portal
- Rich text editor for plant descriptions (Markdown support)
- Plant data version history / rollback