import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/auth_action_result.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/forget_password_request.dart';
import 'package:fitness_app/features/auth/domain/repo/auth_repo.dart';
import 'package:fitness_app/features/auth/domain/use_cases/send_reset_code_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'send_reset_code_use_case_test.mocks.dart';

@GenerateMocks([AuthRepo])
void main() {
  late MockAuthRepo repo;
  late SendResetCodeUseCase useCase;

  setUp(() {
    provideDummy<BaseResponse<AuthActionResult>>(
      const SuccessResponse<AuthActionResult>(AuthActionResult(success: true)),
    );
    repo = MockAuthRepo();
    useCase = SendResetCodeUseCase(repo);
  });

  test('delegates the request to AuthRepo.sendResetCode', () async {
    const request = ForgetPasswordRequest(email: 'a@b.com');
    const result = AuthActionResult(success: true);
    when(
      repo.sendResetCode(request),
    ).thenAnswer((_) async => const SuccessResponse<AuthActionResult>(result));

    final response = await useCase(request: request);

    expect(response, isA<SuccessResponse<AuthActionResult>>());
    expect((response as SuccessResponse<AuthActionResult>).data, same(result));
    verify(repo.sendResetCode(request)).called(1);
    verifyNoMoreInteractions(repo);
  });

  test('passes the failure response through unchanged', () async {
    const request = ForgetPasswordRequest(email: 'a@b.com');
    final response = ErrorResponse<AuthActionResult>(errMessage: 'boom');
    when(repo.sendResetCode(request)).thenAnswer((_) async => response);

    final actual = await useCase(request: request);

    expect(actual, same(response));
    verify(repo.sendResetCode(request)).called(1);
    verifyNoMoreInteractions(repo);
  });
}
