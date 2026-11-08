import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import '../../../../core/contants/endpoints/endpoints.dart';
import '../../../../core/contants/endpoints/query_params.dart';
import '../models/profile_request_dto.dart';
import '../models/profile_response_dto.dart';

part 'profile_client.g.dart';

@RestApi()
abstract class ProfileClient {
  factory ProfileClient(Dio dio, {String baseUrl}) = _ProfileClient;

  @GET(Endpoints.profileData)
  Future<ProfileResponseDto> getProfile();

  @PUT(Endpoints.uploadPhoto)
  @MultiPart()
  Future<ProfileResponseDto> uploadPhoto(
    @Part(name: QueryParams.photo) MultipartFile photo,
  );

  @PUT(Endpoints.editProfile)
  Future<ProfileResponseDto> editProfile(@Body() ProfileRequestDto body);
}
