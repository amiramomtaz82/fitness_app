import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/contants/endpoints/endpoints.dart';
import '../models/login_request_dto.dart';
import '../models/login_response_dto.dart';
import '../models/register_request_dto.dart';
import '../models/register_response_dto.dart';
import '../models/auth_action_response_dto.dart';
import '../models/forget_password_request_dto.dart';
import '../models/reset_password_request_dto.dart';
import '../models/verify_otp_request_dto.dart';

part 'auth_client.g.dart';

@RestApi()
abstract class AuthClient {
  factory AuthClient(Dio dio, {String baseUrl}) = _AuthClient;

  @POST(Endpoints.signin)
  Future<LoginResponseDto> login(@Body() LoginRequestDto body);

  @POST(Endpoints.signup)
  Future<RegisterResponseDto> register(@Body() RegisterRequestDto request);

  @POST(Endpoints.forgotPassword)
  Future<AuthActionResponseDto> forgotPassword(
    @Body() ForgetPasswordRequestDto body,
  );

  @POST(Endpoints.verifyResetCode)
  Future<AuthActionResponseDto> verifyResetCode(
    @Body() VerifyOtpRequestDto body,
  );

  @PUT(Endpoints.resetPassword)
  Future<AuthActionResponseDto> resetPassword(
    @Body() ResetPasswordRequestDto body,
  );
}
