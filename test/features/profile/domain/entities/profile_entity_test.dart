import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';

import '../../profile_test_helper.dart';

void main() {
  group('ProfileEntity', () {
    test('has empty non-nullable defaults', () {
      const entity = ProfileEntity();

      expect(entity.id, isEmpty);
      expect(entity.fullName, isEmpty);
      expect(entity.age, 0);
      expect(entity.weight, 0);
      expect(entity.height, 0);
      expect(entity.hasPhoto, isFalse);
    });

    test('joins first and last name into fullName', () {
      expect(testProfileEntity.fullName, 'Ahmed Sukkary');
    });

    test('trims a fullName when the last name is missing', () {
      const entity = ProfileEntity(firstName: 'Ahmed');

      expect(entity.fullName, 'Ahmed');
    });

    test('reports a photo only when the path is not blank', () {
      expect(testProfileEntity.hasPhoto, isTrue);
      expect(const ProfileEntity(photo: '   ').hasPhoto, isFalse);
    });

    test('is value equal through Equatable', () {
      const sameAsFixture = ProfileEntity(
        id: '123',
        firstName: 'Ahmed',
        lastName: 'Sukkary',
        email: 'ahmed@test.com',
        gender: 'male',
        age: 25,
        weight: 75.5,
        height: 178,
        activityLevel: 'level1',
        goal: 'Gain weight',
        photo: 'uploads/123/photo.jpg',
      );

      expect(testProfileEntity, sameAsFixture);
      expect(testProfileEntity, isNot(const ProfileEntity(id: '124')));
    });

    test('resolves a relative photo against the api domain', () {
      expect(
        testProfileEntity.photoUrl,
        'https://fitness.elevateegy.com/uploads/123/photo.jpg',
      );
    });

    test('keeps an absolute photo address untouched', () {
      const entity = ProfileEntity(photo: 'https://cdn.example.com/a.jpg');

      expect(entity.photoUrl, 'https://cdn.example.com/a.jpg');
    });

    test('reports no url when the photo is blank', () {
      expect(testProfileEntityNoPhoto.photoUrl, isNull);
    });
  });
}
