import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/features/profile/data/models/profile_response_dto.dart';

import '../../profile_test_helper.dart';

void main() {
  group('ProfileResponseDto', () {
    test('parses the api envelope of message and user', () {
      final dto = ProfileResponseDto.fromJson(const {
        'message': 'success',
        'user': {'_id': '123', 'firstName': 'Ahmed', 'weight': 75.5},
      });

      expect(dto.user?.id, '123');
      expect(dto.user?.firstName, 'Ahmed');
      expect(dto.user?.weight, 75.5);
    });

    test('tolerates a payload without a user', () {
      expect(ProfileResponseDto.fromJson(const {'message': 'ok'}).user, isNull);
    });

    test('tolerates unknown fields sent by the backend', () {
      final dto = ProfileResponseDto.fromJson(const {
        'statusCode': 200,
        'meta': {'count': 1},
        'user': {'_id': '123'},
      });

      expect(dto.user?.id, '123');
    });

    test('maps a full user payload of the api envelope', () {
      final dto = ProfileResponseDto.fromJson(const {
        'user': testProfileUserJson,
      });

      expect(dto.user?.id, testProfileUserDto.id);
      expect(dto.user?.email, testProfileUserDto.email);
      expect(dto.user?.weight, testProfileUserDto.weight);
      expect(dto.user?.photo, testProfileUserDto.photo);
    });
  });
}
