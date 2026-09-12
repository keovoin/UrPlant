import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_km.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('km')
  ];

  /// No description provided for @app_name.
  ///
  /// In en, this message translates to:
  /// **'UrPlant'**
  String get app_name;

  /// No description provided for @app_tagline.
  ///
  /// In en, this message translates to:
  /// **'Discover the world around you'**
  String get app_tagline;

  /// No description provided for @onboarding_title_1.
  ///
  /// In en, this message translates to:
  /// **'Discover Plants'**
  String get onboarding_title_1;

  /// No description provided for @onboarding_body_1.
  ///
  /// In en, this message translates to:
  /// **'Point your camera at any plant and UrPlant will identify it instantly.'**
  String get onboarding_body_1;

  /// No description provided for @onboarding_title_2.
  ///
  /// In en, this message translates to:
  /// **'Learn Everything'**
  String get onboarding_title_2;

  /// No description provided for @onboarding_body_2.
  ///
  /// In en, this message translates to:
  /// **'Get detailed info, origin stories, care guides, and fun facts — in English or Khmer.'**
  String get onboarding_body_2;

  /// No description provided for @onboarding_title_3.
  ///
  /// In en, this message translates to:
  /// **'Build Your Collection'**
  String get onboarding_title_3;

  /// No description provided for @onboarding_body_3.
  ///
  /// In en, this message translates to:
  /// **'Unlock rare and special plants. Earn achievements. Become a plant master!'**
  String get onboarding_body_3;

  /// No description provided for @onboarding_skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get onboarding_skip;

  /// No description provided for @onboarding_next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get onboarding_next;

  /// No description provided for @onboarding_get_started.
  ///
  /// In en, this message translates to:
  /// **'Get Started'**
  String get onboarding_get_started;

  /// No description provided for @language_title.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get language_title;

  /// No description provided for @language_english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get language_english;

  /// No description provided for @language_khmer.
  ///
  /// In en, this message translates to:
  /// **'ភាសាខ្មែរ'**
  String get language_khmer;

  /// No description provided for @language_continue.
  ///
  /// In en, this message translates to:
  /// **'Continue'**
  String get language_continue;

  /// No description provided for @auth_sign_up.
  ///
  /// In en, this message translates to:
  /// **'Create Account'**
  String get auth_sign_up;

  /// No description provided for @auth_sign_in.
  ///
  /// In en, this message translates to:
  /// **'Log In'**
  String get auth_sign_in;

  /// No description provided for @auth_email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get auth_email;

  /// No description provided for @auth_password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get auth_password;

  /// No description provided for @auth_display_name.
  ///
  /// In en, this message translates to:
  /// **'Display Name'**
  String get auth_display_name;

  /// No description provided for @auth_continue_google.
  ///
  /// In en, this message translates to:
  /// **'Continue with Google'**
  String get auth_continue_google;

  /// No description provided for @auth_guest.
  ///
  /// In en, this message translates to:
  /// **'Try as Guest'**
  String get auth_guest;

  /// No description provided for @auth_already_have_account.
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Log in'**
  String get auth_already_have_account;

  /// No description provided for @auth_logout.
  ///
  /// In en, this message translates to:
  /// **'Log Out'**
  String get auth_logout;

  /// No description provided for @home_title.
  ///
  /// In en, this message translates to:
  /// **'UrPlant'**
  String get home_title;

  /// No description provided for @home_hero_title.
  ///
  /// In en, this message translates to:
  /// **'Ready to scan?'**
  String get home_hero_title;

  /// No description provided for @home_hero_subtitle.
  ///
  /// In en, this message translates to:
  /// **'Tap camera to identify any plant'**
  String get home_hero_subtitle;

  /// No description provided for @home_hero_cta.
  ///
  /// In en, this message translates to:
  /// **'Open Camera'**
  String get home_hero_cta;

  /// No description provided for @home_your_collection.
  ///
  /// In en, this message translates to:
  /// **'Your Collection'**
  String get home_your_collection;

  /// No description provided for @home_view_all.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get home_view_all;

  /// No description provided for @home_recent_activity.
  ///
  /// In en, this message translates to:
  /// **'Recent Activity'**
  String get home_recent_activity;

  /// No description provided for @home_achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get home_achievements;

  /// No description provided for @camera_hint.
  ///
  /// In en, this message translates to:
  /// **'Frame the plant'**
  String get camera_hint;

  /// No description provided for @camera_review_retake.
  ///
  /// In en, this message translates to:
  /// **'Retake'**
  String get camera_review_retake;

  /// No description provided for @camera_review_use.
  ///
  /// In en, this message translates to:
  /// **'Use Photo'**
  String get camera_review_use;

  /// No description provided for @identifying_title.
  ///
  /// In en, this message translates to:
  /// **'Identifying...'**
  String get identifying_title;

  /// No description provided for @identifying_step_analyze.
  ///
  /// In en, this message translates to:
  /// **'Analyzing image...'**
  String get identifying_step_analyze;

  /// No description provided for @identifying_step_match.
  ///
  /// In en, this message translates to:
  /// **'Matching database...'**
  String get identifying_step_match;

  /// No description provided for @identifying_step_info.
  ///
  /// In en, this message translates to:
  /// **'Gathering info...'**
  String get identifying_step_info;

  /// No description provided for @identifying_fact_title.
  ///
  /// In en, this message translates to:
  /// **'Did you know?'**
  String get identifying_fact_title;

  /// No description provided for @identifying_timeout.
  ///
  /// In en, this message translates to:
  /// **'Taking longer than expected...'**
  String get identifying_timeout;

  /// No description provided for @identifying_error.
  ///
  /// In en, this message translates to:
  /// **'Connection lost'**
  String get identifying_error;

  /// No description provided for @identifying_retry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get identifying_retry;

  /// No description provided for @result_new_unlock.
  ///
  /// In en, this message translates to:
  /// **'New Plant Unlocked!'**
  String get result_new_unlock;

  /// No description provided for @result_duplicate.
  ///
  /// In en, this message translates to:
  /// **'Already in your collection!'**
  String get result_duplicate;

  /// No description provided for @result_low_confidence_title.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t Identify'**
  String get result_low_confidence_title;

  /// No description provided for @result_low_confidence_tip_1.
  ///
  /// In en, this message translates to:
  /// **'Get closer to the plant'**
  String get result_low_confidence_tip_1;

  /// No description provided for @result_low_confidence_tip_2.
  ///
  /// In en, this message translates to:
  /// **'Make sure there\'s good lighting'**
  String get result_low_confidence_tip_2;

  /// No description provided for @result_low_confidence_tip_3.
  ///
  /// In en, this message translates to:
  /// **'Focus on leaves or flowers'**
  String get result_low_confidence_tip_3;

  /// No description provided for @result_low_confidence_tip_4.
  ///
  /// In en, this message translates to:
  /// **'Avoid blurry photos'**
  String get result_low_confidence_tip_4;

  /// No description provided for @result_unmatched_title.
  ///
  /// In en, this message translates to:
  /// **'Plant Not in Database'**
  String get result_unmatched_title;

  /// No description provided for @result_unmatched_body.
  ///
  /// In en, this message translates to:
  /// **'Plant found but not in our database yet. We\'ll review it!'**
  String get result_unmatched_body;

  /// No description provided for @result_xp_earned.
  ///
  /// In en, this message translates to:
  /// **'+{xp} XP'**
  String result_xp_earned(Object xp);

  /// No description provided for @result_scan_another.
  ///
  /// In en, this message translates to:
  /// **'Scan Another Plant'**
  String get result_scan_another;

  /// No description provided for @result_go_home.
  ///
  /// In en, this message translates to:
  /// **'Go Home'**
  String get result_go_home;

  /// No description provided for @plant_detail_discovered.
  ///
  /// In en, this message translates to:
  /// **'Discovered'**
  String get plant_detail_discovered;

  /// No description provided for @plant_detail_sightings.
  ///
  /// In en, this message translates to:
  /// **'Sightings'**
  String get plant_detail_sightings;

  /// No description provided for @plant_detail_locked_hint.
  ///
  /// In en, this message translates to:
  /// **'Find this plant in the wild to unlock its secrets'**
  String get plant_detail_locked_hint;

  /// No description provided for @plant_detail_section_details.
  ///
  /// In en, this message translates to:
  /// **'Plant Details'**
  String get plant_detail_section_details;

  /// No description provided for @plant_detail_section_origin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get plant_detail_section_origin;

  /// No description provided for @plant_detail_section_care.
  ///
  /// In en, this message translates to:
  /// **'Care Guide'**
  String get plant_detail_section_care;

  /// No description provided for @plant_detail_section_facts.
  ///
  /// In en, this message translates to:
  /// **'Fun Facts'**
  String get plant_detail_section_facts;

  /// No description provided for @plant_detail_care_water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get plant_detail_care_water;

  /// No description provided for @plant_detail_care_sunlight.
  ///
  /// In en, this message translates to:
  /// **'Sunlight'**
  String get plant_detail_care_sunlight;

  /// No description provided for @plant_detail_care_soil.
  ///
  /// In en, this message translates to:
  /// **'Soil'**
  String get plant_detail_care_soil;

  /// No description provided for @plant_detail_care_temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get plant_detail_care_temperature;

  /// No description provided for @plant_detail_care_humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get plant_detail_care_humidity;

  /// No description provided for @encyclopedia_title.
  ///
  /// In en, this message translates to:
  /// **'Encyclopedia'**
  String get encyclopedia_title;

  /// No description provided for @encyclopedia_search.
  ///
  /// In en, this message translates to:
  /// **'Search plants...'**
  String get encyclopedia_search;

  /// No description provided for @encyclopedia_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get encyclopedia_filter_all;

  /// No description provided for @encyclopedia_filter_normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get encyclopedia_filter_normal;

  /// No description provided for @encyclopedia_filter_rare.
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get encyclopedia_filter_rare;

  /// No description provided for @encyclopedia_filter_special.
  ///
  /// In en, this message translates to:
  /// **'Special Rare'**
  String get encyclopedia_filter_special;

  /// No description provided for @encyclopedia_progress.
  ///
  /// In en, this message translates to:
  /// **'{unlocked}/{total} unlocked'**
  String encyclopedia_progress(Object total, Object unlocked);

  /// No description provided for @encyclopedia_empty_title.
  ///
  /// In en, this message translates to:
  /// **'Your collection is empty'**
  String get encyclopedia_empty_title;

  /// No description provided for @encyclopedia_empty_body.
  ///
  /// In en, this message translates to:
  /// **'Start exploring! Take a photo of a plant to begin.'**
  String get encyclopedia_empty_body;

  /// No description provided for @encyclopedia_locked_hint.
  ///
  /// In en, this message translates to:
  /// **'Find to unlock'**
  String get encyclopedia_locked_hint;

  /// No description provided for @profile_title.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile_title;

  /// No description provided for @profile_level.
  ///
  /// In en, this message translates to:
  /// **'Level {level}'**
  String profile_level(Object level);

  /// No description provided for @profile_xp_progress.
  ///
  /// In en, this message translates to:
  /// **'{current}/{next} XP'**
  String profile_xp_progress(Object current, Object next);

  /// No description provided for @profile_stat_scans.
  ///
  /// In en, this message translates to:
  /// **'Total Scans'**
  String get profile_stat_scans;

  /// No description provided for @profile_stat_unlocked.
  ///
  /// In en, this message translates to:
  /// **'Plants Unlocked'**
  String get profile_stat_unlocked;

  /// No description provided for @profile_stat_rare.
  ///
  /// In en, this message translates to:
  /// **'Rare Plants'**
  String get profile_stat_rare;

  /// No description provided for @profile_stat_achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements Earned'**
  String get profile_stat_achievements;

  /// No description provided for @profile_settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get profile_settings;

  /// No description provided for @profile_language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get profile_language;

  /// No description provided for @profile_delete_account.
  ///
  /// In en, this message translates to:
  /// **'Delete Account'**
  String get profile_delete_account;

  /// No description provided for @achievements_title.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements_title;

  /// No description provided for @achievements_filter_all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get achievements_filter_all;

  /// No description provided for @achievements_filter_earned.
  ///
  /// In en, this message translates to:
  /// **'Earned'**
  String get achievements_filter_earned;

  /// No description provided for @achievements_filter_locked.
  ///
  /// In en, this message translates to:
  /// **'Locked'**
  String get achievements_filter_locked;

  /// No description provided for @rarity_normal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get rarity_normal;

  /// No description provided for @rarity_rare.
  ///
  /// In en, this message translates to:
  /// **'Rare'**
  String get rarity_rare;

  /// No description provided for @rarity_special_rare.
  ///
  /// In en, this message translates to:
  /// **'Special Rare'**
  String get rarity_special_rare;

  /// No description provided for @error_network_title.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get error_network_title;

  /// No description provided for @error_network_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get error_network_retry;

  /// No description provided for @error_general_title.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get error_general_title;

  /// No description provided for @error_general_retry.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get error_general_retry;

  /// No description provided for @common_cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get common_cancel;

  /// No description provided for @common_confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get common_confirm;

  /// No description provided for @common_ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get common_ok;

  /// No description provided for @common_save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get common_save;

  /// No description provided for @common_loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get common_loading;

  /// No description provided for @achievements_empty.
  ///
  /// In en, this message translates to:
  /// **'Scan plants to earn achievements!'**
  String get achievements_empty;

  /// No description provided for @achievements_locked_hint.
  ///
  /// In en, this message translates to:
  /// **'Keep exploring to reveal'**
  String get achievements_locked_hint;

  /// No description provided for @achievements_progress.
  ///
  /// In en, this message translates to:
  /// **'{earned} of {total} earned'**
  String achievements_progress(Object earned, Object total);

  /// No description provided for @achievements_signin_hint.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view achievements'**
  String get achievements_signin_hint;

  /// No description provided for @camera_failed.
  ///
  /// In en, this message translates to:
  /// **'Failed to take picture'**
  String get camera_failed;

  /// No description provided for @camera_flash_auto.
  ///
  /// In en, this message translates to:
  /// **'Auto'**
  String get camera_flash_auto;

  /// No description provided for @camera_flash_off.
  ///
  /// In en, this message translates to:
  /// **'Off'**
  String get camera_flash_off;

  /// No description provided for @camera_flash_on.
  ///
  /// In en, this message translates to:
  /// **'Flash'**
  String get camera_flash_on;

  /// No description provided for @camera_frame_hint.
  ///
  /// In en, this message translates to:
  /// **'Frame the plant'**
  String get camera_frame_hint;

  /// No description provided for @camera_light_hint.
  ///
  /// In en, this message translates to:
  /// **'Make sure there\'s good lighting'**
  String get camera_light_hint;

  /// No description provided for @camera_opening.
  ///
  /// In en, this message translates to:
  /// **'Opening camera…'**
  String get camera_opening;

  /// No description provided for @camera_starting.
  ///
  /// In en, this message translates to:
  /// **'Starting camera…'**
  String get camera_starting;

  /// No description provided for @camera_take_picture.
  ///
  /// In en, this message translates to:
  /// **'Take picture'**
  String get camera_take_picture;

  /// No description provided for @camera_tip.
  ///
  /// In en, this message translates to:
  /// **'Fill the frame with the plant for best results'**
  String get camera_tip;

  /// No description provided for @care_humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get care_humidity;

  /// No description provided for @care_soil.
  ///
  /// In en, this message translates to:
  /// **'Soil'**
  String get care_soil;

  /// No description provided for @care_sunlight.
  ///
  /// In en, this message translates to:
  /// **'Sunlight'**
  String get care_sunlight;

  /// No description provided for @care_temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get care_temperature;

  /// No description provided for @care_water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get care_water;

  /// No description provided for @collection_progress_label.
  ///
  /// In en, this message translates to:
  /// **'Progress to next level'**
  String get collection_progress_label;

  /// No description provided for @common_error.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get common_error;

  /// No description provided for @common_retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get common_retry;

  /// No description provided for @common_share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get common_share;

  /// No description provided for @common_view.
  ///
  /// In en, this message translates to:
  /// **'View'**
  String get common_view;

  /// No description provided for @delete_account_warning.
  ///
  /// In en, this message translates to:
  /// **'This permanently deletes your account, discoveries, and history. This action cannot be undone.'**
  String get delete_account_warning;

  /// No description provided for @detail_care_guide.
  ///
  /// In en, this message translates to:
  /// **'Care Guide'**
  String get detail_care_guide;

  /// No description provided for @detail_characteristics.
  ///
  /// In en, this message translates to:
  /// **'Characteristics'**
  String get detail_characteristics;

  /// No description provided for @detail_details.
  ///
  /// In en, this message translates to:
  /// **'Plant Details'**
  String get detail_details;

  /// No description provided for @detail_discovered.
  ///
  /// In en, this message translates to:
  /// **'Discovered'**
  String get detail_discovered;

  /// No description provided for @detail_discovery.
  ///
  /// In en, this message translates to:
  /// **'Discovery'**
  String get detail_discovery;

  /// No description provided for @detail_found_by.
  ///
  /// In en, this message translates to:
  /// **'{n} people discovered this'**
  String detail_found_by(Object n);

  /// No description provided for @detail_fun_facts.
  ///
  /// In en, this message translates to:
  /// **'Fun Facts'**
  String get detail_fun_facts;

  /// No description provided for @detail_habitat.
  ///
  /// In en, this message translates to:
  /// **'Habitat'**
  String get detail_habitat;

  /// No description provided for @detail_humidity.
  ///
  /// In en, this message translates to:
  /// **'Humidity'**
  String get detail_humidity;

  /// No description provided for @detail_join_them.
  ///
  /// In en, this message translates to:
  /// **'Join them by finding it in the wild!'**
  String get detail_join_them;

  /// No description provided for @detail_locked_body.
  ///
  /// In en, this message translates to:
  /// **'Find this plant in the wild to unlock its secrets'**
  String get detail_locked_body;

  /// No description provided for @detail_origin.
  ///
  /// In en, this message translates to:
  /// **'Origin'**
  String get detail_origin;

  /// No description provided for @detail_sightings.
  ///
  /// In en, this message translates to:
  /// **'Sightings'**
  String get detail_sightings;

  /// No description provided for @detail_signin_hint.
  ///
  /// In en, this message translates to:
  /// **'Sign in to view your collection'**
  String get detail_signin_hint;

  /// No description provided for @detail_soil.
  ///
  /// In en, this message translates to:
  /// **'Soil'**
  String get detail_soil;

  /// No description provided for @detail_sunlight.
  ///
  /// In en, this message translates to:
  /// **'Sunlight'**
  String get detail_sunlight;

  /// No description provided for @detail_tap_hint.
  ///
  /// In en, this message translates to:
  /// **'Tap the photo to view full size'**
  String get detail_tap_hint;

  /// No description provided for @detail_temperature.
  ///
  /// In en, this message translates to:
  /// **'Temperature'**
  String get detail_temperature;

  /// No description provided for @detail_uses.
  ///
  /// In en, this message translates to:
  /// **'Uses'**
  String get detail_uses;

  /// No description provided for @detail_water.
  ///
  /// In en, this message translates to:
  /// **'Water'**
  String get detail_water;

  /// No description provided for @error_generic.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong. Please try again.'**
  String get error_generic;

  /// No description provided for @error_network.
  ///
  /// In en, this message translates to:
  /// **'Network error - check your connection and try again.'**
  String get error_network;

  /// No description provided for @fact_amazon.
  ///
  /// In en, this message translates to:
  /// **'The Amazon produces 20% of the world\'s oxygen.'**
  String get fact_amazon;

  /// No description provided for @fact_bamboo.
  ///
  /// In en, this message translates to:
  /// **'Bamboo can grow up to 91cm in a single day!'**
  String get fact_bamboo;

  /// No description provided for @fact_hear_water.
  ///
  /// In en, this message translates to:
  /// **'Some plants can \'hear\' running water and grow towards it.'**
  String get fact_hear_water;

  /// No description provided for @fact_oldest_tree.
  ///
  /// In en, this message translates to:
  /// **'The world\'s oldest tree is over 4,800 years old.'**
  String get fact_oldest_tree;

  /// No description provided for @fact_species.
  ///
  /// In en, this message translates to:
  /// **'There are over 390,000 known plant species on Earth.'**
  String get fact_species;

  /// No description provided for @fact_sunflower.
  ///
  /// In en, this message translates to:
  /// **'A sunflower head can hold up to 2,000 seeds.'**
  String get fact_sunflower;

  /// No description provided for @greeting_afternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greeting_afternoon;

  /// No description provided for @greeting_evening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greeting_evening;

  /// No description provided for @greeting_morning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greeting_morning;

  /// No description provided for @history_empty_body.
  ///
  /// In en, this message translates to:
  /// **'Scan your first plant to start your collection journal.'**
  String get history_empty_body;

  /// No description provided for @history_empty_title.
  ///
  /// In en, this message translates to:
  /// **'No scans yet'**
  String get history_empty_title;

  /// No description provided for @history_status_matched.
  ///
  /// In en, this message translates to:
  /// **'Matched'**
  String get history_status_matched;

  /// No description provided for @history_status_new.
  ///
  /// In en, this message translates to:
  /// **'New species'**
  String get history_status_new;

  /// No description provided for @history_status_pending.
  ///
  /// In en, this message translates to:
  /// **'Processing'**
  String get history_status_pending;

  /// No description provided for @history_title.
  ///
  /// In en, this message translates to:
  /// **'Scan History'**
  String get history_title;

  /// No description provided for @identifying_did_you_know.
  ///
  /// In en, this message translates to:
  /// **'Did you know?'**
  String get identifying_did_you_know;

  /// No description provided for @identifying_slow.
  ///
  /// In en, this message translates to:
  /// **'Taking longer than expected…'**
  String get identifying_slow;

  /// No description provided for @identifying_step_details.
  ///
  /// In en, this message translates to:
  /// **'Gathering details...'**
  String get identifying_step_details;

  /// No description provided for @identifying_tip_text.
  ///
  /// In en, this message translates to:
  /// **'Every plant has a story — leaves, flowers, and all.'**
  String get identifying_tip_text;

  /// No description provided for @nav_encyclopedia.
  ///
  /// In en, this message translates to:
  /// **'Guide'**
  String get nav_encyclopedia;

  /// No description provided for @nav_history.
  ///
  /// In en, this message translates to:
  /// **'Scans'**
  String get nav_history;

  /// No description provided for @nav_home.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get nav_home;

  /// No description provided for @nav_profile.
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get nav_profile;

  /// No description provided for @nav_scan.
  ///
  /// In en, this message translates to:
  /// **'Scan'**
  String get nav_scan;

  /// No description provided for @onboarding_choose_language.
  ///
  /// In en, this message translates to:
  /// **'Choose Language'**
  String get onboarding_choose_language;

  /// No description provided for @plant_not_found.
  ///
  /// In en, this message translates to:
  /// **'Plant not found'**
  String get plant_not_found;

  /// No description provided for @result_achievements_unlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievements Unlocked!'**
  String get result_achievements_unlocked;

  /// No description provided for @result_new_species_label.
  ///
  /// In en, this message translates to:
  /// **'New Species'**
  String get result_new_species_label;

  /// No description provided for @result_safety_notice.
  ///
  /// In en, this message translates to:
  /// **'Safety Notice'**
  String get result_safety_notice;

  /// No description provided for @result_safety_poisonous.
  ///
  /// In en, this message translates to:
  /// **'Potentially Poisonous'**
  String get result_safety_poisonous;

  /// No description provided for @result_tag_edible.
  ///
  /// In en, this message translates to:
  /// **'Edible'**
  String get result_tag_edible;

  /// No description provided for @result_tag_invasive.
  ///
  /// In en, this message translates to:
  /// **'Invasive'**
  String get result_tag_invasive;

  /// No description provided for @result_tag_medicinal.
  ///
  /// In en, this message translates to:
  /// **'Medicinal'**
  String get result_tag_medicinal;

  /// No description provided for @result_tag_poisonous.
  ///
  /// In en, this message translates to:
  /// **'Poisonous'**
  String get result_tag_poisonous;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'km'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'km':
      return AppLocalizationsKm();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
