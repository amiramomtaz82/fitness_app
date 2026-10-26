import 'dart:convert';
import 'package:injectable/injectable.dart';
import '../../../../../core/secure_storage/secure_storage.dart';
import '../../../domain/entities/user_entity.dart';
import '../../mapper/user_mapper.dart';
import '../../models/user_dto.dart';
import 'local_data_source.dart';

@Injectable(as: LocalDataSource)
class LocalDataSourceImp implements LocalDataSource {
  final SecureStorage _secureStorage;

  static const String _tokenKey = 'accessToken';
  static const String _userKey = 'cached_user';

  const LocalDataSourceImp(this._secureStorage);

  @override
  Future<void> saveToken(String token) {
    return _secureStorage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> getToken() {
    return _secureStorage.read(key: _tokenKey);
  }

  @override
  Future<void> deleteToken() {
    return _secureStorage.delete(key: _tokenKey);
  }

  @override
  Future<void> saveUser(UserEntity user) {
    final dto = UserMapper.toDto(user);
    final jsonString = jsonEncode(dto?.toJson());
    return _secureStorage.write(key: _userKey, value: jsonString);
  }

  @override
  Future<UserEntity?> getUser() async {
    final jsonString = await _secureStorage.read(key: _userKey);
    if (jsonString == null || jsonString.isEmpty) return null;
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      final dto = UserDto.fromJson(json);
      return UserMapper.toEntity(dto);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> deleteUser() {
    return _secureStorage.delete(key: _userKey);
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
