import 'package:injectable/injectable.dart';

import '../../../../core/base_response/base_response.dart';
import '../entities/email_provider_status.dart';
import '../repo/auth_repo.dart';

@injectable
class CheckEmailProviderUseCase {
  final AuthRepo _authRepo;

  const CheckEmailProviderUseCase(this._authRepo);

  Future<BaseResponse<EmailProviderStatus>> call(String email) {
    return _authRepo.checkEmailProvider(email);
  }
}
