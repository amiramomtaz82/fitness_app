import '../../domain/entities/forget_password/auth_action_result.dart';
import '../../domain/entities/forget_password/forget_password_request.dart';
import '../../domain/entities/forget_password/reset_password_request.dart';
import '../../domain/entities/forget_password/verify_otp_request.dart';
import '../models/auth_action_response_dto.dart';
import '../models/forget_password_request_dto.dart';
import '../models/reset_password_request_dto.dart';
import '../models/verify_otp_request_dto.dart';

abstract final class ForgetPasswordMapper {
  ForgetPasswordMapper._();

  static ForgetPasswordRequestDto toSendRequestDto(ForgetPasswordRequest r) =>
      ForgetPasswordRequestDto(email: r.email);

  static VerifyOtpRequestDto toVerifyRequestDto(VerifyOtpRequest r) =>
      VerifyOtpRequestDto(resetCode: r.resetCode);

  static ResetPasswordRequestDto toResetRequestDto(ResetPasswordRequest r) =>
      ResetPasswordRequestDto(email: r.email, newPassword: r.newPassword);

  static AuthActionResult toEntity(AuthActionResponseDto? dto) =>
      AuthActionResult(success: dto?.success ?? true, message: dto?.message);
}
