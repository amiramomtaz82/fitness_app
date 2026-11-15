import 'package:fitness_app/core/base/base_cubit.dart';
import 'package:fitness_app/core/base/cubit_message.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/core/validation/form_validators.dart';
import 'package:fitness_app/core/validation/validation_errors.dart';
import 'package:fitness_app/features/profile/domain/entities/change_password_entity.dart';
import 'package:fitness_app/features/profile/domain/use_cases/change_password_use_case.dart';
import 'package:injectable/injectable.dart';
import 'change_password_field.dart';
import 'change_password_intent.dart';
import 'change_password_state.dart';

@injectable
class ChangePasswordCubit extends BaseCubit<ChangePasswordState, BaseUiEvent> {
  final ChangePasswordUseCase _changePasswordUseCase;

  ChangePasswordCubit(this._changePasswordUseCase)
    : super(const ChangePasswordState());

  void doIntent(ChangePasswordIntent intent) {
    switch (intent) {
      case UpdatePasswordFieldIntent(:final field, :final value):
        _update(field, value);

      case SubmitChangePasswordIntent():
        _changePassword();
    }
  }

  void _update(ChangePasswordField field, String value) {
    _emit(
      state.copyWith(
        currentPassword: field == ChangePasswordField.currentPassword
            ? value
            : state.currentPassword,
        newPassword: field == ChangePasswordField.newPassword
            ? value
            : state.newPassword,
        confirmPassword: field == ChangePasswordField.confirmPassword
            ? value
            : state.confirmPassword,
        fieldErrors: _without(field, state.fieldErrors),
      ),
    );
  }

  Future<void> _changePassword() async {
    if (state.isChanging) return;

    final errors = _validate();

    if (errors.isNotEmpty) {
      _emit(state.copyWith(fieldErrors: errors));
      emitFailure(const ValidationFailure());
      return;
    }

    _emit(state.copyWith(changePasswordResource: const Resource.loading()));

    final response = await _changePasswordUseCase(
      password: state.currentPassword,
      newPassword: state.newPassword,
    );

    switch (response) {
      case SuccessResponse<ChangePasswordEntity>(:final data):
        _emit(state.copyWith(changePasswordResource: Resource.success(data)));

        emitSuccess(CubitMessageType.passwordChanged);
        emitEvent(const PopEvent());

      case ErrorResponse<ChangePasswordEntity>(:final failure):
        _emit(state.copyWith(changePasswordResource: Resource.error(failure)));

        emitFailure(failure);
    }
  }

  Map<ChangePasswordField, ValidationError> _validate() {
    final checks = <ChangePasswordField, ValidationError?>{
      ChangePasswordField.currentPassword: FormValidators.validateRequired(
        state.currentPassword,
      ),

      ChangePasswordField.newPassword: FormValidators.validatePassword(
        state.newPassword,
      ),

      ChangePasswordField.confirmPassword:
          FormValidators.validateConfirmPassword(
            state.newPassword,
            state.confirmPassword,
          ),
    };

    return Map.unmodifiable({
      for (final entry in checks.entries)
        if (entry.value != null) entry.key: entry.value!,
    });
  }

  Map<ChangePasswordField, ValidationError> _without(
    ChangePasswordField field,
    Map<ChangePasswordField, ValidationError> errors,
  ) {
    if (!errors.containsKey(field)) return errors;

    final copy = Map<ChangePasswordField, ValidationError>.of(errors)
      ..remove(field);

    return Map.unmodifiable(copy);
  }

  void _emit(ChangePasswordState newState) {
    if (isClosed) return;
    emit(newState);
  }
}
