import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'package:fitness_app/features/profile/domain/use_cases/upload_photo_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../profile_test_helper.dart';

void main() {
  late MockProfileRepo mockRepo;
  late UploadPhotoUseCase useCase;

  setUpAll(registerProfileFallbacks);

  setUp(() {
    mockRepo = MockProfileRepo();
    useCase = UploadPhotoUseCase(mockRepo);
  });

  group('UploadPhotoUseCase', () {
    test('forwards the photo path and returns the updated profile', () async {
      const expected = SuccessResponse<ProfileEntity>(testProfileEntity);
      when(() => mockRepo.uploadPhoto(any())).thenAnswer((_) async => expected);

      final result = await useCase('/tmp/photo.jpg');

      expect(result, same(expected));
      expect(
        (result as SuccessResponse<ProfileEntity>).data,
        testProfileEntity,
      );
      verify(() => mockRepo.uploadPhoto('/tmp/photo.jpg')).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('returns the photo size failure unchanged', () async {
      final expected = ErrorResponse<ProfileEntity>(
        failure: const PhotoTooLargeFailure(),
      );
      when(() => mockRepo.uploadPhoto(any())).thenAnswer((_) async => expected);

      final result = await useCase('/tmp/huge.jpg');

      expect(
        (result as ErrorResponse<ProfileEntity>).failure,
        isA<PhotoTooLargeFailure>(),
      );
      verify(() => mockRepo.uploadPhoto('/tmp/huge.jpg')).called(1);
    });
  });
}
