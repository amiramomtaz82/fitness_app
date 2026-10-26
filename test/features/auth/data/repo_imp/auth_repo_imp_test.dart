import 'package:dio/dio.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/auth/data/data_source/local/local_data_source.dart';
import 'package:fitness_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:fitness_app/features/auth/data/models/auth_action_response_dto.dart';
import 'package:fitness_app/features/auth/data/models/forget_password_request_dto.dart';
import 'package:fitness_app/features/auth/data/models/reset_password_request_dto.dart';
import 'package:fitness_app/features/auth/data/models/verify_otp_request_dto.dart';
import 'package:fitness_app/features/auth/data/repo_imp/auth_repo_imp.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/auth_action_result.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/forget_password_request.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/reset_password_request.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/verify_otp_request.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_repo_imp_test.mocks.dart';

RequestOptions testOptions() => RequestOptions(path: '/auth/test');

@GenerateMocks([AuthRemoteDataSource, LocalDataSource])
void main() {
  const okDto = AuthActionResponseDto(success: true, message: 'done');

  setUpAll(() {
    provideDummy<AuthActionResponseDto>(const AuthActionResponseDto());
  });

  late MockAuthRemoteDataSource remote;
  late MockLocalDataSource local;
  late AuthRepoImp repo;

  setUp(() {
    remote = MockAuthRemoteDataSource();
    local = MockLocalDataSource();
    repo = AuthRepoImp(remote, local);
  });

  group('AuthRepoImp forget password mapping', () {
    test('sendResetCode converts the entity to a dto and maps the result back',
        () async {
      when(remote.sendResetCode(any)).thenAnswer((_) async => okDto);

      final response = await repo.sendResetCode(
        const ForgetPasswordRequest(email: 'user@mail.com'),
      );

      expect(response, isA<SuccessResponse<AuthActionResult>>());
      expect((response as SuccessResponse<AuthActionResult>).data.success,
          isTrue);
      expect(response.data.message, 'done');
      verify(remote.sendResetCode(
        argThat(isA<ForgetPasswordRequestDto>()),
      )).called(1);
    });

    test('verifyResetCode surfaces a rejected code as a failed entity',
        () async {
      when(remote.verifyResetCode(any)).thenAnswer(
        (_) async => const AuthActionResponseDto(
          success: false,
          message: 'Invalid reset code.',
        ),
      );

      final response = await repo.verifyResetCode(
        const VerifyOtpRequest(resetCode: '0000'),
      );

      final entity = (response as SuccessResponse<AuthActionResult>).data;
      expect(entity.success, isFalse);
      expect(entity.message, 'Invalid reset code.');
      verify(remote.verifyResetCode(
        argThat(isA<VerifyOtpRequestDto>()),
      )).called(1);
    });

    test('resetPassword converts the entity to a dto and maps the result back',
        () async {
      when(remote.resetPassword(any)).thenAnswer((_) async => okDto);

      final response = await repo.resetPassword(
        const ResetPasswordRequest(
          email: 'user@mail.com',
          newPassword: 'NewPass1',
        ),
      );

      expect((response as SuccessResponse<AuthActionResult>).data.success,
          isTrue);
      verify(remote.resetPassword(
        argThat(isA<ResetPasswordRequestDto>()),
      )).called(1);
    });
  });

  group('AuthRepoImp forget password error handling', () {
    test('wraps a network dio error into a network failure', () async {
      when(remote.sendResetCode(any)).thenThrow(
        DioException.connectionError(
          requestOptions: testOptions(),
          reason: 'offline',
        ),
      );

      final response = await repo.sendResetCode(
        const ForgetPasswordRequest(email: 'user@mail.com'),
      );

      expect(response, isA<ErrorResponse<AuthActionResult>>());
      expect(
        (response as ErrorResponse<AuthActionResult>).failure,
        isA<NetworkFailure>(),
      );
      verify(remote.sendResetCode(any)).called(1);
    });

    test('wraps a 500 bad response into a server failure', () async {
      when(remote.sendResetCode(any)).thenThrow(
        DioException.badResponse(
          statusCode: 500,
          requestOptions: testOptions(),
          response: Response(
            requestOptions: testOptions(),
            statusCode: 500,
            data: {'message': 'Internal error'},
          ),
        ),
      );

      final response = await repo.sendResetCode(
        const ForgetPasswordRequest(email: 'user@mail.com'),
      );

      final failure = (response as ErrorResponse<AuthActionResult>).failure;
      expect(failure, isA<ServerFailure>());
      expect(failure.serverMessage, 'Internal error');
      expect(failure.statusCode, 500);
      verify(remote.sendResetCode(any)).called(1);
    });

    test('wraps a 404 into a not found failure', () async {
      when(remote.resetPassword(any)).thenThrow(
        DioException.badResponse(
          statusCode: 404,
          requestOptions: testOptions(),
          response: Response(requestOptions: testOptions(), statusCode: 404),
        ),
      );

      final response = await repo.resetPassword(
        const ResetPasswordRequest(
          email: 'user@mail.com',
          newPassword: 'NewPass1',
        ),
      );

      expect(
        (response as ErrorResponse<AuthActionResult>).failure,
        isA<NotFoundFailure>(),
      );
      verify(remote.resetPassword(any)).called(1);
    });

    test('wraps any other error into an unknown failure', () async {
      when(remote.verifyResetCode(any)).thenThrow(StateError('boom'));

      final response = await repo.verifyResetCode(
        const VerifyOtpRequest(resetCode: '7542'),
      );

      expect(
        (response as ErrorResponse<AuthActionResult>).failure,
        isA<UnknownFailure>(),
      );
      verify(remote.verifyResetCode(any)).called(1);
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
