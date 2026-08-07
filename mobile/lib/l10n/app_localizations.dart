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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
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
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en', 'km'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en': return AppLocalizationsEn();
    case 'km': return AppLocalizationsKm();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
