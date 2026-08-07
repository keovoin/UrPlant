# UrPlant — Localization Strategy (English & Khmer)

> **Version**: 1.0.0 · **Last Updated**: 2026-08-06
>
> Complete specification for bilingual (EN/KH) support using Flutter ARB files, font setup, dynamic AI-powered KH translation, and locale-aware UI patterns.

---

## 1. Architecture

### 1.1 Overview

UrPlant uses Flutter's built-in `flutter_localizations` + ARB (Application Resource Bundle) for UI strings, and Firestore for per-plant bilingual content (names, descriptions, care guides, etc.).

```
┌──────────────────────────────────────────────┐
│              LOCALIZATION SOURCES              │
├──────────────────────────────────────────────┤
│  ARB Files (static UI strings)               │
│  ├── app_en.arb        ← English (primary)   │
│  └── app_kh.arb        ← Khmer translations  │
├──────────────────────────────────────────────┤
│  Firestore (per-plant content)                │
│  ├── name_en / name_kh                       │
│  ├── description_en / description_kh         │
│  ├── care_en / care_kh                       │
│  ├── fun_facts_en[] / fun_facts_kh[]         │
│  └── origin_en / origin_kh                  │
├──────────────────────────────────────────────┤
│  Self-Hosted AI (dynamic translation)        │
│  └── enriches + translates new/unverified    │
│      plant data into KH                     │
└──────────────────────────────────────────────┘
```

### 1.2 Language Toggle

- **First launch**: Language picker screen (see UX spec §2.3)
- **Settings**: Always accessible in Profile → Language
- **Instant switch**: Language change updates all UI instantly via Riverpod locale provider + ARB reload
- **Persisted**: Stored in `users/{uid}.language` (Firestore) + `SharedPreferences` (local cache)
- **Guest mode**: Stored in `SharedPreferences` only

---

## 2. ARB File Structure

### 2.1 File Locations

```
mobile/lib/l10n/
├── app_en.arb          ← English (source of truth)
└── app_kh.arb          ← Khmer translations
```

### 2.2 app_en.arb (English - Complete)

