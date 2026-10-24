import 'package:injectable/injectable.dart';

import '../../../../core/base_response/base_response.dart';
import '../entities/social_auth_user.dart';
import '../repo/auth_repo.dart';

@injectable
class SignInWithGoogleUseCase {
  final AuthRepo _authRepo;

  const SignInWithGoogleUseCase(this._authRepo);

  Future<BaseResponse<SocialAuthUser?>> call() {
    return _authRepo.signInWithGoogle();
  }
}