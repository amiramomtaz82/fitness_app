import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view_model/edit_profile_field.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view_model/edit_profile_intent.dart';

void main() {
  group('EditProfileIntent', () {
    test('option and number intents carry the field they belong to', () {
      const option = SelectOptionIntent(EditProfileField.gender, 'male');
      const number = UpdateNumberFieldIntent(EditProfileField.weight, 75.5);

      expect(option.field, EditProfileField.gender);
      expect(option.value, 'male');
      expect(number.field, EditProfileField.weight);
      expect(number.value, 75.5);
    });

    test('form lifecycle intents are constant and field independent', () {
      const intents = [StartEditProfileIntent(), SaveProfileIntent()];

      expect(intents, hasLength(2));
      expect(intents, everyElement(isA<EditProfileIntent>()));
    });
  });
}