```json
{
  "@@locale": "en",
  "@@last_modified": "2026-08-06",
  
  "app_name": "UrPlant",
  "app_tagline": "Discover the world around you",
  
  "onboarding_title_1": "Discover Plants",
  "onboarding_body_1": "Point your camera at any plant and UrPlant will identify it instantly.",
  "onboarding_title_2": "Learn Everything",
  "onboarding_body_2": "Get detailed info, origin stories, care guides, and fun facts — in English or Khmer.",
  "onboarding_title_3": "Build Your Collection",
  "onboarding_body_3": "Unlock rare and special plants. Earn achievements. Become a plant master!",
  "onboarding_skip": "Skip",
  "onboarding_next": "Next",
  "onboarding_get_started": "Get Started",
  
  "language_title": "Choose Language",
  "language_english": "English",
  "language_khmer": "ភាសាខ្មែរ",
  "language_continue": "Continue",
  
  "auth_sign_up": "Create Account",
  "auth_sign_in": "Log In",
  "auth_email": "Email",
  "auth_password": "Password",
  "auth_display_name": "Display Name",
  "auth_continue_google": "Continue with Google",
  "auth_continue_apple": "Continue with Apple",
  "auth_guest": "Try as Guest",
  "auth_already_have_account": "Already have an account? Log in",
  "auth_no_account": "Don't have an account? Sign up",
  "auth_forgot_password": "Forgot password?",
  "auth_logout": "Log Out",
  
  "home_title": "UrPlant",
  "home_hero_title": "Ready to scan?",
  "home_hero_subtitle": "Tap camera to identify any plant",
  "home_hero_cta": "Open Camera",
  "home_your_collection": "Your Collection",
  "home_view_all": "View All",
  "home_recent_activity": "Recent Activity",
  "home_achievements": "Achievements",
  
  "camera_hint": "Frame the plant",
  "camera_flash_auto": "Flash: Auto",
  "camera_flash_on": "Flash: On",
  "camera_flash_off": "Flash: Off",
  "camera_permission_title": "Camera Permission Required",
  "camera_permission_body": "UrPlant needs camera access to identify plants. No gallery uploads — only real-time photos.",
  "camera_permission_grant": "Grant Permission",
  "camera_review_retake": "Retake",
  "camera_review_use": "Use Photo",
  
  "identifying_title": "Identifying...",
  "identifying_step_analyze": "Analyzing image...",
  "identifying_step_match": "Matching database...",
  "identifying_step_info": "Gathering info...",
  "identifying_fact_title": "Did you know?",
  "identifying_timeout": "Taking longer than expected...",
  "identifying_error": "Connection lost",
  "identifying_retry": "Try Again",
  
  "result_new_unlock": "New Plant Unlocked!",
  "result_duplicate": "Already in your collection!",
  "result_low_confidence_title": "Couldn't Identify",
  "result_low_confidence_tip_1": "Get closer to the plant",
  "result_low_confidence_tip_2": "Make sure there's good lighting",
  "result_low_confidence_tip_3": "Focus on leaves or flowers",
  "result_low_confidence_tip_4": "Avoid blurry photos",
  "result_unmatched_title": "Plant Not in Database",
  "result_unmatched_body": "Plant found but not in our database yet. We'll review it!",
  "result_unmatched_notify": "We'll notify you when it's added",
  "result_xp_earned": "+{xp} XP",
  "result_scan_another": "Scan Another Plant",
  "result_go_home": "Go Home",
  "result_view_encyclopedia": "View in Encyclopedia",
  "result_share": "Share",
  
  "plant_detail_discovered": "Discovered",
  "plant_detail_location": "Location",
  "plant_detail_sightings": "Sightings",
  "plant_detail_locked_hint": "Find this plant in the wild to unlock its secrets",
  "plant_detail_section_details": "Plant Details",
  "plant_detail_section_origin": "Origin",
  "plant_detail_section_care": "Care Guide",
  "plant_detail_section_facts": "Fun Facts",
  "plant_detail_care_water": "Water",
  "plant_detail_care_sunlight": "Sunlight",
  "plant_detail_care_soil": "Soil",
  "plant_detail_care_temperature": "Temperature",
  "plant_detail_care_humidity": "Humidity",
  
  "encyclopedia_title": "Encyclopedia",
  "encyclopedia_search": "Search plants...",
  "encyclopedia_filter_all": "All",
  "encyclopedia_filter_normal": "Normal",
  "encyclopedia_filter_rare": "Rare",
  "encyclopedia_filter_special": "Special Rare",
  "encyclopedia_progress": "{unlocked}/{total} unlocked",
  "encyclopedia_empty_title": "Your collection is empty",
  "encyclopedia_empty_body": "Start exploring! Take a photo of a plant to begin your collection.",
  "encyclopedia_locked_hint": "Find to unlock",
  "encyclopedia_sort_az_en": "A-Z (English)",
  "encyclopedia_sort_az_kh": "ក-អ (Khmer)",
  "encyclopedia_sort_rarity": "Rarity",
  "encyclopedia_sort_recent_unlocked": "Recently Unlocked",
  "encyclopedia_sort_recent_added": "Recently Added",
  "encyclopedia_no_results": "No plants found",
  
  "profile_title": "Profile",
  "profile_level": "Level {level}",
  "profile_xp_progress": "{current}/{next} XP",
  "profile_stat_scans": "Total Scans",
  "profile_stat_unlocked": "Plants Unlocked",
  "profile_stat_rare": "Rare Plants",
  "profile_stat_achievements": "Achievements Earned",
  "profile_achievements_title": "Achievements",
  "profile_achievements_view_all": "View All",
  "profile_settings": "Settings",
  "profile_language": "Language",
  "profile_notifications": "Notification Preferences",
  "profile_privacy": "Privacy Policy",
  "profile_terms": "Terms of Service",
  "profile_delete_account": "Delete Account",
  "profile_delete_confirm": "Are you sure? This cannot be undone.",
  "profile_delete_cancel": "Cancel",
  "profile_delete_confirm_btn": "Delete",
  
  "achievements_title": "Achievements",
  "achievements_filter_all": "All",
  "achievements_filter_earned": "Earned",
  "achievements_filter_locked": "Locked",
  "achievements_category_collection": "Collection",
  "achievements_category_rarity": "Rarity Hunters",
  "achievements_category_exploration": "Exploration",
  "achievements_category_streak": "Streaks",
  "achievements_category_special": "Special",
  "achievements_earned": "Earned {date}",
  "achievements_secret_hint": "Keep exploring to unlock this secret achievement!",
  
  "achievement_first_plant_name": "First Discovery",
  "achievement_first_plant_desc": "Unlock your first plant",
  "achievement_collector_5_name": "Budding Collector",
  "achievement_collector_5_desc": "Unlock 5 plants",
  "achievement_collector_10_name": "Plant Collector",
  "achievement_collector_10_desc": "Unlock 10 plants",
  "achievement_collector_25_name": "Botanical Collector",
  "achievement_collector_25_desc": "Unlock 25 plants",
  "achievement_collector_50_name": "Master Collector",
  "achievement_collector_50_desc": "Unlock 50 plants",
  "achievement_collector_100_name": "Grand Collector",
  "achievement_collector_100_desc": "Unlock 100 plants",
  "achievement_rare_1_name": "Rare Find",
  "achievement_rare_1_desc": "Unlock your first Rare plant",
  "achievement_rare_5_name": "Rare Hunter",
  "achievement_rare_5_desc": "Unlock 5 Rare plants",
  "achievement_rare_10_name": "Rare Collector",
  "achievement_rare_10_desc": "Unlock 10 Rare plants",
  "achievement_special_1_name": "Special Discovery",
  "achievement_special_1_desc": "Unlock your first Special Rare plant",
  "achievement_special_3_name": "Special Hunter",
  "achievement_special_3_desc": "Unlock 3 Special Rare plants",
  "achievement_special_5_name": "Legendary Collector",
  "achievement_special_5_desc": "Unlock 5 Special Rare plants",
  "achievement_scans_10_name": "Curious Observer",
  "achievement_scans_10_desc": "Scan 10 plants total",
  "achievement_scans_50_name": "Active Explorer",
  "achievement_scans_50_desc": "Scan 50 plants total",
  "achievement_scans_100_name": "Dedicated Naturalist",
  "achievement_scans_100_desc": "Scan 100 plants total",
  "achievement_scans_500_name": "Field Researcher",
  "achievement_scans_500_desc": "Scan 500 plants total",
  "achievement_scans_1000_name": "Plant Photographer",
  "achievement_scans_1000_desc": "Scan 1000 plants total",
  "achievement_streak_3_name": "Getting Started",
  "achievement_streak_3_desc": "3-day scan streak",
  "achievement_streak_7_name": "Weekly Explorer",
  "achievement_streak_7_desc": "7-day scan streak",
  "achievement_streak_14_name": "Fortnight Botanist",
  "achievement_streak_14_desc": "14-day scan streak",
  "achievement_streak_30_name": "Monthly Master",
  "achievement_streak_30_desc": "30-day scan streak",
  "achievement_streak_60_name": "Dedicated Discoverer",
  "achievement_streak_60_desc": "60-day scan streak",
  "achievement_streak_100_name": "Unstoppable",
  "achievement_streak_100_desc": "100-day scan streak",
  "achievement_all_three_rarities_name": "Trifecta",
  "achievement_all_three_rarities_desc": "Unlock 1 Normal, 1 Rare, and 1 Special Rare plant",
  "achievement_khmer_treasure_name": "Khmer Treasure",
  "achievement_khmer_treasure_desc": "Unlock 10 plants native to Cambodia",
  
  "rarity_normal": "Normal",
  "rarity_rare": "Rare",
  "rarity_special_rare": "Special Rare",
  
  "level_title_1": "Seedling",
  "level_title_2": "Plant Scout",
  "level_title_3": "Botanist",
  "level_title_4": "Plant Master",
  "level_title_5": "Green Thumb",
  "level_title_6": "Plant Legend",
  
  "error_network_title": "No internet connection",
  "error_network_retry": "Retry",
  "error_general_title": "Something went wrong",
  "error_general_body": "Please try again",
  "error_general_retry": "Try Again",
  "error_daily_limit": "You've reached your daily scan limit ({used}/{limit}). Upgrade to Premium for unlimited scans.",
  
  "common_cancel": "Cancel",
  "common_confirm": "Confirm",
  "common_ok": "OK",
  "common_close": "Close",
  "common_save": "Save",
  "common_delete": "Delete",
  "common_edit": "Edit",
  "common_loading": "Loading...",
  "common_yes": "Yes",
  "common_no": "No"
}
```

