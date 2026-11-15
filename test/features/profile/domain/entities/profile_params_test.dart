import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_params.dart';

import '../../profile_test_helper.dart';

void main() {
  group('ProfileParams', () {
    test('is built from a saved profile', () {
      expect(ProfileParams.fromEntity(testProfileEntity), testProfileParams);
    });
    test('is value equal through Equatable', () {
      expect(
        testProfileParams,
        const ProfileParams(
          firstName: 'Ahmed',
          lastName: 'Sukkary',
          gender: 'male',
          age: 25,
          weight: 75.5,
          height: 178,
          activityLevel: 'level1',
          goal: 'Gain weight',
        ),
      );
      expect(
        testProfileParams,
        isNot(
          const ProfileParams(
            firstName: 'Ahmed',
            lastName: 'Sukkary',
            gender: 'male',
            age: 26,
            weight: 75.5,
            height: 178,
            activityLevel: 'level1',
            goal: 'Gain weight',
          ),
        ),
      );
    });

    test('copyWith replaces only the given fields', () {
      final updated = testProfileParams.copyWith(goal: 'Lose weight');

      expect(updated.goal, 'Lose weight');
      expect(updated.weight, testProfileParams.weight);
      expect(updated.firstName, testProfileParams.firstName);
    });
  });
}
