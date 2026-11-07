import '../../../../../generated/locale_keys.g.dart';

enum EditProfileField {
  age(
    labelKey: LocaleKeys.profile_your_age_tap_to_edit,
    sheetTitleKey: LocaleKeys.profile_setup_how_old_are_you,
    unitKey: LocaleKeys.common_years,
    min: 10,
    max: 100,
  ),
  weight(
    labelKey: LocaleKeys.profile_your_weight_tap_to_edit,
    sheetTitleKey: LocaleKeys.profile_setup_what_is_your_weight,
    unitKey: LocaleKeys.common_kg,
    min: 30,
    max: 300,
  ),
  height(
    labelKey: LocaleKeys.profile_your_height_tap_to_edit,
    sheetTitleKey: LocaleKeys.profile_setup_what_is_your_height,
    unitKey: LocaleKeys.common_cm,
    min: 100,
    max: 250,
  ),
  goal(
    labelKey: LocaleKeys.profile_your_goal_tap_to_edit,
    sheetTitleKey: LocaleKeys.profile_setup_what_is_your_goal,
  ),
  activityLevel(
    labelKey: LocaleKeys.profile_your_activity_level_tap_to_edit,
    sheetTitleKey: LocaleKeys.profile_setup_activity_level_title,
  );

  const EditProfileField({
    required this.labelKey,
    required this.sheetTitleKey,
    this.unitKey = '',
    this.min = 0,
    this.max = 0,
  });

  final String labelKey;
  final String sheetTitleKey;
  final String unitKey;
  final int min;
  final int max;

  bool get isNumeric => unitKey.isNotEmpty;
}
