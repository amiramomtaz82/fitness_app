import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/features/profile/data/models/profile_user_dto.dart';

import '../../profile_test_helper.dart';

void main() {
  group('ProfileUserDto.fromJson', () {
    test('maps the mongo id key onto id', () {
      expect(ProfileUserDto.fromJson(testProfileUserJson).id, '123');
    });

    test('accepts a fractional weight and height', () {
      final dto = ProfileUserDto.fromJson(const {
        'weight': 75.5,
        'height': 178.2,
        'age': 25,
      });

      expect(dto.weight, 75.5);
      expect(dto.height, 178.2);
      expect(dto.age, 25);
    });

    test('returns nulls for an empty payload', () {
      final dto = ProfileUserDto.fromJson(const {});

      expect(dto.id, isNull);
      expect(dto.firstName, isNull);
      expect(dto.lastName, isNull);
      expect(dto.email, isNull);
      expect(dto.gender, isNull);
      expect(dto.age, isNull);
      expect(dto.weight, isNull);
      expect(dto.height, isNull);
      expect(dto.activityLevel, isNull);
      expect(dto.goal, isNull);
      expect(dto.photo, isNull);
    });
  });

  group('ProfileUserDto.toEntity', () {
    test('maps the fields the profile screen owns', () {
      expect(testProfileUserDto.toEntity(), testProfileEntity);
    });

    test('defaults every missing field instead of leaking nulls', () {
      final entity = const ProfileUserDto(id: '123').toEntity();

      expect(entity.id, '123');
      expect(entity.age, 0);
      expect(entity.weight, 0);
      expect(entity.email, isEmpty);
      expect(entity.photo, isEmpty);
    });
  });
}
