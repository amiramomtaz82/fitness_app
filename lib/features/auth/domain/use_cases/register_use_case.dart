import 'package:injectable/injectable.dart';
import '../../../../core/base_response/base_response.dart';
import '../entities/register_parameters.dart';
import '../entities/user_entity.dart';
import '../repo/auth_repo.dart';

@injectable
class RegisterUseCase {
  final AuthRepo _repo;

  const RegisterUseCase(this._repo);

  Future<BaseResponse<UserEntity>> call(RegisterParameters params) {
    return _repo.register(params);
  }
}
