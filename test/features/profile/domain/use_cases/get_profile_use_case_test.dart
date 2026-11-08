import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/profile/domain/entities/profile_entity.dart';
import 'package:fitness_app/features/profile/domain/use_cases/get_profile_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../profile_test_helper.dart';

void main() {
  late MockProfileRepo mockRepo;
  late GetProfileUseCase useCase;

  setUpAll(registerProfileFallbacks);

  setUp(() {
    mockRepo = MockProfileRepo();
    useCase = GetProfileUseCase(mockRepo);
  });

  group('GetProfileUseCase', () {
    test('returns the repo success unchanged', () async {
      const expected = SuccessResponse<ProfileEntity>(testProfileEntity);
      when(() => mockRepo.getProfile()).thenAnswer((_) async => expected);

      final result = await useCase.call();

      expect(result, isA<SuccessResponse<ProfileEntity>>());
      expect(
        (result as SuccessResponse<ProfileEntity>).data,
        testProfileEntity,
      );
      verify(() => mockRepo.getProfile()).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('returns the repo error unchanged', () async {
      final expected = ErrorResponse<ProfileEntity>(
        failure: const NetworkFailure(),
      );
      when(() => mockRepo.getProfile()).thenAnswer((_) async => expected);

      final result = await useCase.call();

      expect(result, isA<ErrorResponse<ProfileEntity>>());
      expect(
        (result as ErrorResponse<ProfileEntity>).failure,
        isA<NetworkFailure>(),
      );
      verify(() => mockRepo.getProfile()).called(1);
    });
  });
}
