import 'package:injectable/injectable.dart';
import '../../../../core/base_response/base_response.dart';
import '../entities/login_params.dart';
import '../entities/user_entity.dart';
import '../repo/auth_repo.dart';

@injectable
class LoginUseCase {
  final AuthRepo _authRepo;

  const LoginUseCase(this._authRepo);

  Future<BaseResponse<UserEntity>> call(LoginParams params) {
    return _authRepo.login(params);
  }
}
