import 'package:fitness_app/core/base_response/base_response.dart';
import '../entities/forget_password/auth_action_result.dart';
import '../entities/forget_password/forget_password_request.dart';
import '../entities/forget_password/reset_password_request.dart';
import '../entities/forget_password/verify_otp_request.dart';
import '../entities/user_entity.dart';

abstract interface class AuthRepo {
  Future<String?> getToken();
  Future<bool> isLoggedIn();
  Future<UserEntity?> getSavedUser();
  Future<void> logout();

  Future<BaseResponse<AuthActionResult>> sendResetCode(
    ForgetPasswordRequest request,
  );

  Future<BaseResponse<AuthActionResult>> verifyResetCode(
    VerifyOtpRequest request,
  );

  Future<BaseResponse<AuthActionResult>> resetPassword(
    ResetPasswordRequest request,
  );
}
