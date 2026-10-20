import 'package:injectable/injectable.dart';
import '../../../../core/base_response/base_response.dart';
import '../../../../core/base_response/safe_call.dart';
import '../../domain/entities/register_parameters.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repo/auth_repo.dart';
import '../data_source/local/local_data_source.dart';
import '../data_source/remote/auth_remote_data_source.dart';
import '../models/register_request_dto.dart';

@Injectable(as: AuthRepo)
class AuthRepoImp implements AuthRepo {
  final AuthRemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;

  const AuthRepoImp(this._remoteDataSource, this._localDataSource);

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

  @override
  Future<BaseResponse<UserEntity>> register(RegisterParameters params) {
    return safeCall<UserEntity>(() async {
      final request = params.toDto();
      final response = await _remoteDataSource.register(request);
      final entity = response.user?.toEntity();
      return entity ?? const UserEntity();
    });
  }
}
