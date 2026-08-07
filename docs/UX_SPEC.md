# UrPlant — UX/UI Specification

> **Version**: 1.0.0 · **Last Updated**: 2026-08-06
>
> Complete screen-by-screen UX/UI specification: wireframe descriptions, animations, colors, typography, component behaviors, and interaction patterns.

---

## 1. Design System

### 1.1 Color Palette

```dart
class UrPlantColors {
  // Primary
  static const primary = Color(0xFF1B5E20);        // Deep forest green
  static const primaryLight = Color(0xFF4CAF50);    // Fresh leaf green
  static const primaryDark = Color(0xFF0D3B0F);     // Dark green for text
  
  // Rarity
  static const rarityNormal = Color(0xFF4CAF50);    // Green
  static const rarityRare = Color(0xFF2196F3);      // Blue
  static const raritySpecialRare = Color(0xFFFFD700); // Gold
  static const raritySpecialRareDark = Color(0xFFB8860B); // Dark gold (text)
  
  // Background
  static const background = Color(0xFFFAF3E3);      // Warm cream
  static const surface = Color(0xFFFFFFFF);          // White cards
  static const surfaceDark = Color(0xFF1E1E1E);      // Dark mode surface (future)
  
  // Text
  static const textPrimary = Color(0xFF212121);      // Near black
  static const textSecondary = Color(0xFF757575);    // Gray
  static const textOnPrimary = Color(0xFFFFFFFF);    // White on green
  
  // Semantic
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE53935);
  static const warning = Color(0xFFFFA726);
  static const info = Color(0xFF29B6F6);
  
  // Card backgrounds by rarity
  static const cardNormal = Color(0xFFE8F5E9);       // Light green
  static const cardRare = Color(0xFFE3F2FD);          // Light blue
  static const cardSpecialRare = Color(0xFFFFF8E1);   // Light gold
  static const cardLocked = Color(0xFFEEEEEE);        // Gray
}
```

### 1.2 Typography

| Role | English | Khmer |
|------|---------|-------|
| **Display** (plant name) | Poppins Bold, 24sp | Noto Sans Khmer Bold, 22sp |
| **Heading** (screen titles) | Poppins SemiBold, 20sp | Noto Sans Khmer Bold, 18sp |
| **Subheading** (section titles) | Poppins Medium, 16sp | Noto Sans Khmer, 16sp |
| **Body** (descriptions) | Open Sans Regular, 14sp | Noto Sans Khmer Regular, 14sp |
| **Caption** (metadata) | Open Sans Regular, 12sp | Noto Sans Khmer Regular, 12sp |
| **Scientific Name** | Open Sans Italic, 14sp | (not italic in KH) |
| **Button** | Poppins SemiBold, 16sp | Noto Sans Khmer Bold, 15sp |

### 1.3 Spacing & Layout

```dart
// 8dp grid system
static const spacing_xs = 4.0;
static const spacing_sm = 8.0;
static const spacing_md = 16.0;
static const spacing_lg = 24.0;
static const spacing_xl = 32.0;
static const spacing_2xl = 48.0;

// Border radius
static const radius_sm = 8.0;
static const radius_md = 12.0;
static const radius_lg = 16.0;
static const radius_xl = 24.0;
static const radius_full = 999.0;     // Pills, buttons
```

### 1.4 Shadows & Elevation

```dart
// Card shadow
BoxShadow(
  color: Colors.black.withOpacity(0.08),
  blurRadius: 12,
  offset: Offset(0, 4),
)

// Elevated card (unlock celebration)
BoxShadow(
  color: rarityColor.withOpacity(0.3),
  blurRadius: 20,
  offset: Offset(0, 8),
)
```

---

## 2. Screen-by-Screen Spec

### 2.1 Splash Screen

**Duration**: 2 seconds
**Content**:
- Centered UrPlant logo (leaf icon in green gradient, 120x120dp)
- App name "UrPlant" in Poppins Bold 28sp, deep green
- Tagline: "Discover the world around you" (EN) / "ស្វែងយល់ពីពិភពលោកជុំវិញអ្នក" (KH)
- Pulsing fade-in animation (logo + text, 800ms ease-out)
- Bottom: subtle loading dots

