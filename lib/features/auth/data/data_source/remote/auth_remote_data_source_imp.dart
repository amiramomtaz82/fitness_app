import 'package:injectable/injectable.dart';
import '../../client/auth_client.dart';
import '../../models/login_request_dto.dart';
import '../../models/login_response_dto.dart';
import 'auth_remote_data_source.dart';

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImp implements AuthRemoteDataSource {
  final AuthClient _client;

  const AuthRemoteDataSourceImp(this._client);

  @override
  Future<LoginResponseDto> login(LoginRequestDto request) {
    return _client.login(request);
  }
}
