import 'package:injectable/injectable.dart';
import '../../client/auth_client.dart';
import '../../models/register_request_dto.dart';
import '../../models/register_response_dto.dart';
import 'auth_remote_data_source.dart';

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImp implements AuthRemoteDataSource {
  // ignore: unused_field
  final AuthClient _client;

  const AuthRemoteDataSourceImp(this._client);

  @override
  Future<RegisterResponseDto> register(RegisterRequestDto request) {
    return _client.register(request);
  }
}