**Transition**: Fade to onboarding or home (if already authenticated)

---

### 2.2 Onboarding (3 Slides)

**Purpose**: First-launch only. Introduce core concept.

#### Slide 1: Discover
- Illustration: Person pointing phone camera at a flower
- Title: "Discover Plants" / "ស្វែងរករុក្ខជាតិ"
- Body: "Point your camera at any plant and UrPlant will identify it instantly."
- Page indicator: 3 dots (active: green, inactive: gray)

#### Slide 2: Identify
- Illustration: App UI showing plant card with "Aloe Vera" result
- Title: "Learn Everything" / "រៀនអ្វីៗទាំងអស់"
- Body: "Get detailed info, origin stories, care guides, and fun facts — in English or Khmer."

#### Slide 3: Collect
- Illustration: Trophy cabinet with plant badges of different rarities
- Title: "Build Your Collection" / "បង្កើតការប្រមូលរបស់អ្នក"
- Body: "Unlock rare and special plants. Earn achievements. Become a plant master!"
- CTA Button: "Get Started" / "ចាប់ផ្តើម" (filled green, full-width, 56dp height)

**Navigation**: Swipe left/right + "Skip" text button (top-right) + "Next" button on slides 1-2
**On Skip/Finish**: Navigate to Language Picker → Auth

---

### 2.3 Language Picker

**Trigger**: After onboarding (first launch) or from Settings
**Layout**:
- Title: "Choose Language" / "ជ្រើសរើសភាសា"
- Two large cards (160dp height):
  - 🇬🇧 English card: "English" with sample text "Discover, identify, collect"
  - 🇰🇭 Khmer card: "ភាសាខ្មែរ" with sample text "ស្វែងរក កំណត់អត្តសញ្ញាណ ប្រមូល"
- Selected card: green border (2dp) + light green bg
- Unselected: gray border + white bg
- Confirm button: "Continue" / "បន្ត"

**Behavior**: Sets locale in Riverpod provider + SharedPreferences. Updates entire app instantly.

---

### 2.4 Auth Screen

**Layout**:
- Top: UrPlant logo (small, 80dp)
- Center: Illustration of person with plants
- Sign-up form (collapsed by default, expands on tap):
  - Email field
  - Password field (min 8 chars, show/hide toggle)
  - Display name field
  - "Create Account" button (green, full-width)
  - "Already have an account? Log in" link
- Social buttons:
  - "Continue with Google" (white, Google logo, 1dp border)
  - "Continue with Apple" (black, Apple logo — iOS only)
- Divider: "or" / "ឬ"
- "Try as Guest" link (small text, secondary color)

**States**: Loading spinner on button during auth, error snackbar for failures

---

### 2.5 Home Screen (Main Tab)

**Layout**: Scrollable feed of user's activity + quick actions.

```
┌──────────────────────────────┐
│  🔔  UrPlant          👤  ⚙️ │  ← App bar (transparent bg)
├──────────────────────────────┤
│  ┌──────────────────────┐    │
│  │  🌿  Ready to scan?  │    │  ← Hero card (green gradient)
│  │  Tap camera to       │    │
│  │  identify any plant  │    │
│  │  [📷 Open Camera]    │    │  ← CTA button
│  └──────────────────────┘    │
├──────────────────────────────┤
│  Your Collection    View All→│
│  ┌─────┐ ┌─────┐ ┌─────┐   │
│  │🌵   │ │🌻   │ │🌴   │   │  ← Horizontal scroll of recent unlocks
│  │Cact │ │Sunfl│ │Palm │   │     (3-5 cards, 100x140dp)
│  │  ★  │ │  ✦  │ │  ✦✦ │   │     Rarity badge bottom-right
│  └─────┘ └─────┘ └─────┘   │
├──────────────────────────────┤
│  Recent Activity             │
│  ┌────────────────────────┐  │
│  │ ✨ You unlocked Aloe   │  │  ← Activity card
│  │    Vera (Rare)   2m ago│  │     Green left border
│  └────────────────────────┘  │
│  ┌────────────────────────┐  │
│  │ 📷 Scanned a plant    │  │
│  │    +50 XP         1h ago│  │
│  └────────────────────────┘  │
├──────────────────────────────┤
│  Achievements               │
│  🏆 First Discovery ✓      │
│  🏆 Collector (5/10) ▓▓▓▓▓░│  ← Progress bar
└──────────────────────────────┘
```

