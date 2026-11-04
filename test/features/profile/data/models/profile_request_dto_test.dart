import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/features/profile/data/models/profile_request_dto.dart';

import '../../profile_test_helper.dart';

void main() {
  group('ProfileRequestDto', () {
    test('serialises exactly the keys the editProfile endpoint expects', () {
      expect(testProfileRequestDto.toJson().keys.toList(), [
        'firstName',
        'lastName',
        'gender',
        'age',
        'weight',
        'height',
        'activityLevel',
        'goal',
      ]);
    });

    test('sends numeric values without string conversion', () {
      final json = testProfileRequestDto.toJson();

      expect(json['age'], 25);
      expect(json['weight'], 75.5);
      expect(json['height'], 178);
    });

    test('fromParams copies every editable field', () {
      final dto = ProfileRequestDto.fromParams(testProfileParams);

      expect(dto.firstName, testProfileParams.firstName);
      expect(dto.lastName, testProfileParams.lastName);
      expect(dto.gender, testProfileParams.gender);
      expect(dto.age, testProfileParams.age);
      expect(dto.weight, testProfileParams.weight);
      expect(dto.height, testProfileParams.height);
      expect(dto.activityLevel, testProfileParams.activityLevel);
      expect(dto.goal, testProfileParams.goal);
    });

    test('the params extension delegates to fromParams', () {
      expect(
        testProfileParams.toDto().toJson(),
        testProfileRequestDto.toJson(),
      );
    });
  });
}
