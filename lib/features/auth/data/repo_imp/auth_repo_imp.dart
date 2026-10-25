import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/base_response/base_response.dart';
import '../../../../core/base_response/safe_call.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/login_params.dart';
import '../../domain/entities/email_provider_status.dart';
import '../../domain/entities/register_parameters.dart';
import '../../domain/entities/social_auth_user.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repo/auth_repo.dart';
import '../data_source/local/local_data_source.dart';
import '../data_source/remote/auth_remote_data_source.dart';
import '../mapper/user_mapper.dart';
import '../models/login_request_dto.dart';
import '../data_source/remote/firestore_user_data_source.dart';
import '../data_source/remote/social_auth_data_source.dart';
import '../models/register_request_dto.dart';
import '../mapper/email_provider_status_mapper.dart';
import '../models/registered_user_dto.dart';

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
  Future<BaseResponse<UserEntity>> login(LoginParams params) {
    return safeCall(() async {
      final response = await _remoteDataSource.login(
        LoginRequestDto(email: params.email, password: params.password),
      );
      final token = response.token;
      final user = UserMapper.toEntity(response.user);
      if (token == null || token.isEmpty || user == null) {
        throw const ServerFailure();
      }
      await _localDataSource.saveToken(token);
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
  @override
  Future<BaseResponse<UserEntity>> register(RegisterParameters params) {
    return safeCall<UserEntity>(() async {
      // 1. Submit signup request to Elevate backend API
      final request = params.toDto();
      final response = await _remoteDataSource.register(request);

      // 2. Parse UserEntity from response
      final entity = response.user?.toEntity() ?? const UserEntity();

      // 3. Save Access Token & User Entity locally (SecureStorage)
      if (response.token != null && response.token!.isNotEmpty) {
        await _localDataSource.saveToken(response.token!);
      }
      await _localDataSource.saveUser(entity);

      // 4. Determine auth provider ('google', 'facebook', or 'email')
      String provider = 'email';
      try {
        final googlePassword = await _firestoreUserService.getProviderPassword('google');
        if (params.password == googlePassword) {
          provider = 'google';
        } else {
          final facebookPassword = await _firestoreUserService.getProviderPassword('facebook');
          if (params.password == facebookPassword) {
            provider = 'facebook';
          }
        }
      } catch (_) {
        // Fallback to .env in case of temporary offline/sync delay
        if (params.password == dotenv.env['GOOGLE_PROVIDER_PASSWORD']) {
          provider = 'google';
        } else if (params.password == dotenv.env['FACEBOOK_PROVIDER_PASSWORD']) {
          provider = 'facebook';
        }
      }
      // 5. Save the user registry record in Firestore
      try {
        await _firestoreUserService.saveUser(
          RegisteredUserDto(
            email: params.email,
            provider: provider,
            firstName: params.firstName,
            lastName: params.lastName,
            createdAt: DateTime.now(),
          ),
        );
      } catch (_) {
        // Allow signup to succeed even if Firestore has sync lag
      }
      return entity;
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