**Behaviors**:
- Pull-to-refresh
- Tap recent activity → plant detail
- Tap "Open Camera" → camera screen
- Tap collection card → plant detail

---

### 2.6 Camera Screen (Full-Screen)

**This is the most critical screen. No gallery access. In-app camera only.**

```
┌──────────────────────────────┐
│ ⬅ Back          ⚡Flash  🔄 │  ← Top bar (semi-transparent overlay)
│                              │
│                              │
│       ╭─────────────╮       │
│       │             │       │  ← Viewfinder frame (leaf silhouette corners)
│       │   🌿        │       │     Subtle white border, rounded corners
│       │             │       │     Animated breathing (gentle scale pulse, 3s cycle)
│       │             │       │
│       ╰─────────────╯       │
│                              │
│     "Frame the plant"        │  ← Hint text (fades after 3s)
│     "ដាក់ស៊ុមរុក្ខជាតិ"       │
│                              │
│                              │
│           ┌────┐             │
│           │ ●  │             │  ← Capture button (outer ring: white, inner: white)
│           └────┘             │     72dp diameter, animated press (scale down to 0.9)
│                              │     Bottom-center
└──────────────────────────────┘
```

**Features**:
- **Tap to focus**: Yellow focus ring animation at tap point. Auto-focus on frame center.
- **Pinch to zoom**: Smooth digital zoom (0.5x - 3x). Zoom indicator appears while zooming.
- **Flash toggle**: 🔄 cycles: Auto → On → Off → Auto. Icon updates.
- **Viewfinder overlay**: Subtle plant silhouette corners (like taking a photo of a leaf). Non-intrusive.
- **Capture button**: Circular, 72dp. Outer ring 3dp white stroke, inner circle white fill with 20% opacity. Animated press (scale 1.0 → 0.9 → 1.0, 200ms ease-out). Haptic feedback on press.
- **Back button**: Top-left, white with shadow. Returns to previous screen.
- **Permission denied state**: Show rationale dialog → settings link. Dark overlay with message.

**Post-Capture**:
- Image freezes for 200ms (capture feedback)
- Slide transition to "Review Photo" screen (bottom sheet style, but full-screen for better UX)
- Photo shown with "Retake" (left) and "Use Photo" (right) buttons
- "Use Photo" → transitions to Identifying screen

---

### 2.7 Identifying Screen (Loading)

**Purpose**: Keep user engaged during the ~5-8s Plant.id API call.

```
┌──────────────────────────────┐
│                              │
│       [User's photo]         │  ← Small blurred version of captured image as background
│                              │     (blur radius: 20, opacity: 30%)
│                              │
│         ┌──────┐            │
│         │  🌿  │            │  ← Animated leaf icon (Lottie)
│         │  💫  │            │     Pulses + sparkles orbiting
│         └──────┘            │     120dp, centered
│                              │
│     "Identifying..."         │  ← Title text, 20sp
│     "កំពុងកំណត់អត្តសញ្ញាណ..."  │
│                              │
│  ┌────────────────────────┐ │
│  │ 🔍 Analyzing image...  │ │  ← Progress steps (animated, sequential)
│  │ 🌐 Matching database...│ │     Each step fades in as previous completes
│  │ 📚 Gathering info...   │ │     Checkmark appears on completion
│  └────────────────────────┘ │
│                              │
│  Did you know?              │  ← Random plant facts carousel (auto-rotate every 3s)
│  " Bamboo can grow up to   │
│    91cm in a single day! "  │
└──────────────────────────────┘
```

