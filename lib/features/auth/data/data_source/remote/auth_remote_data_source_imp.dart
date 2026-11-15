import 'package:injectable/injectable.dart';

import '../../client/auth_client.dart';
import '../../models/auth_action_response_dto.dart';
import '../../models/forget_password_request_dto.dart';
import '../../models/login_request_dto.dart';
import '../../models/login_response_dto.dart';
import '../../models/register_request_dto.dart';
import '../../models/register_response_dto.dart';
import '../../models/reset_password_request_dto.dart';
import '../../models/verify_otp_request_dto.dart';
import 'auth_remote_data_source.dart';

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImp implements AuthRemoteDataSource {
  final AuthClient _client;

  const AuthRemoteDataSourceImp(this._client);

  @override
  Future<LoginResponseDto> login(LoginRequestDto request) {
    return _client.login(request);
  }

  @override
  Future<RegisterResponseDto> register(RegisterRequestDto request) {
    return _client.register(request);
  }

  @override
  Future<AuthActionResponseDto> sendResetCode(
    ForgetPasswordRequestDto request,
  ) => _client.forgotPassword(request);

  @override
  Future<AuthActionResponseDto> verifyResetCode(VerifyOtpRequestDto request) =>
      _client.verifyResetCode(request);

  @override
  Future<AuthActionResponseDto> resetPassword(
    ResetPasswordRequestDto request,
  ) => _client.resetPassword(request);
}
