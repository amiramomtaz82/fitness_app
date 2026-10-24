import 'package:equatable/equatable.dart';

import '../../../../../../core/resource/resource.dart';
import '../../../../domain/entities/register_parameters.dart';
import '../../../../domain/entities/user_entity.dart';

class RegisterState extends Equatable {
  final RegisterParameters params;
  final Resource<UserEntity> registerResource;
  final bool isPasswordObscured; // Screen 1 specific UI state

  const RegisterState({
    this.params = const RegisterParameters(),
    this.registerResource = const Resource.initial(),
    this.isPasswordObscured = true,
  });

  RegisterState copyWith({
    RegisterParameters? params,
    Resource<UserEntity>? registerResource,
    bool? isPasswordObscured,
  }) {
    return RegisterState(
      params: params ?? this.params,
      registerResource: registerResource ?? this.registerResource,
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
    );
  }

  @override
  List<Object?> get props => [params, registerResource, isPasswordObscured];
}
