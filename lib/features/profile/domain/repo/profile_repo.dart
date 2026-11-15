import '../../../../core/base_response/base_response.dart';
import '../entities/profile_entity.dart';
import '../entities/profile_params.dart';

abstract interface class ProfileRepo {
  Future<BaseResponse<ProfileEntity>> getProfile();

  Future<BaseResponse<ProfileEntity>> uploadPhoto(String photoPath);

  Future<BaseResponse<ProfileEntity>> editProfile(ProfileParams params);
  Future<BaseResponse<void>> logout();
}
