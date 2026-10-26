import 'dart:async';

import 'package:fitness_app/core/base/base_cubit.dart';
import 'package:fitness_app/core/base/cubit_message.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/app/go_routes/routes_names.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/forget_password_request.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/reset_password_request.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/verify_otp_request.dart';
import 'package:fitness_app/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:fitness_app/features/auth/domain/use_cases/send_reset_code_use_case.dart';
import 'package:fitness_app/features/auth/domain/use_cases/verify_reset_code_use_case.dart';
import 'package:injectable/injectable.dart';

import 'forget_password_config.dart';
import 'forget_password_event.dart';
import 'forget_password_state.dart';

@injectable
class ForgetPasswordCubit extends BaseCubit<ForgetPasswordState, BaseUiEvent> {
  final SendResetCodeUseCase _sendCodeUseCase;
  final VerifyResetCodeUseCase _verifyCodeUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  Timer? _resendTimer;

  ForgetPasswordCubit(
    this._sendCodeUseCase,
    this._verifyCodeUseCase,
    this._resetPasswordUseCase,
  ) : super(const ForgetPasswordState());

  void onEvent(ForgetPasswordEvent event) {
    switch (event) {
      case SendResetCode(:final email):
        _sendCode(email);
      case VerifyResetCode(:final otp):
        _verifyCode(otp);
      case ResendResetCode():
        _resendCode();
      case SubmitNewPassword(:final password, :final confirmPassword):
        _resetPassword(password, confirmPassword);
      case GoToPreviousStep():
        _goToPreviousStep();
    }
  }

  Future<void> _sendCode(String email) async {
    if (state.sendCode.isLoading) return;
    emit(state.copyWith(sendCode: const Resource.loading()));

    final result = await _sendCodeUseCase(
      request: ForgetPasswordRequest(email: email),
    );

    switch (result) {
      case SuccessResponse(:final data) when data.success:
        emit(
          state.copyWith(
            sendCode: Resource.success(data),
            step: ForgetPasswordStep.otp,
            email: email,
          ),
        );
        emitSuccess(CubitMessageType.otpSent);
        _startResendCountdown();
      case SuccessResponse(:final data):
        final failure = ValidationFailure(serverMessage: data.message);
        emit(state.copyWith(sendCode: Resource.error(failure)));
        emitFailure(failure);
      case ErrorResponse(:final failure):
        emit(state.copyWith(sendCode: Resource.error(failure)));
        emitFailure(failure);
    }
  }

  Future<void> _verifyCode(String otp) async {
    if (state.verifyCode.isLoading) return;
    emit(state.copyWith(verifyCode: const Resource.loading()));

    final result = await _verifyCodeUseCase(
      request: VerifyOtpRequest(resetCode: otp),
    );

    switch (result) {
      case SuccessResponse(:final data) when data.success:
        emit(
          state.copyWith(
            verifyCode: Resource.success(data),
            step: ForgetPasswordStep.resetPassword,
          ),
        );
      case SuccessResponse(:final data):
        final failure = ValidationFailure(serverMessage: data.message);
        emit(state.copyWith(verifyCode: Resource.error(failure)));
        emitFailure(failure);
      case ErrorResponse(:final failure):
        emit(state.copyWith(verifyCode: Resource.error(failure)));
        emitFailure(failure);
    }
  }

  Future<void> _resendCode() async {
    if (state.resendCode.isLoading || state.isResendCoolingDown) return;
    emit(state.copyWith(resendCode: const Resource.loading()));

    final result = await _sendCodeUseCase(
      request: ForgetPasswordRequest(email: state.email),
    );

    switch (result) {
      case SuccessResponse(:final data) when data.success:
        emit(state.copyWith(resendCode: Resource.success(data)));
        emitSuccess(CubitMessageType.otpSent);
        _startResendCountdown();
      case SuccessResponse(:final data):
        final failure = ValidationFailure(serverMessage: data.message);
        emit(state.copyWith(resendCode: Resource.error(failure)));
        emitFailure(failure);
      case ErrorResponse(:final failure):
        emit(state.copyWith(resendCode: Resource.error(failure)));
        emitFailure(failure);
    }
  }

  Future<void> _resetPassword(String password, String confirmPassword) async {
    if (state.resetPassword.isLoading) return;
    if (password != confirmPassword) {
      emitFailure(const ValidationFailure());
      return;
    }

    emit(state.copyWith(resetPassword: const Resource.loading()));

    final result = await _resetPasswordUseCase(
      request: ResetPasswordRequest(email: state.email, newPassword: password),
    );

    switch (result) {
      case SuccessResponse(:final data) when data.success:
        emit(state.copyWith(resetPassword: Resource.success(data)));
        emitSuccess(CubitMessageType.passwordChanged);
        emitEvent(const NavigateReplacementEvent(AppRoutes.login));
      case SuccessResponse(:final data):
        final failure = ValidationFailure(serverMessage: data.message);
        emit(state.copyWith(resetPassword: Resource.error(failure)));
        emitFailure(failure);
      case ErrorResponse(:final failure):
        emit(state.copyWith(resetPassword: Resource.error(failure)));
        emitFailure(failure);
    }
  }

  void _startResendCountdown() {
    _resendTimer?.cancel();
    emit(state.copyWith(resendSecondsLeft: ForgetPasswordConfig.resendCooldown.inSeconds));
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final next = state.resendSecondsLeft - 1;
      emit(state.copyWith(resendSecondsLeft: next < 0 ? 0 : next));
      if (next <= 0) timer.cancel();
    });
  }

  void _goToPreviousStep() {
    final previous = switch (state.step) {
      ForgetPasswordStep.otp => ForgetPasswordStep.email,
      ForgetPasswordStep.resetPassword => ForgetPasswordStep.otp,
      ForgetPasswordStep.email => ForgetPasswordStep.email,
    };
    if (previous != state.step) {
      emit(state.copyWith(step: previous));
    }
  }

  @override
  Future<void> close() {
    _resendTimer?.cancel();
    return super.close();
  }
}
