import '../../../../../generated/locale_keys.g.dart';

enum EditProfileField {
  gender(
    labelKey: LocaleKeys.profile_your_gender_tap_to_edit,
    sheetTitleKey: LocaleKeys.profile_setup_need_to_know_gender,
  ),
  age(
    labelKey: LocaleKeys.profile_your_age_tap_to_edit,
    sheetTitleKey: LocaleKeys.profile_setup_how_old_are_you,
    unitKey: LocaleKeys.common_years,
  ),
  weight(
    labelKey: LocaleKeys.profile_your_weight_tap_to_edit,
    sheetTitleKey: LocaleKeys.profile_setup_what_is_your_weight,
    unitKey: LocaleKeys.common_kg,
  ),
  height(
    labelKey: LocaleKeys.profile_your_height_tap_to_edit,
    sheetTitleKey: LocaleKeys.profile_setup_what_is_your_height,
    unitKey: LocaleKeys.common_cm,
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
  });

  final String labelKey;
  final String sheetTitleKey;
  final String unitKey;

  bool get isNumeric => unitKey.isNotEmpty;
}
