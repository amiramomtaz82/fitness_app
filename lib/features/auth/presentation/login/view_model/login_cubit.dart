import 'package:injectable/injectable.dart';
import '../../../../../core/base/base_cubit.dart';
import '../../../../../core/base/cubit_message.dart';
import '../../../../../core/base/ui_events.dart';
import '../../../../../core/base_response/base_response.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../app/routes_names.dart';
import '../../../../../core/resource/resource.dart';
import '../../../domain/entities/email_provider_status.dart';
import '../../../domain/entities/login_params.dart';
import '../../../domain/entities/social_auth_user.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/use_cases/get_provider_password_use_case.dart';
import '../../../domain/use_cases/login_use_case.dart';
import '../../../domain/use_cases/sign_in_with_facebook_use_case.dart';
import '../../../domain/use_cases/sign_in_with_google_use_case.dart';
import 'login_intent.dart';
import 'login_state.dart';

typedef _SocialSignIn = Future<BaseResponse<SocialAuthUser?>> Function();

@injectable
class LoginCubit extends BaseCubit<LoginState, BaseUiEvent> {
  final LoginUseCase _loginUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInWithFacebookUseCase _signInWithFacebookUseCase;
  final GetProviderPasswordUseCase _getProviderPasswordUseCase;

  LoginCubit(
    this._loginUseCase,
    this._signInWithGoogleUseCase,
    this._signInWithFacebookUseCase,
    this._getProviderPasswordUseCase,
  ) : super(const LoginState());

  void doIntent(LoginIntent intent) {
    switch (intent) {
      case LoginSubmittedIntent():
        _login(intent.email, intent.password);
      case SignInWithGoogleIntent():
        _socialLogin(
          _signInWithGoogleUseCase.call,
          EmailProviderStatus.registeredWithGoogle,
        );
      case SignInWithFacebookIntent():
        _socialLogin(
          _signInWithFacebookUseCase.call,
          EmailProviderStatus.registeredWithFacebook,
        );
      case TogglePasswordVisibilityIntent():
        emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
      case NavigateToRegisterIntent():
        emitEvent(const NavigateEvent(AppRoutes.register));
      case NavigateToForgetPasswordIntent():
        emitEvent(const NavigateEvent(AppRoutes.forgetPassword));
    }
  }

  Future<void> _login(String email, String password) async {
    if (state.loginResource.isLoading) return;
    emit(state.copyWith(loginResource: const Resource.loading()));
    await _submitLogin(email, password);
  }

  /// Social accounts sign in to the backend with their email and the
  /// shared provider password they were registered with.
  Future<void> _socialLogin(
    _SocialSignIn signIn,
    EmailProviderStatus provider,
  ) async {
    if (state.loginResource.isLoading) return;
    emit(state.copyWith(loginResource: const Resource.loading()));
    final result = await signIn();
    switch (result) {
      case SuccessResponse(data: final user?):
        await _loginWithProvider(user.email, provider);
      case SuccessResponse():
        emit(state.copyWith(loginResource: const Resource.initial()));
      case ErrorResponse(:final failure):
        _onLoginFailure(failure);
    }
  }

  Future<void> _loginWithProvider(
    String email,
    EmailProviderStatus provider,
  ) async {
    final result = await _getProviderPasswordUseCase(provider);
    switch (result) {
      case SuccessResponse(data: final password):
        await _submitLogin(email, password);
      case ErrorResponse(:final failure):
        _onLoginFailure(failure);
    }
  }

  Future<void> _submitLogin(String email, String password) async {
    final response = await _loginUseCase(
      LoginParams(email: email.trim(), password: password),
    );
    switch (response) {
      case SuccessResponse<UserEntity>():
        _onLoginSuccess(response.data);
      case ErrorResponse<UserEntity>():
        _onLoginFailure(response.failure);
    }
  }

  void _onLoginFailure(Failure failure) {
    emit(state.copyWith(loginResource: Resource.error(failure)));
    emitFailure(failure);
  }

  void _onLoginSuccess(UserEntity user) {
    emit(state.copyWith(loginResource: Resource.success(user)));
    emitSuccess(CubitMessageType.loginSuccess);
    emitEvent(const NavigateReplacementEvent(AppRoutes.home));
  }
}
