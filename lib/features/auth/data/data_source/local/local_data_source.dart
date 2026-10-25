import '../../../domain/entities/user_entity.dart';

abstract interface class LocalDataSource {
  Future<void> saveToken(String token);
  Future<String?> getToken();
  Future<void> deleteToken();
  Future<void> saveUser(UserEntity user);
  Future<UserEntity?> getUser();
  Future<void> deleteUser();
  Future<bool> isLoggedIn();
}
