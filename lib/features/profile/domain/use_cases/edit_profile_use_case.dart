import 'package:injectable/injectable.dart';
import '../../../../core/base_response/base_response.dart';
import '../entities/profile_entity.dart';
import '../entities/profile_params.dart';
import '../repo/profile_repo.dart';

@injectable
class EditProfileUseCase {
  final ProfileRepo _profileRepo;

  const EditProfileUseCase(this._profileRepo);

  Future<BaseResponse<ProfileEntity>> call(ProfileParams params) {
    return _profileRepo.editProfile(params);
  }
}
