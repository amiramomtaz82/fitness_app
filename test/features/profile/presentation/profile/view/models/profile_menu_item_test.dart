import 'package:fitness_app/core/contants/web_pages.dart';
import 'package:flutter/material.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/models/profile_menu_action.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/models/profile_menu_item.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/models/profile_menu_trailing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileMenuItem', () {
    test('defaults to a plain chevron row with no destination', () {
      const item = ProfileMenuItem(
        icon: Icons.person_outline,
        action: ProfileMenuAction.editProfile,
      );

      expect(item.trailing, ProfileMenuTrailing.chevron);
      expect(item.page, isNull);
      expect(item.isDestructive, isFalse);
    });

    test('compares by what the row shows and does', () {
      const first = ProfileMenuItem(
        icon: Icons.person_outline,
        action: ProfileMenuAction.help,
      );
      const same = ProfileMenuItem(
        icon: Icons.person_outline,
        action: ProfileMenuAction.help,
      );
      const other = ProfileMenuItem(
        icon: Icons.person_outline,
        action: ProfileMenuAction.help,
        page: WebPage.help,
      );

      expect(first, same);
      expect(first, isNot(other));
    });
  });

  group('profileMenuItems', () {
    test('holds the seven rows of the profile screen in order', () {
      expect(profileMenuItems.map((item) => item.action), [
        ProfileMenuAction.editProfile,
        ProfileMenuAction.changePassword,
        ProfileMenuAction.selectLanguage,
        ProfileMenuAction.security,
        ProfileMenuAction.privacyPolicy,
        ProfileMenuAction.help,
        ProfileMenuAction.logout,
      ]);
    });

    test('covers each action exactly once', () {
      final actions = profileMenuItems.map((item) => item.action).toSet();

      expect(actions, ProfileMenuAction.values.toSet());
      expect(profileMenuItems, hasLength(actions.length));
    });

    test('draws an icon on every row', () {
      for (final item in profileMenuItems) {
        expect(item.icon.codePoint, isNot(0));
      }
    });

    test('switches only the language row', () {
      final switches = profileMenuItems.where(
        (item) => item.trailing == ProfileMenuTrailing.languageSwitch,
      );

      expect(switches, hasLength(1));
      expect(switches.single.action, ProfileMenuAction.selectLanguage);
    });

    test('marks only the logout row as destructive', () {
      final destructive = profileMenuItems.where((item) => item.isDestructive);

      expect(destructive, hasLength(1));
      expect(destructive.single.action, ProfileMenuAction.logout);
    });

    test('carries a web page only on the rows that open one', () {
      const webActions = [
        ProfileMenuAction.security,
        ProfileMenuAction.privacyPolicy,
        ProfileMenuAction.help,
      ];
      final withPage = profileMenuItems.where((item) => item.page != null);

      expect(withPage.map((item) => item.action), webActions);
      expect(withPage.map((item) => item.page), [
        WebPage.security,
        WebPage.privacyPolicy,
        WebPage.help,
      ]);
    });
  });
}
