import 'package:injectable/injectable.dart';
import '../../../../core/base_response/base_response.dart';
import '../entities/profile_entity.dart';
import '../repo/profile_repo.dart';

@injectable
class UploadPhotoUseCase {
  final ProfileRepo _profileRepo;

  const UploadPhotoUseCase(this._profileRepo);

  Future<BaseResponse<ProfileEntity>> call(String photoPath) {
    return _profileRepo.uploadPhoto(photoPath);
  }
}