**Lottie Animation**: Leaf with pulsing glow + orbiting sparkles. Loop during loading.
**Progress Steps**: Show sequentially every 1.5-2s. Creates illusion of progress.
**Fun Facts**: Pulled from a local cache of plant facts. Changes every 3s.

**Edge Cases**:
- Timeout (15s): show "Taking longer than expected..." + retry option
- Network error: show "Connection lost" with retry button

---

### 2.8 Result Screen (Post-Identification)

**Layout depends on result type: New Unlock, Duplicate, Low Confidence, Unmatched.**

#### 2.8.1 New Unlock (Celebration!)

**Animation Sequence** (total ~3s):
1. **0-0.5s**: Screen transitions from Identifying with a bright flash
2. **0.5-1.5s**: Plant card slides up from bottom with spring animation (bouncy)
3. **0.5-2.0s**: Confetti cannon: 
   - Normal rarity: gentle green confetti (20 pieces, downward)
   - Rare rarity: blue confetti burst (50 pieces, spread)
   - Special Rare: full-screen gold confetti (100 pieces) + screen edge glow pulse
4. **1.0-1.5s**: Rarity badge scales up from 0 (elastic ease-out, overshoot)
5. **1.5-2.0s**: "Unlocked!" text banner slides in from top
6. **2.0-3.0s**: Badge settles, confetti fades, plant info becomes scrollable
7. Haptic feedback: light for Normal, medium for Rare, heavy double-tap for Special Rare

**Screen Layout** (after celebration):

```
┌──────────────────────────────┐
│ ← Back to Home               │
├──────────────────────────────┤
│  ┌────────────────────────┐  │
│  │                        │  │
│  │   [User's Photo]       │  │  ← Hero image (full-width, 280dp height)
│  │                   [✦]  │  │     Rarity badge top-right (48dp, with glow)
│  │                        │  │
│  └────────────────────────┘  │
│                              │
│  ✨ New Plant Unlocked! ✨   │  ← Animated banner (green gradient, sliding)
│                              │
│  Aloe Vera            ✦ Rare│  ← Name + rarity pill
│  Aloe vera                  │  ← Scientific name (italic)
│  យក្ខព្រឹក្ស                  │  ← KH name
│                              │
│  +100 XP  🏆 First Discovery│  ← XP earned + achievements badge
│                              │
│  ┌────────────────────────┐  │
│  │ 📋 Plant Details   ▼   │  │  ← Expandable sections
│  │  ...description...     │  │
│  └────────────────────────┘  │
│  ┌────────────────────────┐  │
│  │ 🗺️ Origin          ▼   │  │
│  │  Arabian Peninsula    │  │
│  └────────────────────────┘  │
│  ┌────────────────────────┐  │
│  │ 🌱 Care Guide      ▼   │  │
│  │  💧 Water: Low        │  │
│  │  ☀️ Sun: Bright       │  │
│  │  🪴 Soil: Cactus mix  │  │
│  │  🌡️ Temp: 13-27°C     │  │
│  │  💨 Humidity: Low     │  │
│  └────────────────────────┘  │
│  ┌────────────────────────┐  │
│  │ 💡 Fun Facts       ▼   │  │
│  │  • 99% water          │  │
│  │  • Used for 6000 yrs  │  │
│  └────────────────────────┘  │
│                              │
│  ┌────────────────────────┐  │
│  │ [View in Encyclopedia] │  │  ← Outline button
│  └────────────────────────┘  │
│  ┌────────────────────────┐  │
│  │ [📷 Scan Another Plant]│  │  ← Filled green button
│  └────────────────────────┘  │
└──────────────────────────────┘
```

#### 2.8.2 Duplicate Identification

