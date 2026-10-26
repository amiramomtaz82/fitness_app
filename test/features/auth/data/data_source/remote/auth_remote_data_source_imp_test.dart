import 'package:dio/dio.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/auth/data/client/auth_client.dart';
import 'package:fitness_app/features/auth/data/data_source/remote/auth_remote_data_source_imp.dart';
import 'package:fitness_app/features/auth/data/models/auth_action_response_dto.dart';
import 'package:fitness_app/features/auth/data/models/forget_password_request_dto.dart';
import 'package:fitness_app/features/auth/data/models/reset_password_request_dto.dart';
import 'package:fitness_app/features/auth/data/models/verify_otp_request_dto.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/auth_action_result.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/forget_password_request.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/reset_password_request.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/verify_otp_request.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_remote_data_source_imp_test.mocks.dart';

RequestOptions testOptions() => RequestOptions(path: '/auth/test');

@GenerateMocks([AuthClient])
void main() {
  const okDto = AuthActionResponseDto(success: true, message: 'done');

  setUpAll(() {
    provideDummy<BaseResponse<AuthActionResult>>(
      const SuccessResponse<AuthActionResult>(AuthActionResult(success: true)),
    );
    provideDummy<AuthActionResponseDto>(const AuthActionResponseDto());
  });

  late MockAuthClient client;
  late AuthRemoteDataSourceImp dataSource;

  setUp(() {
    client = MockAuthClient();
    dataSource = AuthRemoteDataSourceImp(client);
  });

  tearDown(() {
    verifyNoMoreInteractions(client);
  });

  group('AuthRemoteDataSourceImp.sendResetCode', () {
    test('maps the client response into an entity success', () async {
      when(client.forgotPassword(any)).thenAnswer((_) async => okDto);

      final response = await dataSource.sendResetCode(
        const ForgetPasswordRequest(email: 'user@mail.com'),
      );

      expect(response, isA<SuccessResponse<AuthActionResult>>());
      expect((response as SuccessResponse<AuthActionResult>).data.success,
          isTrue);
      expect(response.data.message, 'done');
      verify(client.forgotPassword(
        argThat(isA<ForgetPasswordRequestDto>()),
      )).called(1);
    });

    test('wraps a network dio error into a network failure', () async {
      when(client.forgotPassword(any)).thenThrow(
        DioException.connectionError(
          requestOptions: testOptions(),
          reason: 'offline',
        ),
      );

      final response = await dataSource.sendResetCode(
        const ForgetPasswordRequest(email: 'user@mail.com'),
      );

      expect(response, isA<ErrorResponse<AuthActionResult>>());
      expect(
        (response as ErrorResponse<AuthActionResult>).failure,
        isA<NetworkFailure>(),
      );
      verify(client.forgotPassword(any)).called(1);
    });

    test('wraps a 500 bad response into a server failure', () async {
      when(client.forgotPassword(any)).thenThrow(
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

      final response = await dataSource.sendResetCode(
        const ForgetPasswordRequest(email: 'user@mail.com'),
      );

      final failure = (response as ErrorResponse<AuthActionResult>).failure;
      expect(failure, isA<ServerFailure>());
      expect(failure.serverMessage, 'Internal error');
      expect(failure.statusCode, 500);
      verify(client.forgotPassword(any)).called(1);
    });

    test('wraps any other error into an unknown failure', () async {
      when(client.forgotPassword(any)).thenThrow(StateError('boom'));

      final response = await dataSource.sendResetCode(
        const ForgetPasswordRequest(email: 'user@mail.com'),
      );

      expect(
        (response as ErrorResponse<AuthActionResult>).failure,
        isA<UnknownFailure>(),
      );
      verify(client.forgotPassword(any)).called(1);
    });
  });

  group('AuthRemoteDataSourceImp.verifyResetCode', () {
    test('maps the client response into an entity success', () async {
      when(client.verifyResetCode(any)).thenAnswer((_) async => okDto);

      final response = await dataSource.verifyResetCode(
        const VerifyOtpRequest(resetCode: '7542'),
      );

      expect((response as SuccessResponse<AuthActionResult>).data.success,
          isTrue);
      verify(client.verifyResetCode(
        argThat(isA<VerifyOtpRequestDto>()),
      )).called(1);
    });

    test('a rejected code from the backend surfaces as an error snackbar data',
        () async {
      when(client.verifyResetCode(any)).thenAnswer(
        (_) async =>
            const AuthActionResponseDto(success: false, message: 'Invalid reset code.'),
      );

      final response = await dataSource.verifyResetCode(
        const VerifyOtpRequest(resetCode: '0000'),
      );

      final entity = (response as SuccessResponse<AuthActionResult>).data;
      expect(entity.success, isFalse);
      expect(entity.message, 'Invalid reset code.');
      verify(client.verifyResetCode(any)).called(1);
    });
  });

  group('AuthRemoteDataSourceImp.resetPassword', () {
    test('maps the client response into an entity success', () async {
      when(client.resetPassword(any)).thenAnswer((_) async => okDto);

      final response = await dataSource.resetPassword(
        const ResetPasswordRequest(email: 'user@mail.com', newPassword: 'NewPass1'),
      );

      expect((response as SuccessResponse<AuthActionResult>).data.success,
          isTrue);
      verify(client.resetPassword(
        argThat(isA<ResetPasswordRequestDto>()),
      )).called(1);
    });

    test('wraps a 404 into a not found failure', () async {
      when(client.resetPassword(any)).thenThrow(
        DioException.badResponse(
          statusCode: 404,
          requestOptions: testOptions(),
          response: Response(requestOptions: testOptions(), statusCode: 404),
        ),
      );

      final response = await dataSource.resetPassword(
        const ResetPasswordRequest(email: 'user@mail.com', newPassword: 'NewPass1'),
      );

      expect(
        (response as ErrorResponse<AuthActionResult>).failure,
        isA<NotFoundFailure>(),
      );
      verify(client.resetPassword(any)).called(1);
    });
  });
}
