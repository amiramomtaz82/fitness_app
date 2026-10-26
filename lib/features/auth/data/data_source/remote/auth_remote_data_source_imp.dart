import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/base_response/safe_call.dart';
import 'package:fitness_app/features/auth/data/client/auth_client.dart';
import 'package:fitness_app/features/auth/data/data_source/remote/auth_remote_data_source.dart';
import 'package:fitness_app/features/auth/data/mapper/forget_password_mapper.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/auth_action_result.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/forget_password_request.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/reset_password_request.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/verify_otp_request.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImp implements AuthRemoteDataSource {
  final AuthClient _client;

  const AuthRemoteDataSourceImp(this._client);

  @override
  Future<BaseResponse<AuthActionResult>> sendResetCode(
    ForgetPasswordRequest request,
  ) => safeCall(
    () async => ForgetPasswordMapper.toEntity(
      await _client.forgotPassword(ForgetPasswordMapper.toSendRequestDto(request)),
    ),
  );

  @override
  Future<BaseResponse<AuthActionResult>> verifyResetCode(
    VerifyOtpRequest request,
  ) => safeCall(
    () async => ForgetPasswordMapper.toEntity(
      await _client.verifyResetCode(ForgetPasswordMapper.toVerifyRequestDto(request)),
    ),
  );

  @override
  Future<BaseResponse<AuthActionResult>> resetPassword(
    ResetPasswordRequest request,
  ) => safeCall(
    () async => ForgetPasswordMapper.toEntity(
      await _client.resetPassword(ForgetPasswordMapper.toResetRequestDto(request)),
    ),
  );
}
