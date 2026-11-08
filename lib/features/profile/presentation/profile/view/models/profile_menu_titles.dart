import 'package:fitness_app/core/contants/app_language.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'profile_menu_action.dart';

String menuTitleKey(AppLanguage language, ProfileMenuAction action) {
  return switch (action) {
    ProfileMenuAction.editProfile => LocaleKeys.profile_edit_profile,
    ProfileMenuAction.changePassword => LocaleKeys.profile_change_password,
    ProfileMenuAction.selectLanguage => language.titleKey,
    ProfileMenuAction.security => LocaleKeys.profile_security,
    ProfileMenuAction.privacyPolicy => LocaleKeys.profile_privacy_policy,
    ProfileMenuAction.help => LocaleKeys.profile_help,
    ProfileMenuAction.logout => LocaleKeys.profile_logout,
  };
}
