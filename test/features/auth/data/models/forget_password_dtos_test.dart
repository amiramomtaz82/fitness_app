import 'package:fitness_app/features/auth/data/models/auth_action_response_dto.dart';
import 'package:fitness_app/features/auth/data/models/forget_password_request_dto.dart';
import 'package:fitness_app/features/auth/data/models/reset_password_request_dto.dart';
import 'package:fitness_app/features/auth/data/models/verify_otp_request_dto.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ForgetPasswordRequestDto', () {
    test('serializes to the email key the API expects', () {
      const dto = ForgetPasswordRequestDto(email: 'user@mail.com');
      expect(dto.toJson(), {'email': 'user@mail.com'});
    });

    test('round-trips through fromJson', () {
      final dto = ForgetPasswordRequestDto.fromJson(const {
        'email': 'user@mail.com',
      });
      expect(dto.email, 'user@mail.com');
    });
  });

  group('VerifyOtpRequestDto', () {
    test('serializes to the resetCode key the API expects', () {
      const dto = VerifyOtpRequestDto(resetCode: '7542');
      expect(dto.toJson(), {'resetCode': '7542'});
    });

    test('round-trips through fromJson', () {
      final dto = VerifyOtpRequestDto.fromJson(const {'resetCode': '7542'});
      expect(dto.resetCode, '7542');
    });
  });

  group('ResetPasswordRequestDto', () {
    test('serializes to the email and newPassword keys the API expects', () {
      const dto = ResetPasswordRequestDto(
        email: 'user@mail.com',
        newPassword: 'NewPass1',
      );
      expect(dto.toJson(), {
        'email': 'user@mail.com',
        'newPassword': 'NewPass1',
      });
    });

    test('round-trips through fromJson', () {
      final dto = ResetPasswordRequestDto.fromJson(const {
        'email': 'user@mail.com',
        'newPassword': 'NewPass1',
      });
      expect(dto.email, 'user@mail.com');
      expect(dto.newPassword, 'NewPass1');
    });
  });

  group('AuthActionResponseDto', () {
    test('parses success and message from the backend payload', () {
      final dto = AuthActionResponseDto.fromJson(const {
        'success': false,
        'message': 'Invalid reset code.',
      });
      expect(dto.success, isFalse);
      expect(dto.message, 'Invalid reset code.');
    });

    test('tolerates a payload without any fields', () {
      final dto = AuthActionResponseDto.fromJson(const {});
      expect(dto.success, isNull);
      expect(dto.message, isNull);
    });

    test('round-trips through toJson and fromJson', () {
      const dto = AuthActionResponseDto(success: true, message: 'ok');
      final restored = AuthActionResponseDto.fromJson(dto.toJson());
      expect(restored.success, isTrue);
      expect(restored.message, 'ok');
    });
  });
}
