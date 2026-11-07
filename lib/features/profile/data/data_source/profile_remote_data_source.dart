import 'package:fitness_app/features/profile/data/models/change_password_request_dto.dart';
import 'package:fitness_app/features/profile/data/models/change_password_response_dto.dart';

import '../models/profile_request_dto.dart';
import '../models/profile_response_dto.dart';

abstract interface class ProfileRemoteDataSource {
  Future<ProfileResponseDto> getProfile();

  Future<ProfileResponseDto> uploadPhoto(String photoPath);

  Future<ProfileResponseDto> editProfile(ProfileRequestDto request);
  Future<ChangePasswordResponseDto> changePassword(
    ChangePasswordRequestDto request,
  );
}
