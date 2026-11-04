import 'package:fitness_app/features/profile/presentation/profile/view/models/profile_menu_trailing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileMenuTrailing', () {
    test('offers the chevron and the language switch only', () {
      expect(ProfileMenuTrailing.values, [
        ProfileMenuTrailing.chevron,
        ProfileMenuTrailing.languageSwitch,
      ]);
    });
  });
}
