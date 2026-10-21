import 'package:injectable/injectable.dart';
import '../../../../../core/base/base_cubit.dart';
import '../../../../../core/base/cubit_message.dart';
import '../../../../../core/base/ui_events.dart';
import '../../../../../core/base_response/base_response.dart';
import '../../../../../core/error/failure_mapper.dart';
import '../../../../../core/error/failures.dart';
import '../../../../../core/go_routes/routes_names.dart';
import '../../../../../core/resource/resource.dart';
import '../../../domain/entities/login_params.dart';
import '../../../domain/entities/user_entity.dart';
import '../../../domain/use_cases/login_use_case.dart';
import 'login_intent.dart';
import 'login_state.dart';

@injectable
class LoginCubit extends BaseCubit<LoginState, BaseUiEvent> {
  final LoginUseCase _loginUseCase;

  LoginCubit(this._loginUseCase) : super(const LoginState());

  void doIntent(LoginIntent intent) {
    switch (intent) {
      case LoginSubmittedIntent():
        _login(intent.email, intent.password);
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
    final message = FailureMapper.mapToMessage(failure);
    emit(state.copyWith(loginResource: Resource.error(message)));
    // A 401 here means wrong credentials, not an expired session,
    // so always show the message instead of the default redirect.
    emitEvent(ShowSnackBarEvent(message: message, isError: true));
  }

  void _onLoginSuccess(UserEntity user) {
    emit(state.copyWith(loginResource: Resource.success(user)));
    emitSuccess(CubitMessageType.loginSuccess);
    emitEvent(const NavigateReplacementEvent(AppRoutes.home));
  }
}
