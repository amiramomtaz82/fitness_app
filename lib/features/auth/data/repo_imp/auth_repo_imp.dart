import 'package:injectable/injectable.dart';
import '../../../../core/base_response/base_response.dart';
import '../../../../core/base_response/safe_call.dart';
import '../../domain/entities/email_provider_status.dart';
import '../../domain/entities/register_parameters.dart';
import '../../domain/entities/social_auth_user.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repo/auth_repo.dart';
import '../data_source/local/local_data_source.dart';
import '../data_source/remote/auth_remote_data_source.dart';
import '../data_source/remote/firestore_user_data_source.dart';
import '../data_source/remote/social_auth_data_source.dart';
import '../models/register_request_dto.dart';
import '../mapper/email_provider_status_mapper.dart';

@Injectable(as: AuthRepo)
class AuthRepoImp implements AuthRepo {
  final AuthRemoteDataSource _remoteDataSource;
  final LocalDataSource _localDataSource;
  final SocialAuthService _socialAuthService;
  final FirestoreUserService _firestoreUserService;

  const AuthRepoImp(
    this._remoteDataSource,
    this._localDataSource,
    this._socialAuthService,
    this._firestoreUserService,
  );

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

  @override
  Future<BaseResponse<SocialAuthUser?>> signInWithGoogle() {
    return safeCall<SocialAuthUser?>(
      () => _socialAuthService.signInWithGoogle(),
    );
  }

  @override
  Future<BaseResponse<EmailProviderStatus>> checkEmailProvider(String email) {
    return safeCall<EmailProviderStatus>(
      () => _firestoreUserService.checkEmailProvider(email),
    );
  }

  @override
  Future<BaseResponse<String>> getProviderPassword(EmailProviderStatus status) {
    return safeCall<String>(
      () =>
          _firestoreUserService.getProviderPassword(status.toProviderString()),
    );
  }

  @override
  Future<BaseResponse<SocialAuthUser?>> signInWithFacebook() {
    return safeCall<SocialAuthUser?>(
      () => _socialAuthService.signInWithFacebook(),
    );
  }
}
