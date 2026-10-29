import 'package:equatable/equatable.dart';

sealed class ForgetPasswordEvent extends Equatable {
  const ForgetPasswordEvent();

  @override
  List<Object?> get props => [];
}

class SendResetCode extends ForgetPasswordEvent {
  final String email;

  const SendResetCode({required this.email});

  @override
  List<Object?> get props => [email];
}

class VerifyResetCode extends ForgetPasswordEvent {
  final String otp;

  const VerifyResetCode({required this.otp});

  @override
  List<Object?> get props => [otp];
}

class ResendResetCode extends ForgetPasswordEvent {
  const ResendResetCode();
}

class SubmitNewPassword extends ForgetPasswordEvent {
  final String password;
  final String confirmPassword;

  const SubmitNewPassword({
    required this.password,
    required this.confirmPassword,
  });

  @override
  List<Object?> get props => [password, confirmPassword];
}

class GoToPreviousStep extends ForgetPasswordEvent {
  const GoToPreviousStep();
}
