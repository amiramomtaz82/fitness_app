import 'package:injectable/injectable.dart';
import '../../../../core/base_response/base_response.dart';
import '../../../../core/base_response/safe_call.dart';
import '../../domain/entities/login_params.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repo/auth_repo.dart';
import '../data_source/local/local_data_source.dart';
import '../data_source/remote/auth_remote_data_source.dart';
import '../mapper/user_mapper.dart';
import '../models/login_request_dto.dart';

@Injectable(as: AuthRepo)
class AuthRepoImp implements AuthRepo {
  final AuthRemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;

  const AuthRepoImp(this._remoteDataSource, this._localDataSource);

  @override
  Future<BaseResponse<UserEntity>> login(LoginParams params) {
    return safeCall(() async {
      final response = await _remoteDataSource.login(
        LoginRequestDto(email: params.email, password: params.password),
      );
      final user = UserMapper.toEntity(response.user) ?? const UserEntity();
      await _localDataSource.saveToken(response.token ?? '');
      await _localDataSource.saveUser(user);
      return user;
    });
  }

  @override
  Future<String?> getToken() => _localDataSource.getToken();

  @override
  Future<bool> isLoggedIn() => _localDataSource.isLoggedIn();

  @override
  Future<UserEntity?> getSavedUser() => _localDataSource.getUser();

  @override
  Future<void> logout() async {
    await _localDataSource.deleteToken();
    await _localDataSource.deleteUser();
  }
}
