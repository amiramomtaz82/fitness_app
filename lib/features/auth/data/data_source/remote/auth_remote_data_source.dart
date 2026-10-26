import '../../models/auth_action_response_dto.dart';
import '../../models/forget_password_request_dto.dart';
import '../../models/reset_password_request_dto.dart';
import '../../models/verify_otp_request_dto.dart';

abstract interface class AuthRemoteDataSource {
  Future<AuthActionResponseDto> sendResetCode(ForgetPasswordRequestDto request);

  Future<AuthActionResponseDto> verifyResetCode(VerifyOtpRequestDto request);

  Future<AuthActionResponseDto> resetPassword(ResetPasswordRequestDto request);
}
