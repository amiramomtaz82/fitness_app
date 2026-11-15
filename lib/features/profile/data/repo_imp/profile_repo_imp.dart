import 'package:injectable/injectable.dart';

import '../../../../core/base_response/base_response.dart';
import '../../../../core/base_response/safe_call.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/secure_storage/secure_storage.dart';
import '../../domain/entities/profile_entity.dart';
import '../../domain/entities/profile_params.dart';
import '../../domain/repo/profile_repo.dart';
import '../data_source/profile_remote_data_source.dart';
import '../models/profile_request_dto.dart';
import '../models/profile_user_dto.dart';

@Injectable(as: ProfileRepo)
class ProfileRepoImp implements ProfileRepo {
  final ProfileRemoteDataSource _remoteDataSource;
  final SecureStorage _secureStorage;
  const ProfileRepoImp(this._remoteDataSource, this._secureStorage);

  @override
  Future<BaseResponse<ProfileEntity>> getProfile() {
    return safeCall(() async {
      final response = await _remoteDataSource.getProfile();
      return _requireUser(response.user);
    });
  }

  @override
  Future<BaseResponse<ProfileEntity>> editProfile(ProfileParams params) {
    return safeCall(() async {
      final response = await _remoteDataSource.editProfile(params.toDto());
      return _requireUser(response.user);
    });
  }

  @override
  Future<BaseResponse<ProfileEntity>> uploadPhoto(String photoPath) {
    return safeCall(() async {
      final response = await _remoteDataSource.uploadPhoto(photoPath);
      if (response.user != null) return response.user!.toEntity();
      return _requireUser((await _remoteDataSource.getProfile()).user);
    });
  }

  ProfileEntity _requireUser(ProfileUserDto? userDto) {
    final entity = userDto?.toEntity();
    if (entity == null) {
      throw const ServerFailure();
    }
    return entity;
  }

  @override
  Future<BaseResponse<void>> logout() {
    return safeCall<void>(() async {
      await _secureStorage.delete(key: 'accessToken');
      await _secureStorage.delete(key: 'cached_user');
    });
  }
}
