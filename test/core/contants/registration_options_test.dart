import 'package:fitness_app/core/contants/registration_options.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RegistrationGender', () {
    test('offers the two values the backend recognises', () {
      expect(RegistrationGender.values.map((gender) => gender.apiKey), [
        'male',
        'female',
      ]);
    });

    test('labels each value with its own text', () {
      final labels = RegistrationGender.values.map(
        (gender) => gender.displayText,
      );
      expect(labels.toSet(), hasLength(RegistrationGender.values.length));
    });

    test('reads the api key back as the value name', () {
      for (final gender in RegistrationGender.values) {
        expect(gender.apiKey, gender.name);
      }
    });
  });

  group('RegistrationGoal', () {
    test('sends the title-cased label the backend stores', () {
      expect(RegistrationGoal.values.map((goal) => goal.apiKey), [
        'Gain weight',
        'Lose weight',
        'Get fitter',
        'Gain more flexible',
        'Learn the basic',
      ]);
    });

    test('keeps every goal distinguishable on screen', () {
      final labels = RegistrationGoal.values.map((goal) => goal.displayText);
      expect(labels.toSet(), hasLength(RegistrationGoal.values.length));
    });
  });

  group('RegistrationActivity', () {
    test('maps the five levels to their api keys in order', () {
      expect(RegistrationActivity.values.map((activity) => activity.apiKey), [
        'level1',
        'level2',
        'level3',
        'level4',
        'level5',
      ]);
    });

    test('keeps every level distinguishable on screen', () {
      final labels = RegistrationActivity.values.map(
        (activity) => activity.displayText,
      );
      expect(labels.toSet(), hasLength(RegistrationActivity.values.length));
    });
  });
}
