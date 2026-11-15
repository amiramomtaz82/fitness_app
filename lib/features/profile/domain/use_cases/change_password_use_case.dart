import 'package:injectable/injectable.dart';

import '../../../../core/base_response/base_response.dart';
import '../entities/change_password_entity.dart';
import '../repo/profile_repo.dart';

@injectable
class ChangePasswordUseCase {
  final ProfileRepo _profileRepo;

  const ChangePasswordUseCase(this._profileRepo);

  Future<BaseResponse<ChangePasswordEntity>> call({
    required String password,
    required String newPassword,
  }) {
    return _profileRepo.changePassword(
      password: password,
      newPassword: newPassword,
    );
  }
}
