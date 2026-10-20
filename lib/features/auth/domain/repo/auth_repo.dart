import '../../../../core/base_response/base_response.dart';
import '../entities/register_parameters.dart';
import '../entities/user_entity.dart';

abstract class AuthRepo {
  Future<String?> getToken();
  Future<bool> isLoggedIn();
  Future<UserEntity?> getSavedUser();
  Future<void> logout();
  Future<BaseResponse<UserEntity>> register(RegisterParameters params);
}
