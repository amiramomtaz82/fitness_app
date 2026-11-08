import 'package:fitness_app/core/contants/app_language.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/models/profile_menu_action.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/models/profile_menu_titles.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('menuTitleKey', () {
    test('names the plain rows the same whatever the language is', () {
      const expected = {
        ProfileMenuAction.editProfile: LocaleKeys.profile_edit_profile,
        ProfileMenuAction.changePassword: LocaleKeys.profile_change_password,
        ProfileMenuAction.security: LocaleKeys.profile_security,
        ProfileMenuAction.privacyPolicy: LocaleKeys.profile_privacy_policy,
        ProfileMenuAction.help: LocaleKeys.profile_help,
        ProfileMenuAction.logout: LocaleKeys.profile_logout,
      };

      for (final entry in expected.entries) {
        for (final language in AppLanguage.values) {
          expect(
            menuTitleKey(language, entry.key),
            entry.value,
            reason: '${entry.key.name} should not move with the language',
          );
        }
      }
    });

    test('names the language row after the language the user is in', () {
      expect(
        menuTitleKey(AppLanguage.english, ProfileMenuAction.selectLanguage),
        AppLanguage.english.titleKey,
      );
      expect(
        menuTitleKey(AppLanguage.arabic, ProfileMenuAction.selectLanguage),
        AppLanguage.arabic.titleKey,
      );
    });

    test('resolves a title for every action the menu can fire', () {
      for (final action in ProfileMenuAction.values) {
        expect(
          menuTitleKey(AppLanguage.english, action),
          isNot(isEmpty),
          reason: '$action has no title of its own',
        );
      }
    });
  });
}
