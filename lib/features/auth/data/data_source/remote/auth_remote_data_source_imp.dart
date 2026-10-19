import 'package:injectable/injectable.dart';
import '../../client/auth_client.dart';
import 'auth_remote_data_source.dart';

@Injectable(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImp implements AuthRemoteDataSource {
  // ignore: unused_field
  final AuthClient _client;

  const AuthRemoteDataSourceImp(this._client);
}
