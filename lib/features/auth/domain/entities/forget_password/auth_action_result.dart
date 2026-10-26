import 'package:equatable/equatable.dart';

class AuthActionResult extends Equatable {
  final bool success;
  final String? message;

  const AuthActionResult({required this.success, this.message});

  @override
  List<Object?> get props => [success, message];
}
