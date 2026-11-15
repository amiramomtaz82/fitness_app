import 'package:injectable/injectable.dart';
import '../../../../core/base_response/base_response.dart';
import '../entities/profile_entity.dart';
import '../repo/profile_repo.dart';

@injectable
class GetProfileUseCase {
  final ProfileRepo _profileRepo;

  const GetProfileUseCase(this._profileRepo);

  Future<BaseResponse<ProfileEntity>> call() {
    return _profileRepo.getProfile();
  }
}
