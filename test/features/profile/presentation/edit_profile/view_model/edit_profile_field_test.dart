import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view_model/edit_profile_field.dart';

void main() {
  group('EditProfileField', () {
    test('covers only the fields the user may change', () {
      expect(EditProfileField.values, [
        EditProfileField.age,
        EditProfileField.weight,
        EditProfileField.height,
        EditProfileField.goal,
        EditProfileField.activityLevel,
      ]);
    });

    test('every field carries the label and sheet title it is shown with', () {
      for (final field in EditProfileField.values) {
        expect(field.labelKey, isNotEmpty, reason: field.name);
        expect(field.sheetTitleKey, isNotEmpty, reason: field.name);
      }
    });

    test('only the measured fields expose a unit', () {
      const measured = [
        EditProfileField.age,
        EditProfileField.weight,
        EditProfileField.height,
      ];

      for (final field in EditProfileField.values) {
        expect(
          field.unitKey.isNotEmpty,
          measured.contains(field),
          reason: field.name,
        );
      }
    });

    test('only the measured fields carry a scroll range', () {
      const measured = [
        EditProfileField.age,
        EditProfileField.weight,
        EditProfileField.height,
      ];

      for (final field in EditProfileField.values) {
        expect(
          field.min < field.max,
          measured.contains(field),
          reason: field.name,
        );
      }
    });

    test('the kind of a field is decided by its unit', () {
      expect(EditProfileField.age.isNumeric, isTrue);
      expect(EditProfileField.weight.isNumeric, isTrue);
      expect(EditProfileField.height.isNumeric, isTrue);
      expect(EditProfileField.goal.isNumeric, isFalse);
      expect(EditProfileField.activityLevel.isNumeric, isFalse);
    });
  });
}
