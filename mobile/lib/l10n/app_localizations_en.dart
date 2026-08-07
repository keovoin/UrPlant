// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get app_name => 'UrPlant';

  @override
  String get app_tagline => 'Discover the world around you';

  @override
  String get onboarding_title_1 => 'Discover Plants';

  @override
  String get onboarding_body_1 => 'Point your camera at any plant and UrPlant will identify it instantly.';

  @override
  String get onboarding_title_2 => 'Learn Everything';

  @override
  String get onboarding_body_2 => 'Get detailed info, origin stories, care guides, and fun facts — in English or Khmer.';

  @override
  String get onboarding_title_3 => 'Build Your Collection';

  @override
  String get onboarding_body_3 => 'Unlock rare and special plants. Earn achievements. Become a plant master!';

  @override
  String get onboarding_skip => 'Skip';

  @override
  String get onboarding_next => 'Next';

  @override
  String get onboarding_get_started => 'Get Started';

  @override
  String get language_title => 'Choose Language';

  @override
  String get language_english => 'English';

  @override
  String get language_khmer => 'ភាសាខ្មែរ';

  @override
  String get language_continue => 'Continue';

  @override
  String get auth_sign_up => 'Create Account';

  @override
  String get auth_sign_in => 'Log In';

  @override
  String get auth_email => 'Email';

  @override
  String get auth_password => 'Password';

  @override
  String get auth_display_name => 'Display Name';

  @override
  String get auth_continue_google => 'Continue with Google';

  @override
  String get auth_guest => 'Try as Guest';

  @override
  String get auth_already_have_account => 'Already have an account? Log in';

  @override
  String get auth_logout => 'Log Out';

  @override
  String get home_title => 'UrPlant';

  @override
  String get home_hero_title => 'Ready to scan?';

  @override
  String get home_hero_subtitle => 'Tap camera to identify any plant';

  @override
  String get home_hero_cta => 'Open Camera';

  @override
  String get home_your_collection => 'Your Collection';

  @override
  String get home_view_all => 'View All';

  @override
  String get home_recent_activity => 'Recent Activity';

  @override
  String get home_achievements => 'Achievements';

  @override
  String get camera_hint => 'Frame the plant';

  @override
  String get camera_review_retake => 'Retake';

  @override
  String get camera_review_use => 'Use Photo';

  @override
  String get identifying_title => 'Identifying...';

  @override
  String get identifying_step_analyze => 'Analyzing image...';

  @override
  String get identifying_step_match => 'Matching database...';

  @override
  String get identifying_step_info => 'Gathering info...';

  @override
  String get identifying_fact_title => 'Did you know?';

  @override
  String get identifying_timeout => 'Taking longer than expected...';

  @override
  String get identifying_error => 'Connection lost';

  @override
  String get identifying_retry => 'Try Again';

  @override
  String get result_new_unlock => 'New Plant Unlocked!';

  @override
  String get result_duplicate => 'Already in your collection!';

  @override
  String get result_low_confidence_title => 'Couldn\'t Identify';

  @override
  String get result_low_confidence_tip_1 => 'Get closer to the plant';

  @override
  String get result_low_confidence_tip_2 => 'Make sure there\'s good lighting';

  @override
  String get result_low_confidence_tip_3 => 'Focus on leaves or flowers';

  @override
  String get result_low_confidence_tip_4 => 'Avoid blurry photos';

  @override
  String get result_unmatched_title => 'Plant Not in Database';

  @override
  String get result_unmatched_body => 'Plant found but not in our database yet. We\'ll review it!';

  @override
  String result_xp_earned(Object xp) {
    return '+$xp XP';
  }

  @override
  String get result_scan_another => 'Scan Another Plant';

  @override
  String get result_go_home => 'Go Home';

  @override
  String get plant_detail_discovered => 'Discovered';

  @override
  String get plant_detail_sightings => 'Sightings';

  @override
  String get plant_detail_locked_hint => 'Find this plant in the wild to unlock its secrets';

  @override
  String get plant_detail_section_details => 'Plant Details';

  @override
  String get plant_detail_section_origin => 'Origin';

  @override
  String get plant_detail_section_care => 'Care Guide';

  @override
  String get plant_detail_section_facts => 'Fun Facts';

  @override
  String get plant_detail_care_water => 'Water';

  @override
  String get plant_detail_care_sunlight => 'Sunlight';

  @override
  String get plant_detail_care_soil => 'Soil';

  @override
  String get plant_detail_care_temperature => 'Temperature';

  @override
  String get plant_detail_care_humidity => 'Humidity';

  @override
  String get encyclopedia_title => 'Encyclopedia';

  @override
  String get encyclopedia_search => 'Search plants...';

  @override
  String get encyclopedia_filter_all => 'All';

  @override
  String get encyclopedia_filter_normal => 'Normal';

  @override
  String get encyclopedia_filter_rare => 'Rare';

  @override
  String get encyclopedia_filter_special => 'Special Rare';

  @override
  String encyclopedia_progress(Object total, Object unlocked) {
    return '$unlocked/$total unlocked';
  }

  @override
  String get encyclopedia_empty_title => 'Your collection is empty';

  @override
  String get encyclopedia_empty_body => 'Start exploring! Take a photo of a plant to begin.';

  @override
  String get encyclopedia_locked_hint => 'Find to unlock';

  @override
  String get profile_title => 'Profile';

  @override
  String profile_level(Object level) {
    return 'Level $level';
  }

  @override
  String profile_xp_progress(Object current, Object next) {
    return '$current/$next XP';
  }

  @override
  String get profile_stat_scans => 'Total Scans';

  @override
  String get profile_stat_unlocked => 'Plants Unlocked';

  @override
  String get profile_stat_rare => 'Rare Plants';

  @override
  String get profile_stat_achievements => 'Achievements Earned';

  @override
  String get profile_settings => 'Settings';

  @override
  String get profile_language => 'Language';

  @override
  String get profile_delete_account => 'Delete Account';

  @override
  String get achievements_title => 'Achievements';

  @override
  String get achievements_filter_all => 'All';

  @override
  String get achievements_filter_earned => 'Earned';

  @override
  String get achievements_filter_locked => 'Locked';

  @override
  String get rarity_normal => 'Normal';

  @override
  String get rarity_rare => 'Rare';

  @override
  String get rarity_special_rare => 'Special Rare';

  @override
  String get error_network_title => 'No internet connection';

  @override
  String get error_network_retry => 'Retry';

  @override
  String get error_general_title => 'Something went wrong';

  @override
  String get error_general_retry => 'Try Again';

  @override
  String get common_cancel => 'Cancel';

  @override
  String get common_confirm => 'Confirm';

  @override
  String get common_ok => 'OK';

  @override
  String get common_save => 'Save';

  @override
  String get common_loading => 'Loading...';
}
