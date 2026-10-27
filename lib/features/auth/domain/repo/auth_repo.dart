import '../../../../core/base_response/base_response.dart';
import '../entities/email_provider_status.dart';
import '../entities/forget_password/auth_action_result.dart';
import '../entities/forget_password/forget_password_request.dart';
import '../entities/forget_password/reset_password_request.dart';
import '../entities/forget_password/verify_otp_request.dart';
import '../entities/login_params.dart';
import '../entities/register_parameters.dart';
import '../entities/social_auth_user.dart';
import '../entities/user_entity.dart';

abstract interface class AuthRepo {
  Future<BaseResponse<UserEntity>> login(LoginParams params);
  Future<String?> getToken();
  Future<bool> isLoggedIn();
  Future<UserEntity?> getSavedUser();
  Future<void> logout();
  Future<BaseResponse<UserEntity>> register(RegisterParameters params);
  Future<BaseResponse<String>> getProviderPassword(EmailProviderStatus status);
  Future<BaseResponse<EmailProviderStatus>> checkEmailProvider(String email);
  Future<BaseResponse<SocialAuthUser?>> signInWithGoogle();
  Future<BaseResponse<SocialAuthUser?>> signInWithFacebook();

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