**Layout**: Same as New Unlock but:
- Banner: "Already in your collection!" / "មានក្នុងការប្រមូលរបស់អ្នករួចហើយ!" (blue banner instead of green)
- Shows: "+50 XP" badge
- "Sightings: 3" updated counter
- No confetti
- Haptic: light tap

#### 2.8.3 Low Confidence

**Layout**: Minimal result screen.
```
┌──────────────────────────────┐
│      ┌────────────┐         │
│      │    😕      │         │  ← Sad leaf illustration
│      └────────────┘         │
│                              │
│  Couldn't Identify           │
│  មិនអាចកំណត់អត្តសញ្ញាណបានទេ    │
│                              │
│  Tips:                       │
│  • Get closer to the plant   │
│  • Make sure there's good    │
│    lighting                  │
│  • Focus on leaves or flowers│
│  • Avoid blurry photos       │
│                              │
│  [📷 Try Again]              │  ← Primary button
│  [🏠 Go Home]                │  ← Text button
└──────────────────────────────┘
```

#### 2.8.4 Unmatched (Not in Database)

Similar to low confidence but:
- Illustration: Magnifying glass with plant
- Message: "Plant found but not in our database yet. We'll review it!"
- "We'll notify you when it's added"
- [+10 XP] for the attempt
- Buttons: [Scan Another] [Go Home]

---

### 2.9 Plant Detail Screen

**Accessed from**: Encyclopedia, Home Recent Activity, Result screen, Collection view

**Layout**: Identical to the scrollable portion of the Result screen (2.8.1), with additional:
- Top app bar: Back button + Share (iOS: share sheet, Android: share intent) + Bookmark (future)
- Language toggle chip at top-right: "EN" / "KH" — tap to switch all content language
- Discovery info section at bottom:
  - "Discovered: Aug 6, 2026"
  - "Location: Phnom Penh" (if location granted)
  - "Sightings: 3"

**For locked plants** (viewed from encyclopedia):
- Hero image replaced with dark silhouette (opacity 10%) + large "?" in center
- Content sections hidden, replaced with: "Find this plant in the wild to unlock its secrets"
- No care guide, no origin, no fun facts visible
- Only taxonomy section visible (scientific family/order info)

---

### 2.10 Encyclopedia Screen

**Tab**: Part of bottom navigation (second tab)

```
┌──────────────────────────────┐
│ 🔍 Search plants...      🔄  │  ← Search bar (sticky top)
├──────────────────────────────┤
│ [All] [Normal] [Rare] [✦SR] │  ← Rarity filter chips (horizontal scroll)
├──────────────────────────────┤
│  Collection: 8/50 unlocked   │  ← Progress indicator
│  ▓▓▓▓▓▓▓▓▓░░░░░░░░░░  16%   │  ← Green progress bar
├──────────────────────────────┤
│  ┌──────┐ ┌──────┐ ┌──────┐ │
│  │🌵    │ │🌻    │ │🌴?   │ │  ← 2-column grid
│  │Cactus│ │Sunfl │ │Locked│ │     Card: 160x200dp
│  │  ★   │ │  ✦✦ │ │  🔒  │ │     Unlocked: photo, name, rarity badge
│  └──────┘ └──────┘ └──────┘ │     Locked: dark silhouette, "?", hint text
│  ┌──────┐ ┌──────┐ ┌──────┐ │
│  │🌺    │ │🌿?   │ │🌸    │ │
│  │Hibis │ │Locked│ │Cherry│ │
│  │  ✦   │ │  🔒  │ │  ★   │ │
│  └──────┘ └──────┘ └──────┘ │
│                              │
│  (infinite scroll, paginated)│
└──────────────────────────────┘
```

