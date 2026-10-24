import 'package:equatable/equatable.dart';
import '../../../../../core/resource/resource.dart';
import '../../../domain/entities/user_entity.dart';

class LoginState extends Equatable {
  final Resource<UserEntity> loginResource;
  final bool isPasswordObscured;

  const LoginState({
    this.loginResource = const Resource.initial(),
    this.isPasswordObscured = true,
  });

  LoginState copyWith({
    Resource<UserEntity>? loginResource,
    bool? isPasswordObscured,
  }) {
    return LoginState(
      loginResource: loginResource ?? this.loginResource,
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
    );
  }

  @override
  List<Object?> get props => [loginResource, isPasswordObscured];
}
