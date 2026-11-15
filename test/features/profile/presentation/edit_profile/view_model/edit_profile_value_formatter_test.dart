import 'package:fitness_app/core/contants/registration_options.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view_model/edit_profile_field.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view_model/edit_profile_value_formatter.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../profile_test_helper.dart';

void main() {
  const draft = testProfileParams;

  group('EditProfileValueFormatter.options', () {
    test('lists the goals in the order the registration step shows them', () {
      final options = EditProfileValueFormatter.options(EditProfileField.goal);

      expect(
        options.map((option) => option.value),
        RegistrationGoal.values.map((goal) => goal.apiKey),
      );
    });

    test('lists the activity levels in the order the backend ranks them', () {
      final options = EditProfileValueFormatter.options(
        EditProfileField.activityLevel,
      );

      expect(
        options.map((option) => option.value),
        RegistrationActivity.values.map((activity) => activity.apiKey),
      );
    });

    test('refuses to list options for a measured field', () {
      for (final field in [
        EditProfileField.age,
        EditProfileField.weight,
        EditProfileField.height,
      ]) {
        expect(
          () => EditProfileValueFormatter.options(field),
          throwsAssertionError,
          reason: '$field is typed as a measurement, not a choice',
        );
      }
    });
  });

  group('EditProfileValueFormatter.number', () {
    test('reads the measurement the field stands for', () {
      expect(EditProfileValueFormatter.number(EditProfileField.age, draft), 25);
      expect(
        EditProfileValueFormatter.number(EditProfileField.weight, draft),
        75.5,
      );
      expect(
        EditProfileValueFormatter.number(EditProfileField.height, draft),
        178,
      );
    });

    test('refuses to read a measurement off a choice field', () {
      for (final field in [
        EditProfileField.goal,
        EditProfileField.activityLevel,
      ]) {
        expect(
          () => EditProfileValueFormatter.number(field, draft),
          throwsAssertionError,
        );
      }
    });
  });

  group('EditProfileValueFormatter.optionValue', () {
    test('returns the stored key the sheet has to preselect', () {
      expect(
        EditProfileValueFormatter.optionValue(EditProfileField.goal, draft),
        'Gain weight',
      );
      expect(
        EditProfileValueFormatter.optionValue(
          EditProfileField.activityLevel,
          draft,
        ),
        'level1',
      );
    });
  });

  group('EditProfileValueFormatter.genderLabel', () {
    test('reads the stored key back as its display label', () {
      for (final gender in RegistrationGender.values) {
        expect(
          EditProfileValueFormatter.genderLabel(gender.apiKey),
          gender.displayText,
        );
      }
    });

    test('shows the stored text when the server sent an unknown gender', () {
      expect(EditProfileValueFormatter.genderLabel('other'), 'other');
    });
  });

  group('EditProfileValueFormatter.value', () {
    test('shows an option field with its readable label', () {
      expect(
        EditProfileValueFormatter.value(EditProfileField.goal, draft),
        RegistrationGoal.gainWeight.displayText,
      );
      expect(
        EditProfileValueFormatter.value(EditProfileField.activityLevel, draft),
        RegistrationActivity.rookie.displayText,
      );
    });

    test('shows a measured field with its unit', () {
      expect(
        EditProfileValueFormatter.value(EditProfileField.age, draft),
        '25 ${LocaleKeys.common_years}',
      );
      expect(
        EditProfileValueFormatter.value(EditProfileField.height, draft),
        '178 ${LocaleKeys.common_cm}',
      );
    });

    test('drops the trailing zero from a whole number', () {
      expect(
        EditProfileValueFormatter.value(EditProfileField.weight, draft),
        '75.5 ${LocaleKeys.common_kg}',
      );
      expect(
        EditProfileValueFormatter.value(
          EditProfileField.weight,
          draft.copyWith(weight: 80.0),
        ),
        '80 ${LocaleKeys.common_kg}',
      );
    });

    test('shows the stored text when the server sent an unknown value', () {
      expect(
        EditProfileValueFormatter.value(
          EditProfileField.goal,
          draft.copyWith(goal: ''),
        ),
        isEmpty,
      );
    });
  });

  group('EditProfileValueFormatter.formatNumber', () {
    test('keeps decimals as they were typed', () {
      expect(EditProfileValueFormatter.formatNumber(75.5), '75.5');
      expect(EditProfileValueFormatter.formatNumber(0), '0');
      expect(EditProfileValueFormatter.formatNumber(-1.25), '-1.25');
    });

    test('trims the point off whole numbers', () {
      expect(EditProfileValueFormatter.formatNumber(178.0), '178');
      expect(EditProfileValueFormatter.formatNumber(25), '25');
    });
  });
}
