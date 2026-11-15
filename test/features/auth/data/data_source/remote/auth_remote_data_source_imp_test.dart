import 'package:fitness_app/features/auth/data/client/auth_client.dart';
import 'package:fitness_app/features/auth/data/data_source/remote/auth_remote_data_source_imp.dart';
import 'package:fitness_app/features/auth/data/models/auth_action_response_dto.dart';
import 'package:fitness_app/features/auth/data/models/forget_password_request_dto.dart';
import 'package:fitness_app/features/auth/data/models/reset_password_request_dto.dart';
import 'package:fitness_app/features/auth/data/models/verify_otp_request_dto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'auth_remote_data_source_imp_test.mocks.dart';

@GenerateMocks([AuthClient])
void main() {
  const okDto = AuthActionResponseDto(success: true, message: 'done');
  const rejectedDto = AuthActionResponseDto(
    success: false,
    message: 'Invalid reset code.',
  );

  setUpAll(() {
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
    test(
      'forwards the dto to the client and returns its dto untouched',
      () async {
        const request = ForgetPasswordRequestDto(email: 'user@mail.com');
        when(client.forgotPassword(request)).thenAnswer((_) async => okDto);

        final response = await dataSource.sendResetCode(request);

        expect(response, same(okDto));
        verify(client.forgotPassword(request)).called(1);
      },
    );
  });

  group('AuthRemoteDataSourceImp.verifyResetCode', () {
    test(
      'forwards the dto to the client and returns its dto untouched',
      () async {
        const request = VerifyOtpRequestDto(resetCode: '7542');
        when(client.verifyResetCode(request)).thenAnswer((_) async => okDto);

        final response = await dataSource.verifyResetCode(request);

        expect(response, same(okDto));
        verify(client.verifyResetCode(request)).called(1);
      },
    );

    test(
      'passes a rejected code dto straight through without interpreting it',
      () async {
        const request = VerifyOtpRequestDto(resetCode: '0000');
        when(
          client.verifyResetCode(request),
        ).thenAnswer((_) async => rejectedDto);

        final response = await dataSource.verifyResetCode(request);

        expect(response, same(rejectedDto));
        expect(response.success, isFalse);
        verify(client.verifyResetCode(request)).called(1);
      },
    );
  });

  group('AuthRemoteDataSourceImp.resetPassword', () {
    test(
      'forwards the dto to the client and returns its dto untouched',
      () async {
        const request = ResetPasswordRequestDto(
          email: 'user@mail.com',
          newPassword: 'NewPass1',
        );
        when(client.resetPassword(request)).thenAnswer((_) async => okDto);

        final response = await dataSource.resetPassword(request);

        expect(response, same(okDto));
        verify(client.resetPassword(request)).called(1);
      },
    );
  });
}
