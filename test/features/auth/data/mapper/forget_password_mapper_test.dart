import 'package:fitness_app/features/auth/data/mapper/forget_password_mapper.dart';
import 'package:fitness_app/features/auth/data/models/auth_action_response_dto.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/forget_password_request.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/reset_password_request.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/verify_otp_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ForgetPasswordRequest.toDto', () {
    test('copies the email across', () {
      const request = ForgetPasswordRequest(email: 'user@mail.com');
      final dto = request.toDto();
      expect(dto.email, 'user@mail.com');
    });
  });

  group('VerifyOtpRequest.toDto', () {
    test('copies the reset code across', () {
      const request = VerifyOtpRequest(resetCode: '7542');
      final dto = request.toDto();
      expect(dto.resetCode, '7542');
    });
  });

  group('ResetPasswordRequest.toDto', () {
    test('copies email and new password across', () {
      const request = ResetPasswordRequest(
        email: 'user@mail.com',
        newPassword: 'NewPass1',
      );
      final dto = request.toDto();
      expect(dto.email, 'user@mail.com');
      expect(dto.newPassword, 'NewPass1');
    });
  });

  group('AuthActionResponseDto.toEntity', () {
    test('maps success and message from the response dto', () {
      const dto = AuthActionResponseDto(
        success: false,
        message: 'Invalid reset code.',
      );
      final entity = dto.toEntity();
      expect(entity.success, isFalse);
      expect(entity.message, 'Invalid reset code.');
    });

    test('a missing dto defaults to success without a message', () {
      const AuthActionResponseDto? dto = null;
      final entity = dto.toEntity();
      expect(entity.success, isTrue);
      expect(entity.message, isNull);
    });

    test('a dto without fields defaults to success', () {
      const dto = AuthActionResponseDto();
      final entity = dto.toEntity();
      expect(entity.success, isTrue);
    });
  });
}
