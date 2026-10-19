import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../features/auth/data/client/auth_client.dart';

@module
abstract class AuthDiModule {
  @lazySingleton
  AuthClient authClient(Dio dio) => AuthClient(dio);
}
