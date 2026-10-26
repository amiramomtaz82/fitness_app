import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/auth_action_result.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/reset_password_request.dart';
import 'package:fitness_app/features/auth/domain/repo/auth_repo.dart';
import 'package:fitness_app/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'reset_password_use_case_test.mocks.dart';

@GenerateMocks([AuthRepo])
void main() {
  late MockAuthRepo repo;
  late ResetPasswordUseCase useCase;

  setUp(() {
    provideDummy<BaseResponse<AuthActionResult>>(
      const SuccessResponse<AuthActionResult>(
        AuthActionResult(success: true),
      ),
    );
    repo = MockAuthRepo();
    useCase = ResetPasswordUseCase(repo);
  });

  test('delegates the request to AuthRepo.resetPassword', () async {
    const request = ResetPasswordRequest(
      email: 'a@b.com',
      newPassword: 'NewPass123',
    );
    const result = AuthActionResult(success: true, message: 'done');
    when(repo.resetPassword(request)).thenAnswer(
      (_) async => const SuccessResponse<AuthActionResult>(result),
    );

    final response = await useCase(request: request);

    expect(response, isA<SuccessResponse<AuthActionResult>>());
    expect((response as SuccessResponse<AuthActionResult>).data, same(result));
    verify(repo.resetPassword(request)).called(1);
    verifyNoMoreInteractions(repo);
  });

  test('passes the failure response through unchanged', () async {
    const request = ResetPasswordRequest(
      email: 'a@b.com',
      newPassword: 'NewPass123',
    );
    final response = ErrorResponse<AuthActionResult>(errMessage: 'expired');
    when(repo.resetPassword(request)).thenAnswer((_) async => response);

    final actual = await useCase(request: request);

    expect(actual, same(response));
    verify(repo.resetPassword(request)).called(1);
    verifyNoMoreInteractions(repo);
  });
}
