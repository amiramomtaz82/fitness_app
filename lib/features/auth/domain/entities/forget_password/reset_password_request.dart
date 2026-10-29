import 'package:equatable/equatable.dart';

class ResetPasswordRequest extends Equatable {
  final String email;
  final String newPassword;

  const ResetPasswordRequest({required this.email, required this.newPassword});

  @override
  List<Object?> get props => [email, newPassword];
}
