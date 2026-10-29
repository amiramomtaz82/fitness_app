import 'package:equatable/equatable.dart';
import 'package:fitness_app/core/resource/resource.dart';

import 'package:fitness_app/features/auth/domain/entities/forget_password/auth_action_result.dart';

enum ForgetPasswordStep { email, otp, resetPassword }

class ForgetPasswordState extends Equatable {
  final ForgetPasswordStep step;
  final String email;
  final Resource<AuthActionResult> sendCode;
  final Resource<AuthActionResult> verifyCode;
  final Resource<AuthActionResult> resendCode;
  final Resource<AuthActionResult> resetPassword;
  final int resendSecondsLeft;

  const ForgetPasswordState({
    this.step = ForgetPasswordStep.email,
    this.email = '',
    this.sendCode = const Resource.initial(),
    this.verifyCode = const Resource.initial(),
    this.resendCode = const Resource.initial(),
    this.resetPassword = const Resource.initial(),
    this.resendSecondsLeft = 0,
  });

  bool get isFirstStep => step == ForgetPasswordStep.email;

  bool get isResendCoolingDown => resendSecondsLeft > 0;

  ForgetPasswordState copyWith({
    ForgetPasswordStep? step,
    String? email,
    Resource<AuthActionResult>? sendCode,
    Resource<AuthActionResult>? verifyCode,
    Resource<AuthActionResult>? resendCode,
    Resource<AuthActionResult>? resetPassword,
    int? resendSecondsLeft,
  }) {
    return ForgetPasswordState(
      step: step ?? this.step,
      email: email ?? this.email,
      sendCode: sendCode ?? this.sendCode,
      verifyCode: verifyCode ?? this.verifyCode,
      resendCode: resendCode ?? this.resendCode,
      resetPassword: resetPassword ?? this.resetPassword,
      resendSecondsLeft: resendSecondsLeft ?? this.resendSecondsLeft,
    );
  }

  @override
  List<Object?> get props => [
    step,
    email,
    sendCode,
    verifyCode,
    resendCode,
    resetPassword,
    resendSecondsLeft,
  ];
}
