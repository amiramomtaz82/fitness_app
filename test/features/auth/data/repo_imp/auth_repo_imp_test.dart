import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/auth/data/data_source/local/local_data_source.dart';
import 'package:fitness_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:fitness_app/features/auth/data/repo_imp/auth_repo_imp.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/auth_action_result.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/forget_password_request.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/reset_password_request.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/verify_otp_request.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_repo_imp_test.mocks.dart';

@GenerateMocks([AuthRemoteDataSource, LocalDataSource])
void main() {
  const result = AuthActionResult(success: true);
  const response = SuccessResponse<AuthActionResult>(result);

  setUpAll(() {
    provideDummy<BaseResponse<AuthActionResult>>(response);
  });

  late MockAuthRemoteDataSource remote;
  late MockLocalDataSource local;
  late AuthRepoImp repo;

  setUp(() {
    remote = MockAuthRemoteDataSource();
    local = MockLocalDataSource();
    repo = AuthRepoImp(remote, local);
  });

  group('AuthRepoImp forget password delegation', () {
    test('sendResetCode forwards the request and returns the same response',
        () async {
      const request = ForgetPasswordRequest(email: 'user@mail.com');
      when(remote.sendResetCode(request)).thenAnswer((_) async => response);

      expect(await repo.sendResetCode(request), same(response));
      verify(remote.sendResetCode(request)).called(1);
    });

    test('verifyResetCode forwards the request and returns the same response',
        () async {
      const request = VerifyOtpRequest(resetCode: '7542');
      when(remote.verifyResetCode(request)).thenAnswer((_) async => response);

      expect(await repo.verifyResetCode(request), same(response));
      verify(remote.verifyResetCode(request)).called(1);
    });

    test('resetPassword forwards the request and returns the same response',
        () async {
      const request = ResetPasswordRequest(
        email: 'user@mail.com',
        newPassword: 'NewPass1',
      );
      when(remote.resetPassword(request)).thenAnswer((_) async => response);

      expect(await repo.resetPassword(request), same(response));
      verify(remote.resetPassword(request)).called(1);
    });
  });

  group('AuthRepoImp local session', () {
    test('getToken reads from the local data source', () async {
      when(local.getToken()).thenAnswer((_) async => 'token-1');

      expect(await repo.getToken(), 'token-1');
      verify(local.getToken()).called(1);
    });

    test('isLoggedIn reads from the local data source', () async {
      when(local.isLoggedIn()).thenAnswer((_) async => true);

      expect(await repo.isLoggedIn(), isTrue);
      verify(local.isLoggedIn()).called(1);
    });

    test('logout clears both token and user', () async {
      await repo.logout();

      verifyInOrder([local.deleteToken(), local.deleteUser()]);
      verifyNever(local.saveToken(any));
      verifyNever(local.saveUser(any));
    });
  });
}
