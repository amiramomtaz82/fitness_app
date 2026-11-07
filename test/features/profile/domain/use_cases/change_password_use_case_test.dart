import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/profile/domain/entities/change_password_entity.dart';
import 'package:fitness_app/features/profile/domain/use_cases/change_password_use_case.dart';
import 'package:mocktail/mocktail.dart';

import '../../profile_test_helper.dart';

void main() {
  late MockProfileRepo mockRepo;
  late ChangePasswordUseCase useCase;

  setUpAll(registerProfileFallbacks);

  setUp(() {
    mockRepo = MockProfileRepo();
    useCase = ChangePasswordUseCase(mockRepo);
  });

  group('ChangePasswordUseCase', () {
    const password = 'OldPassword123!';
    const newPassword = 'NewPassword123!';

    test(
      'forwards password and newPassword to the repo and returns success',
      () async {
        const entity = ChangePasswordEntity(
          message: 'Password changed successfully',
          token: 'test-token',
        );

        const expected = SuccessResponse<ChangePasswordEntity>(entity);

        when(
          () => mockRepo.changePassword(
            password: any(named: 'password'),
            newPassword: any(named: 'newPassword'),
          ),
        ).thenAnswer((_) async => expected);

        final result = await useCase(
          password: password,
          newPassword: newPassword,
        );

        expect(result, isA<SuccessResponse<ChangePasswordEntity>>());

        expect((result as SuccessResponse<ChangePasswordEntity>).data, entity);

        verify(
          () => mockRepo.changePassword(
            password: password,
            newPassword: newPassword,
          ),
        ).called(1);

        verifyNoMoreInteractions(mockRepo);
      },
    );

    test('returns the repo validation failure unchanged', () async {
      final expected = ErrorResponse<ChangePasswordEntity>(
        failure: const ValidationFailure(serverMessage: 'Invalid password'),
      );

      when(
        () => mockRepo.changePassword(
          password: any(named: 'password'),
          newPassword: any(named: 'newPassword'),
        ),
      ).thenAnswer((_) async => expected);

      final result = await useCase(
        password: password,
        newPassword: newPassword,
      );

      expect(result, isA<ErrorResponse<ChangePasswordEntity>>());

      expect(
        (result as ErrorResponse<ChangePasswordEntity>).failure,
        isA<ValidationFailure>(),
      );

      verify(
        () => mockRepo.changePassword(
          password: password,
          newPassword: newPassword,
        ),
      ).called(1);
    });
  });
}
