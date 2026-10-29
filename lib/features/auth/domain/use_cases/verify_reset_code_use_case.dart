import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/auth_action_result.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/verify_otp_request.dart';
import 'package:fitness_app/features/auth/domain/repo/auth_repo.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class VerifyResetCodeUseCase {
  final AuthRepo _repo;

  const VerifyResetCodeUseCase(this._repo);

  Future<BaseResponse<AuthActionResult>> call({
    required VerifyOtpRequest request,
  }) => _repo.verifyResetCode(request);
}
