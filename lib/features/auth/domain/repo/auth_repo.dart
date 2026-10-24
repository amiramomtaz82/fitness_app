import '../../../../core/base_response/base_response.dart';
import '../entities/email_provider_status.dart';
import '../entities/register_parameters.dart';
import '../entities/social_auth_user.dart';
import '../entities/user_entity.dart';

abstract class AuthRepo {
  Future<String?> getToken();
  Future<bool> isLoggedIn();
  Future<UserEntity?> getSavedUser();
  Future<void> logout();
  Future<BaseResponse<UserEntity>> register(RegisterParameters params);
  Future<BaseResponse<String>> getProviderPassword(EmailProviderStatus status);
  Future<BaseResponse<EmailProviderStatus>> checkEmailProvider(String email);
  Future<BaseResponse<SocialAuthUser?>> signInWithGoogle();
}
