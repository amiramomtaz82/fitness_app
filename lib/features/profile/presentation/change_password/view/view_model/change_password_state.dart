
import 'package:equatable/equatable.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/core/validation/validation_errors.dart';
import 'package:fitness_app/features/profile/domain/entities/change_password_entity.dart';

import 'change_password_field.dart';

class ChangePasswordState extends Equatable {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;

  final Map<ChangePasswordField, ValidationError> fieldErrors;

  final Resource<ChangePasswordEntity> changePasswordResource;

  const ChangePasswordState({
    this.currentPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.fieldErrors = const {},
    this.changePasswordResource = const Resource.initial(),
  });

  bool get isChanging => changePasswordResource.isLoading;

  ValidationError? errorOf(ChangePasswordField field) => fieldErrors[field];

  ChangePasswordState copyWith({
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
    Map<ChangePasswordField, ValidationError>? fieldErrors,
    Resource<ChangePasswordEntity>? changePasswordResource,
  }) {
    return ChangePasswordState(
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      fieldErrors: fieldErrors ?? this.fieldErrors,
      changePasswordResource:
          changePasswordResource ?? this.changePasswordResource,
    );
  }

  @override
  List<Object?> get props => [
    currentPassword,
    newPassword,
    confirmPassword,
    fieldErrors,
    changePasswordResource,
  ];
}