### 2.3 app_kh.arb (Khmer — Key Strings)

```json
{
  "@@locale": "kh",
  "@@last_modified": "2026-08-06",
  
  "app_name": "UrPlant",
  "app_tagline": "ស្វែងយល់ពីពិភពលោកជុំវិញអ្នក",
  
  "onboarding_title_1": "ស្វែងរករុក្ខជាតិ",
  "onboarding_body_1": "ចង្អុលកាមេរ៉ារបស់អ្នកទៅកាន់រុក្ខជាតិណាមួយ ហើយ UrPlant នឹងកំណត់អត្តសញ្ញាណវាភ្លាមៗ។",
  "onboarding_title_2": "រៀនអ្វីៗទាំងអស់",
  "onboarding_body_2": "ទទួលបានព័ត៌មានលម្អិត រឿងរ៉ាវប្រភពដើម ការណែនាំថែទាំ និងការពិតគួរឱ្យចាប់អារម្មណ៍ — ជាភាសាអង់គ្លេស ឬភាសាខ្មែរ។",
  "onboarding_title_3": "បង្កើតការប្រមូលរបស់អ្នក",
  "onboarding_body_3": "ដោះសោរុក្ខជាតិកម្រ និងពិសេស។ ទទួលបានសមិទ្ធផល។ ក្លាយជាម្ចាស់រុក្ខជាតិ!",
  "onboarding_skip": "រំលង",
  "onboarding_next": "បន្ទាប់",
  "onboarding_get_started": "ចាប់ផ្តើម",
  
  "language_title": "ជ្រើសរើសភាសា",
  "language_english": "English",
  "language_khmer": "ភាសាខ្មែរ",
  "language_continue": "បន្ត",
  
  "auth_sign_up": "បង្កើតគណនី",
  "auth_sign_in": "ចូល",
  "auth_email": "អ៊ីមែល",
  "auth_password": "ពាក្យសម្ងាត់",
  "auth_display_name": "ឈ្មោះបង្ហាញ",
  "auth_continue_google": "បន្តជាមួយ Google",
  "auth_continue_apple": "បន្តជាមួយ Apple",
  "auth_guest": "សាកល្បងជាភ្ញៀវ",
  "auth_already_have_account": "មានគណនីរួចហើយ? ចូល",
  "auth_no_account": "មិនទាន់មានគណនី? ចុះឈ្មោះ",
  "auth_forgot_password": "ភ្លេចពាក្យសម្ងាត់?",
  "auth_logout": "ចាកចេញ",
  
  "home_title": "UrPlant",
  "home_hero_title": "ត្រៀមស្កេនហើយឬនៅ?",
  "home_hero_subtitle": "ចុចកាមេរ៉ាដើម្បីកំណត់អត្តសញ្ញាណរុក្ខជាតិ",
  "home_hero_cta": "បើកកាមេរ៉ា",
  "home_your_collection": "ការប្រមូលរបស់អ្នក",
  "home_view_all": "មើលទាំងអស់",
  "home_recent_activity": "សកម្មភាពថ្មីៗ",
  "home_achievements": "សមិទ្ធផល",
  
  "camera_hint": "ដាក់ស៊ុមរុក្ខជាតិ",
  "camera_permission_title": "ត្រូវការការអនុញ្ញាតកាមេរ៉ា",
  "camera_permission_body": "UrPlant ត្រូវការចូលប្រើកាមេរ៉ាដើម្បីកំណត់អត្តសញ្ញាណរុក្ខជាតិ។ មិនមានការផ្ទុកឡើងពីវិចិត្រសាល — មានតែរូបថតពេលវេលាពិតប៉ុណ្ណោះ។",
  "camera_permission_grant": "ផ្តល់ការអនុញ្ញាត",
  "camera_review_retake": "ថតឡើងវិញ",
  "camera_review_use": "ប្រើរូបថត",
  
  "identifying_title": "កំពុងកំណត់អត្តសញ្ញាណ...",
  "identifying_step_analyze": "កំពុងវិភាគរូបភាព...",
  "identifying_step_match": "កំពុងផ្គូផ្គងមូលដ្ឋានទិន្នន័យ...",
  "identifying_step_info": "កំពុងប្រមូលព័ត៌មាន...",
  "identifying_fact_title": "តើអ្នកដឹងទេ?",
  "identifying_timeout": "ចំណាយពេលយូរជាងការរំពឹងទុក...",
  "identifying_error": "បាត់ការតភ្ជាប់",
  "identifying_retry": "ព្យាយាមម្តងទៀត",
  
  "result_new_unlock": "រុក្ខជាតិថ្មីបានដោះសោ!",
  "result_duplicate": "មានក្នុងការប្រមូលរបស់អ្នករួចហើយ!",
  "result_low_confidence_title": "មិនអាចកំណត់អត្តសញ្ញាណបានទេ",
  "result_low_confidence_tip_1": "ចូលទៅជិតរុក្ខជាតិ",
  "result_low_confidence_tip_2": "ត្រូវប្រាកដថាមានពន្លឺគ្រប់គ្រាន់",
  "result_low_confidence_tip_3": "ផ្តោតលើស្លឹកឬផ្កា",
  "result_low_confidence_tip_4": "ជៀសវាងរូបថតព្រិលៗ",
  "result_unmatched_title": "រុក្ខជាតិមិនមានក្នុងមូលដ្ឋានទិន្នន័យ",
  "result_unmatched_body": "រកឃើញរុក្ខជាតិ ប៉ុន្តែមិនទាន់មានក្នុងមូលដ្ឋានទិន្នន័យរបស់យើងទេ។ យើងនឹងពិនិត្យឡើងវិញ!",
  "result_unmatched_notify": "យើងនឹងជូនដំណឹងដល់អ្នកនៅពេលវាត្រូវបានបន្ថែម",
  "result_xp_earned": "+{xp} XP",
  "result_scan_another": "ស្កេនរុក្ខជាតិផ្សេងទៀត",
  "result_go_home": "ទៅទំព័រដើម",
  "result_view_encyclopedia": "មើលក្នុងសព្វវចនាធិប្បាយ",
  
  "plant_detail_discovered": "បានរកឃើញ",
  "plant_detail_location": "ទីតាំង",
  "plant_detail_sightings": "ការមើលឃើញ",
  "plant_detail_locked_hint": "ស្វែងរករុក្ខជាតិនេះនៅក្នុងធម្មជាតិដើម្បីដោះសោអាថ៌កំបាំងរបស់វា",
  "plant_detail_section_details": "ព័ត៌មានលម្អិតរុក្ខជាតិ",
  "plant_detail_section_origin": "ប្រភពដើម",
  "plant_detail_section_care": "ការណែនាំថែទាំ",
  "plant_detail_section_facts": "ការពិតគួរឱ្យចាប់អារម្មណ៍",
  "plant_detail_care_water": "ទឹក",
  "plant_detail_care_sunlight": "ពន្លឺព្រះអាទិត្យ",
  "plant_detail_care_soil": "ដី",
  "plant_detail_care_temperature": "សីតុណ្ហភាព",
  "plant_detail_care_humidity": "សំណើម",
  
  "encyclopedia_title": "សព្វវចនាធិប្បាយ",
  "encyclopedia_search": "ស្វែងរករុក្ខជាតិ...",
  "encyclopedia_filter_all": "ទាំងអស់",
  "encyclopedia_filter_normal": "ធម្មតា",
  "encyclopedia_filter_rare": "កម្រ",
  "encyclopedia_filter_special": "កម្រពិសេស",
  "encyclopedia_progress": "បានដោះសោ {unlocked}/{total}",
  "encyclopedia_empty_title": "ការប្រមូលរបស់អ្នកទទេ",
  "encyclopedia_empty_body": "ចាប់ផ្តើមរុករក! ថតរូបរុក្ខជាតិដើម្បីចាប់ផ្តើមការប្រមូលរបស់អ្នក។",
  "encyclopedia_locked_hint": "ស្វែងរកដើម្បីដោះសោ",
  
  "profile_title": "ប្រវត្តិរូប",
  "profile_level": "កម្រិត {level}",
  "profile_xp_progress": "{current}/{next} XP",
  "profile_stat_scans": "ការស្កេនសរុប",
  "profile_stat_unlocked": "រុក្ខជាតិដែលបានដោះសោ",
  "profile_stat_rare": "រុក្ខជាតិកម្រ",
  "profile_stat_achievements": "សមិទ្ធផលដែលទទួលបាន",
  "profile_achievements_title": "សមិទ្ធផល",
  "profile_achievements_view_all": "មើលទាំងអស់",
  "profile_settings": "ការកំណត់",
  "profile_language": "ភាសា",
  "profile_notifications": "ចំណូលចិត្តការជូនដំណឹង",
  "profile_privacy": "គោលការណ៍ឯកជនភាព",
  "profile_terms": "លក្ខខណ្ឌសេវាកម្ម",
  "profile_delete_account": "លុបគណនី",
  "profile_delete_confirm": "តើអ្នកប្រាកដទេ? សកម្មភាពនេះមិនអាចត្រឡប់វិញបានទេ។",
  "profile_delete_cancel": "បោះបង់",
  "profile_delete_confirm_btn": "លុប",
  
  "rarity_normal": "ធម្មតា",
  "rarity_rare": "កម្រ",
  "rarity_special_rare": "កម្រពិសេស",
  
  "level_title_1": "កូនសំណាប",
  "level_title_2": "អ្នករុករករុក្ខជាតិ",
  "level_title_3": "អ្នករុក្ខសាស្ត្រ",
  "level_title_4": "ម្ចាស់រុក្ខជាតិ",
  "level_title_5": "មេដៃបៃតង",
  "level_title_6": "រឿងព្រេងរុក្ខជាតិ",
  
  "error_network_title": "គ្មានការភ្ជាប់អ៊ីនធឺណិត",
  "error_network_retry": "ព្យាយាមម្តងទៀត",
  "error_general_title": "មានអ្វីមួយខុសប្រក្រតី",
  "error_general_body": "សូមព្យាយាមម្តងទៀត",
  "error_general_retry": "ព្យាយាមម្តងទៀត",
  "error_daily_limit": "អ្នកបានឈានដល់ដែនកំណត់ស្កេនប្រចាំថ្ងៃ ({used}/{limit})។ ដំឡើងទៅ Premium សម្រាប់ការស្កេនគ្មានដែនកំណត់។",
  
  "common_cancel": "បោះបង់",
  "common_confirm": "បញ្ជាក់",
  "common_ok": "យល់ព្រម",
  "common_close": "បិទ",
  "common_save": "រក្សាទុក",
  "common_delete": "លុប",
  "common_edit": "កែសម្រួល",
  "common_loading": "កំពុងផ្ទុក...",
  "common_yes": "បាទ/ចាស",
  "common_no": "ទេ"
}
```

