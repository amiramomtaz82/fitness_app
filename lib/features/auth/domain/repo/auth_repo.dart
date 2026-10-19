import '../entities/user_entity.dart';

abstract class AuthRepo {
  Future<String?> getToken();
  Future<bool> isLoggedIn();
  Future<UserEntity?> getSavedUser();
  Future<void> logout();
}
