import '../models/profile_request_dto.dart';
import '../models/profile_response_dto.dart';

abstract interface class ProfileRemoteDataSource {
  Future<ProfileResponseDto> getProfile();

  Future<ProfileResponseDto> uploadPhoto(String photoPath);

  Future<ProfileResponseDto> editProfile(ProfileRequestDto request);
}