---

## 3. Flutter Implementation

### 3.1 pubspec.yaml Configuration

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  intl: ^0.19.0

flutter:
  generate: true  # Enable code generation for ARB
  
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

### 3.2 App Configuration (main.dart)

```dart
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

MaterialApp(
  title: 'UrPlant',
  localizationsDelegates: const [
    AppLocalizations.delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
  ],
  supportedLocales: const [
    Locale('en'),
    Locale('kh'),
  ],
  locale: localeProvider.locale, // From Riverpod
  theme: theme,
  home: const AppShell(),
);
```

### 3.3 Locale Provider (Riverpod)

```dart
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

class LocaleNotifier extends StateNotifier<Locale> {
  LocaleNotifier() : super(const Locale('en')) {
    _loadSavedLocale();
  }
  
  Future<void> _loadSavedLocale() async {
    final prefs = await SharedPreferences.getInstance();
    final langCode = prefs.getString('language') ?? 'en';
    state = Locale(langCode);
  }
  
  Future<void> setLocale(String languageCode, {String? userId}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', languageCode);
    state = Locale(languageCode);
    
    // Update Firestore if authenticated
    if (userId != null) {
      await FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .update({'language': languageCode});
    }
  }
}
```

### 3.4 Usage Example

```dart
// In widget:
final l10n = AppLocalizations.of(context)!;

Text(l10n.home_hero_title);         // "Ready to scan?" or "ត្រៀមស្កេនហើយឬនៅ?"
Text(l10n.result_xp_earned(100));   // "+100 XP"
Text(l10n.encyclopedia_progress(8, 50)); // "8/50 unlocked" or "បានដោះសោ 8/50"
```

