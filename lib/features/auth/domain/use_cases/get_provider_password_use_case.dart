import 'package:injectable/injectable.dart';

import '../../../../core/base_response/base_response.dart';
import '../entities/email_provider_status.dart';
import '../repo/auth_repo.dart';

@injectable
class GetProviderPasswordUseCase {
  final AuthRepo _authRepo;

  const GetProviderPasswordUseCase(this._authRepo);

  Future<BaseResponse<String>> call(EmailProviderStatus status) {
    return _authRepo.getProviderPassword(status);
  }
}
