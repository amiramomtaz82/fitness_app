import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/contants/endpoints/endpoints.dart';
import '../models/login_request_dto.dart';
import '../models/login_response_dto.dart';

part 'auth_client.g.dart';

@RestApi()
abstract class AuthClient {
  factory AuthClient(Dio dio, {String baseUrl}) = _AuthClient;

  @POST(Endpoints.signin)
  Future<LoginResponseDto> login(@Body() LoginRequestDto body);
}
