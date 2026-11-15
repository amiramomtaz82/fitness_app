import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'package:fitness_app/features/profile/domain/use_cases/edit_profile_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../profile_test_helper.dart';

void main() {
  late MockProfileRepo mockRepo;
  late EditProfileUseCase useCase;

  setUpAll(registerProfileFallbacks);

  setUp(() {
    mockRepo = MockProfileRepo();
    useCase = EditProfileUseCase(mockRepo);
  });

  group('EditProfileUseCase', () {
    test(
      'forwards the params to the repo and returns the saved profile',
      () async {
        const expected = SuccessResponse<ProfileEntity>(testProfileEntity);
        when(
          () => mockRepo.editProfile(any()),
        ).thenAnswer((_) async => expected);

        final result = await useCase(testProfileParams);

        expect(result, isA<SuccessResponse<ProfileEntity>>());
        expect(
          (result as SuccessResponse<ProfileEntity>).data,
          testProfileEntity,
        );
        verify(() => mockRepo.editProfile(testProfileParams)).called(1);
        verifyNoMoreInteractions(mockRepo);
      },
    );

    test('returns the repo validation error unchanged', () async {
      final expected = ErrorResponse<ProfileEntity>(
        failure: const ValidationFailure(serverMessage: 'invalid'),
      );
      when(() => mockRepo.editProfile(any())).thenAnswer((_) async => expected);

      final result = await useCase(testProfileParams);

      expect(
        (result as ErrorResponse<ProfileEntity>).failure,
        isA<ValidationFailure>(),
      );
      verify(() => mockRepo.editProfile(testProfileParams)).called(1);
    });
  });
}
