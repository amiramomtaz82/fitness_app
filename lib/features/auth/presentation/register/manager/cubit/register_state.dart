import 'package:equatable/equatable.dart';

import '../../../../../../core/resource/resource.dart';
import '../../../../domain/entities/register_parameters.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../registration_options.dart';

class RegisterState extends Equatable {
  final RegisterParameters params;
  final Resource<UserEntity> registerResource;
  final bool isPasswordObscured;
  final int currentStep;
  final RegistrationGoal? selectedGoal;
  final RegistrationActivity? selectedActivity;

  const RegisterState({
    this.params = const RegisterParameters(),
    this.registerResource = const Resource.initial(),
    this.isPasswordObscured = true,
    this.currentStep = 0,
    this.selectedGoal,
    this.selectedActivity,
  }) : assert(
         currentStep >= 0 && currentStep <= 5,
         'currentStep must stay between 0 and 5',
       );

  RegisterState copyWith({
    RegisterParameters? params,
    Resource<UserEntity>? registerResource,
    bool? isPasswordObscured,
    int? currentStep,
    RegistrationGoal? selectedGoal,
    RegistrationActivity? selectedActivity,
  }) {
    return RegisterState(
      params: params ?? this.params,
      registerResource: registerResource ?? this.registerResource,
      isPasswordObscured: isPasswordObscured ?? this.isPasswordObscured,
      currentStep: currentStep ?? this.currentStep,
      selectedGoal: selectedGoal ?? this.selectedGoal,
      selectedActivity: selectedActivity ?? this.selectedActivity,
    );
  }

  @override
  List<Object?> get props => [
    params,
    registerResource,
    isPasswordObscured,
    currentStep,
    selectedGoal,
    selectedActivity,
  ];
}
