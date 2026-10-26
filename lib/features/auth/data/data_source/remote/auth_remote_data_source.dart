import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/auth_action_result.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/forget_password_request.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/reset_password_request.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/verify_otp_request.dart';

abstract interface class AuthRemoteDataSource {
  Future<BaseResponse<AuthActionResult>> sendResetCode(
    ForgetPasswordRequest request,
  );

  Future<BaseResponse<AuthActionResult>> verifyResetCode(
    VerifyOtpRequest request,
  );

  Future<BaseResponse<AuthActionResult>> resetPassword(
    ResetPasswordRequest request,
  );
}
