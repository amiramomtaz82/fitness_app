import '../../domain/entities/forget_password/auth_action_result.dart';
import '../../domain/entities/forget_password/forget_password_request.dart';
import '../../domain/entities/forget_password/reset_password_request.dart';
import '../../domain/entities/forget_password/verify_otp_request.dart';
import '../models/auth_action_response_dto.dart';
import '../models/forget_password_request_dto.dart';
import '../models/reset_password_request_dto.dart';
import '../models/verify_otp_request_dto.dart';

extension ForgetPasswordRequestToDto on ForgetPasswordRequest {
  ForgetPasswordRequestDto toDto() => ForgetPasswordRequestDto(email: email);
}

extension VerifyOtpRequestToDto on VerifyOtpRequest {
  VerifyOtpRequestDto toDto() => VerifyOtpRequestDto(resetCode: resetCode);
}

extension ResetPasswordRequestToDto on ResetPasswordRequest {
  ResetPasswordRequestDto toDto() =>
      ResetPasswordRequestDto(email: email, newPassword: newPassword);
}

extension AuthActionResponseDtoToEntity on AuthActionResponseDto? {
  AuthActionResult toEntity() =>
      AuthActionResult(success: this?.success ?? true, message: this?.message);
}
