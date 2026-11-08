import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/profile/domain/use_cases/logout_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../profile_test_helper.dart';

void main() {
  late MockProfileRepo mockRepo;
  late LogoutUseCase useCase;

  setUpAll(registerProfileFallbacks);

  setUp(() {
    mockRepo = MockProfileRepo();
    useCase = LogoutUseCase(mockRepo);
  });

  group('LogoutUseCase', () {
    test('delegates logout to repository and returns success', () async {
      const expected = SuccessResponse<void>(null);
      when(() => mockRepo.logout()).thenAnswer((_) async => expected);

      final result = await useCase.call();

      expect(result, isA<SuccessResponse<void>>());
      verify(() => mockRepo.logout()).called(1);
      verifyNoMoreInteractions(mockRepo);
    });

    test('returns repository failure when logout fails', () async {
      final expected = ErrorResponse<void>(failure: const ServerFailure());
      when(() => mockRepo.logout()).thenAnswer((_) async => expected);

      final result = await useCase.call();

      expect(result, isA<ErrorResponse<void>>());
      expect((result as ErrorResponse<void>).failure, isA<ServerFailure>());
      verify(() => mockRepo.logout()).called(1);
      verifyNoMoreInteractions(mockRepo);
    });
  });
}
