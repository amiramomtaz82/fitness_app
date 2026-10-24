import '../../models/login_request_dto.dart';
import '../../models/login_response_dto.dart';

abstract interface class AuthRemoteDataSource {
  Future<LoginResponseDto> login(LoginRequestDto request);
}
