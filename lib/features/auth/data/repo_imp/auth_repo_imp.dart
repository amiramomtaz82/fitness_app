import 'package:injectable/injectable.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import '../../domain/entities/forget_password/auth_action_result.dart';
import '../../domain/entities/forget_password/forget_password_request.dart';
import '../../domain/entities/forget_password/reset_password_request.dart';
import '../../domain/entities/forget_password/verify_otp_request.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repo/auth_repo.dart';
import '../data_source/local/local_data_source.dart';
import '../data_source/remote/auth_remote_data_source.dart';

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
  Future<BaseResponse<AuthActionResult>> sendResetCode(
    ForgetPasswordRequest request,
  ) => _remoteDataSource.sendResetCode(request);

  @override
  Future<BaseResponse<AuthActionResult>> verifyResetCode(
    VerifyOtpRequest request,
  ) => _remoteDataSource.verifyResetCode(request);

  @override
  Future<BaseResponse<AuthActionResult>> resetPassword(
    ResetPasswordRequest request,
  ) => _remoteDataSource.resetPassword(request);
}
