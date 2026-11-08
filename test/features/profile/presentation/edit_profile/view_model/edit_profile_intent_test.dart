import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view_model/edit_profile_field.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view_model/edit_profile_intent.dart';

import '../../../profile_test_helper.dart';

void main() {
  group('EditProfileIntent', () {
    test('the start intent carries the profile to edit', () {
      const intent = StartEditProfileIntent(testProfileEntity);

      expect(intent, isA<EditProfileIntent>());
      expect(intent.profile, testProfileEntity);
    });

    test('option and number intents carry the field they belong to', () {
      const option = SelectOptionIntent(EditProfileField.goal, 'Lose weight');
      const number = UpdateNumberFieldIntent(EditProfileField.weight, 75.5);

      expect(option.field, EditProfileField.goal);
      expect(option.value, 'Lose weight');
      expect(number.field, EditProfileField.weight);
      expect(number.value, 75.5);
    });

    test('saving is a constant field independent intent', () {
      const intent = SaveProfileIntent();

      expect(intent, isA<EditProfileIntent>());
    });
  });
}
