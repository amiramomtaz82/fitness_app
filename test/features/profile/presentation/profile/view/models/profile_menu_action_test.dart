import 'package:fitness_app/features/profile/presentation/profile/view/models/profile_menu_action.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileMenuAction', () {
    test('lists every row the profile menu can trigger', () {
      expect(ProfileMenuAction.values, [
        ProfileMenuAction.editProfile,
        ProfileMenuAction.changePassword,
        ProfileMenuAction.selectLanguage,
        ProfileMenuAction.security,
        ProfileMenuAction.privacyPolicy,
        ProfileMenuAction.help,
        ProfileMenuAction.logout,
      ]);
    });

    test('gives each row a name unique enough to key its widget', () {
      final names = ProfileMenuAction.values.map((action) => action.name);

      expect(names.toSet(), hasLength(ProfileMenuAction.values.length));
    });
  });
}
