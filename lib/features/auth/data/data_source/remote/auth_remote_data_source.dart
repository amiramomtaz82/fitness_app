import '../../models/login_request_dto.dart';
import '../../models/login_response_dto.dart';
import '../../models/register_request_dto.dart';
import '../../models/register_response_dto.dart';

abstract interface class AuthRemoteDataSource {
  Future<LoginResponseDto> login(LoginRequestDto request);
  Future<RegisterResponseDto> register(RegisterRequestDto request);
}
