// ignore_for_file: unused_field

import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../../../core/contants/endpoints/endpoints.dart';
import '../models/register_request_dto.dart';
import '../models/register_response_dto.dart';

part 'auth_client.g.dart';

@RestApi()
abstract class AuthClient {
  factory AuthClient(Dio dio, {String baseUrl}) = _AuthClient;

  @POST(Endpoints.signup)
  Future<RegisterResponseDto> register(@Body() RegisterRequestDto request);
}
