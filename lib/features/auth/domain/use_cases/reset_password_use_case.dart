import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/auth_action_result.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/reset_password_request.dart';
import 'package:fitness_app/features/auth/domain/repo/auth_repo.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class ResetPasswordUseCase {
  final AuthRepo _repo;

  const ResetPasswordUseCase(this._repo);

  Future<BaseResponse<AuthActionResult>> call({
    required ResetPasswordRequest request,
  }) => _repo.resetPassword(request);
}