---

## 4. Dynamic KH Translation (Self-Hosted AI)

### 4.1 When Used

The self-hosted AI gateway generates KH translations for:
- New/unverified plants that don't have KH content yet
- User-generated content (future: community plant notes)
- Admin-entered plants where admin filled EN fields but not KH

### 4.2 Translation Prompt

```
Translate the following plant information from English to Khmer (ភាសាខ្មែរ).
Use natural, conversational Khmer. Preserve botanical accuracy.
Maintain the original JSON structure.

English:
{
  "description": "Aloe vera is a succulent plant species...",
  "origin": "Arabian Peninsula",
  "care": { "water": "...", "sunlight": "...", ... },
  "fun_facts": ["...", "...", "..."]
}

Respond with ONLY the JSON, no markdown, no explanation:
```

### 4.3 Quality Assurance

- Admin can review and edit AI-generated KH content via the admin portal
- KH content marked with `ai_translated: true` flag, admin can override
- Users can report poor translations (future feature)

---

## 5. Font Rendering Notes

### 5.1 Khmer Text Challenges
- **Stack height**: Khmer script has stacked consonants + vowel signs. Ensure minimum line height of 1.5x for body text.
- **Zero-width characters**: Some Khmer characters are zero-width. Test on real devices.
- **Noto Sans Khmer**: The official Google font for Khmer. Bundled with the app.
- **Italic for scientific names**: Scientific names use italics in EN. In KH, do NOT italicize (Khmer italic rendering is poor); use bold instead.

### 5.2 Font Fallback Chain
```
English: Poppins → system default
Khmer: Noto Sans Khmer → system Khmer font → Noto Sans (for mixed EN/KH text)
```

---

## 6. Testing Checklist

- [ ] All ARB keys have both EN and KH values
- [ ] No missing translations (flutter analyze shows warnings for missing ARB keys)
- [ ] KH text renders correctly on Android (API 24+) and iOS 15+
- [ ] KH text doesn't overflow containers (test with longest strings)
- [ ] Language switch updates all screens instantly
- [ ] Language persists across app restarts
- [ ] Language synced to Firestore for authenticated users
- [ ] Guest mode remembers language locally
- [ ] Plant content shows correct language based on user preference
- [ ] Language toggle on Plant Detail screen works independently
- [ ] Error messages, snackbars, dialogs all localized
- [ ] Achievement names/descriptions localized
- [ ] Level titles localized
- [ ] Rarity labels localized