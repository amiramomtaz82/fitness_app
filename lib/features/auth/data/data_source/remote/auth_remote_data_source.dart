import '../../models/register_request_dto.dart';
import '../../models/register_response_dto.dart';

abstract class AuthRemoteDataSource {
  Future<RegisterResponseDto> register(RegisterRequestDto request);
}