**Card States**:
- **Unlocked card**: User's captured photo as background (cover), plant name EN bottom-left, KH name bottom-left small, rarity badge top-right (colored circle with "★", "✦", or "✦✦")
- **Locked card**: Dark gray background (#BDBDBD), plant silhouette icon in center (opacity 30%), "?" watermark, "Find to unlock" / "ស្វែងរកដើម្បីដោះសោ" hint at bottom
- **Tap**: Navigate to Plant Detail screen

**Search**: Real-time filter (debounced 300ms). Searches `search_keywords` array (EN + KH names). Shows "No results" illustration if empty.

**Sort** (top-right icon): Bottom sheet with options:
- A-Z (English)
- ក-អ (A-Z Khmer)
- Rarity (Special Rare → Rare → Normal)
- Recently Unlocked
- Recently Added

---

### 2.11 Profile Screen

**Tab**: Part of bottom navigation (third tab)

```
┌──────────────────────────────┐
│  ⚙️ Settings                 │  ← Settings gear icon top-right
├──────────────────────────────┤
│       ┌──────────┐          │
│       │  Avatar  │          │  ← Circular avatar (80dp)
│       │  (photo) │          │     Tap to change / Google photo
│       └──────────┘          │
│      Rithy                  │  ← Display name
│      Level 3 • Plant Scout  │  ← Level + title
│  ▓▓▓▓▓▓▓▓▓▓▓░░░░░  750/1000│  ← XP progress bar to next level
├──────────────────────────────┤
│  ┌──────────┬──────────────┐ │
│  │   Total  │   Plants     │ │  ← Stats grid (2x2)
│  │  Scans   │  Unlocked    │ │     Each stat: icon + number + label
│  │   15     │    8         │ │     Background: light green
│  ├──────────┼──────────────┤ │
│  │   Rare   │  Achievements│ │
│  │  Plants  │   Earned     │ │
│  │    3     │    3         │ │
│  └──────────┴──────────────┘ │
├──────────────────────────────┤
│  🏆 Achievements      View All│
│  ┌────┐ ┌────┐ ┌────┐ ┌───┐ │
│  │🏅  │ │🌟  │ │🔒  │ │🔒 │ │  ← Horizontal scroll
│  │1st │ │10  │ │25  │ │7d │ │     Earned: colored + icon
│  │Plant│ │Plants│ │Plants│ │Stk│     Locked: gray + lock icon
│  └────┘ └────┘ └────┘ └───┘ │
├──────────────────────────────┤
│  📋 Account                  │
│  > Language: ភាសាខ្មែរ          │  ← Tap to open language picker
│  > Notification Preferences  │
│  > Privacy Policy            │
│  > Terms of Service          │
│  > Delete Account            │  ← Red text, confirmation dialog
├──────────────────────────────┤
│  [Log Out]                   │  ← Text button, red
└──────────────────────────────┘
```

---

### 2.12 Achievements Screen (Full Wall)

**Accessed from**: Profile → "View All" on achievements row

```
┌──────────────────────────────┐
│ ← Profile    Achievements    │
├──────────────────────────────┤
│ [All] [Earned] [Locked]     │  ← Filter tabs
├──────────────────────────────┤
│  🌟 Collection               │  ← Category headers
│  ┌──────────────────────┐    │
│  │ 🏅 First Discovery ✓ │    │  ← Earned: green left border
│  │   Unlock your first  │    │     Checkmark + earned date
│  │   plant  +50 XP      │    │
│  │   Earned Aug 6, 2026 │    │
│  └──────────────────────┘    │
│  ┌──────────────────────┐    │
│  │ 🌿 Plant Collector   │    │  ← In-progress: blue left border
│  │   5/10 plants        │    │     Progress bar
│  │   ▓▓▓▓▓▓▓▓▓░░░░  50%│    │
│  └──────────────────────┘    │
│  ┌──────────────────────┐    │
│  │ 🔒 Master Collector │    │  ← Locked: gray, no progress shown
│  │   Unlock 50 plants   │    │     (unless is_hidden=false)
│  │   ???                │    │
│  └──────────────────────┘    │
│                              │
│  💎 Rarity Hunters           │
│  ┌──────────────────────┐    │
│  │ 🔒 Rare Hunter       │    │
│  │   Unlock 5 rare      │    │
│  │   plants             │    │
│  └──────────────────────┘    │
│                              │
│  🎯 Special                  │
│  ┌──────────────────────┐    │
│  │ 🔒 Lucky Find        │    │
│  │   ???                │    │  ← Hidden achievement
│  │   ???                │    │
│  └──────────────────────┘    │
└──────────────────────────────┘
```

---

### 2.13 Bottom Navigation Bar

**3 Tabs** (Material 3 NavigationBar):

| Tab | Icon | Label EN | Label KH |
|-----|------|----------|----------|
| Home | 🏠 (house) | Home | ទំព័រដើម |
| Encyclopedia | 📚 (book) | Encyclopedia | សព្វវចនាធិប្បាយ |
| Profile | 👤 (person) | Profile | ប្រវត្តិរូប |

**Active**: Icon + label in primary green, subtle scale animation (1.0 → 1.1)
**Inactive**: Gray icon, no label (Material 3 style)
**Center FAB**: Camera icon (📷) elevated above nav bar (60dp, green gradient, drop shadow). Tapping opens Camera screen. **This is the primary CTA.**

```
         [🏠]    [📷]    [👤]
                 ↑
          Elevated FAB (primary action)
```

---

## 3. Animation Specifications

### 3.1 Transitions

| Transition | Animation | Duration | Easing |
|-----------|-----------|----------|--------|
| Screen push | Slide left + fade | 300ms | easeOutCubic |
| Screen pop | Slide right + fade | 300ms | easeInCubic |
| Bottom sheet | Slide up | 250ms | easeOutBack |
| Modal/dialog | Scale up + fade | 200ms | easeOutCubic |
| Tab switch | Cross-fade | 200ms | easeInOut |

### 3.2 Micro-interactions

| Interaction | Animation | Details |
|------------|-----------|---------|
| Button press | Scale 1.0 → 0.95 → 1.05 → 1.0 | 200ms, spring |
| Card tap | Scale + slight lift shadow | 150ms |
| List item ripple | Material ripple (ink spread) | Default |
| Like/favorite | Heart scale 0→1.3→1.0 + color fill | 300ms |
| Achievement earn | Badge scale 0→1.3→1.0 + glow + confetti | 500ms |
| Switch toggle | Smooth thumb slide + color transition | 200ms |
| Pull-to-refresh | Material indicator (spinning green circle) | Default |

### 3.3 Celebration Animations (Rarity-Specific)

| Rarity | Confetti Count | Colors | Duration | Sound | Haptic |
|--------|---------------|--------|----------|-------|--------|
| **Normal** | 20 pieces | Green, white | 1.5s | Soft chime | Light |
| **Rare** | 50 pieces | Blue, silver, white | 2.5s | Sparkle jingle | Medium |
| **Special Rare** | 100 pieces | Gold, purple, diamond | 4.0s | Fanfare chord | Heavy double |

---

## 4. Empty & Error States

### Empty Encyclopedia
```
┌──────────────────────────────┐
│                              │
│        🌱 (large icon)       │
│                              │
│   Your collection is empty   │
│   Start exploring! Take a    │
│   photo of a plant to begin  │
│   your collection.           │
│                              │
│      [📷 Open Camera]        │
└──────────────────────────────┘
```

### Network Error (Any Screen)
- Persistent top banner: "No internet connection" / "គ្មានការភ្ជាប់អ៊ីនធឺណិត" (red)
- Retry button on banner
- Offline-available content still accessible (cached plants)

### General Error
- Full-screen illustration: leaf with bandage
- Message: "Something went wrong"
- [Try Again] button
- [Go Home] text link

---

## 5. Accessibility Guidelines

- All touch targets ≥ 48x48dp
- Contrast ratio ≥ 4.5:1 for body text, ≥ 3:1 for large text
- Screen reader labels on all interactive elements (Semantics widget in Flutter)
- Khmer text: minimum 14sp for body, proper line height (1.5x)
- Camera screen: voice guidance "Point camera at plant and tap the center button to capture"
- Haptic feedback for: capture, unlock, achievement earn, error
- Respect system font scaling (up to 1.5x)