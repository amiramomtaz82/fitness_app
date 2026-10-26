import 'package:fitness_app/features/auth/data/mapper/forget_password_mapper.dart';
import 'package:fitness_app/features/auth/data/models/auth_action_response_dto.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/forget_password_request.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/reset_password_request.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/verify_otp_request.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ForgetPasswordMapper.toSendRequestDto', () {
    test('copies the email across', () {
      final dto = ForgetPasswordMapper.toSendRequestDto(
        const ForgetPasswordRequest(email: 'user@mail.com'),
      );
      expect(dto.email, 'user@mail.com');
    });
  });

  group('ForgetPasswordMapper.toVerifyRequestDto', () {
    test('copies the reset code across', () {
      final dto = ForgetPasswordMapper.toVerifyRequestDto(
        const VerifyOtpRequest(resetCode: '7542'),
      );
      expect(dto.resetCode, '7542');
    });
  });

  group('ForgetPasswordMapper.toResetRequestDto', () {
    test('copies email and new password across', () {
      final dto = ForgetPasswordMapper.toResetRequestDto(
        const ResetPasswordRequest(email: 'user@mail.com', newPassword: 'NewPass1'),
      );
      expect(dto.email, 'user@mail.com');
      expect(dto.newPassword, 'NewPass1');
    });
  });

  group('ForgetPasswordMapper.toEntity', () {
    test('maps success and message from the response dto', () {
      final entity = ForgetPasswordMapper.toEntity(
        const AuthActionResponseDto(success: false, message: 'Invalid reset code.'),
      );
      expect(entity.success, isFalse);
      expect(entity.message, 'Invalid reset code.');
    });

    test('a missing dto defaults to success without a message', () {
      final entity = ForgetPasswordMapper.toEntity(null);
      expect(entity.success, isTrue);
      expect(entity.message, isNull);
    });

    test('a dto without fields defaults to success', () {
      final entity = ForgetPasswordMapper.toEntity(
        const AuthActionResponseDto(),
      );
      expect(entity.success, isTrue);
    });
  });
}
