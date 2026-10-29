import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/auth_action_result.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/verify_otp_request.dart';
import 'package:fitness_app/features/auth/domain/repo/auth_repo.dart';
import 'package:fitness_app/features/auth/domain/use_cases/verify_reset_code_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'verify_reset_code_use_case_test.mocks.dart';

@GenerateMocks([AuthRepo])
void main() {
  late MockAuthRepo repo;
  late VerifyResetCodeUseCase useCase;

  setUp(() {
    provideDummy<BaseResponse<AuthActionResult>>(
      const SuccessResponse<AuthActionResult>(
        AuthActionResult(success: true),
      ),
    );
    repo = MockAuthRepo();
    useCase = VerifyResetCodeUseCase(repo);
  });

  test('delegates the request to AuthRepo.verifyResetCode', () async {
    const request = VerifyOtpRequest(resetCode: '1234');
    const result = AuthActionResult(success: true);
    when(repo.verifyResetCode(request)).thenAnswer(
      (_) async => const SuccessResponse<AuthActionResult>(result),
    );

    final response = await useCase(request: request);

    expect(response, isA<SuccessResponse<AuthActionResult>>());
    expect((response as SuccessResponse<AuthActionResult>).data, same(result));
    verify(repo.verifyResetCode(request)).called(1);
    verifyNoMoreInteractions(repo);
  });

  test('passes an invalid-code failure response through unchanged', () async {
    const request = VerifyOtpRequest(resetCode: '0000');
    final response = ErrorResponse<AuthActionResult>(
      errMessage: 'invalid code',
    );
    when(repo.verifyResetCode(request)).thenAnswer((_) async => response);

    final actual = await useCase(request: request);

    expect(actual, same(response));
    verify(repo.verifyResetCode(request)).called(1);
    verifyNoMoreInteractions(repo);
  });
}
