import '../../../../core/base_response/base_response.dart';
import '../entities/login_params.dart';
import '../entities/user_entity.dart';

abstract interface class AuthRepo {
  Future<BaseResponse<UserEntity>> login(LoginParams params);
  Future<String?> getToken();
  Future<bool> isLoggedIn();
  Future<UserEntity?> getSavedUser();
  Future<void> logout();
}
