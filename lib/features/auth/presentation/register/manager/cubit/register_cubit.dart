import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../../../core/base/base_cubit.dart';
import '../../../../../../core/base/ui_events.dart';
import '../../../../../../core/base_response/base_response.dart';
import '../../../../../../core/resource/resource.dart';
import '../../../../../../core/validation/form_validators.dart';
import '../../../../../../core/validation/validation_errors.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../../../domain/entities/register_parameters.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../domain/use_cases/register_use_case.dart';
import '../../registration_measurement_rules.dart';
import '../../registration_options.dart';
import 'register_intent.dart';
import 'register_state.dart';

@injectable
class RegisterCubit extends BaseCubit<RegisterState, BaseUiEvent> {
  final RegisterUseCase _registerUseCase;

  RegisterCubit(this._registerUseCase) : super(const RegisterState());

  void doIntent(RegisterIntent intent) {
    switch (intent) {
      case TogglePasswordVisibilityIntent():
        _togglePasswordVisibility();
      case NextStepIntent():
        _nextStep();
      case GoBackIntent():
        _goBack();
      case SubmitRegistrationIntent():
        _guardSubmission();
      case SelectGenderIntent():
      case SelectAgeIntent():
      case SelectWeightIntent():
      case SelectHeightIntent():
      case SelectGoalIntent():
      case SelectActivityIntent():
        _select(intent);
    }
  }

  void _togglePasswordVisibility() {
    emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
  }

  void _select(RegisterIntent intent) {
    switch (intent) {
      case SelectGenderIntent(:final gender):
        _selectGender(gender);
      case SelectAgeIntent(:final age):
        _selectAge(age);
      case SelectWeightIntent(:final weight):
        _selectWeight(weight);
      default:
        _selectOption(intent);
    }
  }

  void _selectOption(RegisterIntent intent) {
    switch (intent) {
      case SelectHeightIntent(:final height):
        _selectHeight(height);
      case SelectGoalIntent(:final goal, :final label):
        _rememberGoal(goal, label);
      case SelectActivityIntent(:final activity, :final label):
        _rememberActivity(activity, label);
      default:
        return;
    }
  }

  void _selectGender(String gender) {
    final normalized = gender.trim().toLowerCase();
    if (FormValidators.validateGender(normalized) != null) {
      return;
    }
    _emitParams(state.params.copyWith(gender: normalized));
  }

  void _selectAge(int age) {
    if (!RegistrationMeasurementRules.isValidAge(age)) {
      return;
    }
    _emitParams(state.params.copyWith(age: age));
  }

  void _selectWeight(num weight) {
    if (!RegistrationMeasurementRules.isValidWeight(weight)) {
      return;
    }
    _emitParams(state.params.copyWith(weight: weight));
  }

  void _selectHeight(num height) {
    if (!RegistrationMeasurementRules.isValidHeight(height)) {
      return;
    }
    _emitParams(state.params.copyWith(height: height));
  }

  void _rememberGoal(RegistrationGoal goal, String label) {
    emit(
      state.copyWith(
        selectedGoal: goal,
        params: state.params.copyWith(goal: label),
      ),
    );
  }

  void _rememberActivity(RegistrationActivity activity, String label) {
    emit(
      state.copyWith(
        selectedActivity: activity,
        params: state.params.copyWith(activityLevel: label),
      ),
    );
  }

  void _nextStep() {
    final message = _blockedMessage(state);
    if (message != null) {
      _rejectStep(message);
      return;
    }
    if (state.currentStep >= RegistrationMeasurementRules.lastStepIndex) {
      return;
    }
    _advanceStep();
  }

  void _rejectStep(String message) {
    emitEvent(ShowSnackBarEvent(message: message, isError: true));
  }

  void _advanceStep() {
    final nextStep = state.currentStep + 1;
    final params = RegistrationMeasurementRules.withStepDefaults(
      nextStep,
      state.params,
    );
    emit(state.copyWith(currentStep: nextStep, params: params));
  }

  void _goBack() {
    if (state.currentStep == RegistrationMeasurementRules.firstStepIndex) {
      emitEvent(const PopEvent());
      return;
    }
    emit(state.copyWith(currentStep: state.currentStep - 1));
  }

  void _guardSubmission() {
    if (_submissionIsClosed || !_canSubmitLater()) {
      return;
    }
    emit(state.copyWith(registerResource: const Resource.loading()));
    unawaited(_register(state.params));
  }

  Future<void> _register(RegisterParameters params) async {
    final result = await _registerUseCase(params);
    if (isClosed) return;
    switch (result) {
      case SuccessResponse(:final data):
        _showSuccess(data);
      case final ErrorResponse<UserEntity> failure:
        _showFailure(failure.errMessage);
    }
  }

  void _showSuccess(UserEntity user) {
    emit(state.copyWith(registerResource: Resource.success(user)));
    emitEvent(const ShowSnackBarEvent(message: LocaleKeys.auth_done));
  }

  void _showFailure(String message) {
    emit(state.copyWith(registerResource: Resource.error(message)));
    emitEvent(ShowSnackBarEvent(message: message, isError: true));
  }

  bool get _submissionIsClosed =>
      state.registerResource.isLoading || state.registerResource.isSuccess;

  bool _canSubmitLater() {
    if (state.currentStep != RegistrationMeasurementRules.lastStepIndex) {
      return false;
    }
    if (!_canLeave(state) || !_credentialsAreValid(state.params)) {
      return false;
    }
    return _hasGoalAndActivity(state);
  }

  bool _canLeave(RegisterState current) => _blockedMessage(current) == null;

  String? _blockedMessage(RegisterState current) {
    final params = current.params;
    return switch (current.currentStep) {
      0 => _genderMessage(params.gender),
      1 => _ageMessage(params.age),
      2 => _weightMessage(params.weight),
      3 => _heightMessage(params.height),
      4 => _choiceMessage(current.selectedGoal != null),
      5 => _choiceMessage(current.selectedActivity != null),
      _ => LocaleKeys.validation_field_required,
    };
  }

  String? _choiceMessage(bool selected) {
    if (selected) return null;
    return LocaleKeys.validation_field_required;
  }

  String? _genderMessage(String gender) {
    final error = FormValidators.validateGender(gender);
    if (error == null) return null;
    return _validationKey(error);
  }

  String? _ageMessage(int age) {
    if (RegistrationMeasurementRules.isValidAge(age)) return null;
    if (RegistrationMeasurementRules.isAgeUnset(age)) {
      return LocaleKeys.validation_field_required;
    }
    if (age < RegistrationMeasurementRules.minimumAge) {
      return LocaleKeys.validation_value_below_minimum;
    }
    return LocaleKeys.validation_value_above_maximum;
  }

  String? _weightMessage(num weight) {
    if (RegistrationMeasurementRules.isValidWeight(weight)) return null;
    if (RegistrationMeasurementRules.isWeightUnset(weight)) {
      return LocaleKeys.validation_field_required;
    }
    final error = FormValidators.validateWeight('$weight');
    return _validationKey(error ?? ValidationError.empty);
  }

  String? _heightMessage(num height) {
    if (RegistrationMeasurementRules.isValidHeight(height)) return null;
    if (RegistrationMeasurementRules.isHeightUnset(height)) {
      return LocaleKeys.validation_field_required;
    }
    if (height < RegistrationMeasurementRules.minimumHeightCm) {
      return LocaleKeys.validation_value_below_minimum;
    }
    return LocaleKeys.validation_value_above_maximum;
  }

  String _validationKey(ValidationError error) {
    return switch (error) {
      ValidationError.empty => LocaleKeys.validation_field_required,
      ValidationError.invalidGender => LocaleKeys.validation_invalid_gender,
      ValidationError.notANumber => LocaleKeys.validation_not_a_number,
      ValidationError.valueBelowMinimum =>
        LocaleKeys.validation_value_below_minimum,
      ValidationError.valueAboveMaximum =>
        LocaleKeys.validation_value_above_maximum,
      ValidationError.invalidEmail ||
      ValidationError.passwordTooShort ||
      ValidationError.passwordMissingNumber ||
      ValidationError.passwordMissingUppercase ||
      ValidationError.passwordsDoNotMatch ||
      ValidationError.invalidPhoneNumber =>
        LocaleKeys.validation_field_required,
    };
  }

  bool _credentialsAreValid(RegisterParameters params) {
    if (FormValidators.validateRequired(params.firstName) != null) {
      return false;
    }
    if (FormValidators.validateRequired(params.lastName) != null) {
      return false;
    }
    if (FormValidators.validateEmail(params.email) != null) {
      return false;
    }
    return FormValidators.validatePassword(params.password) == null;
  }

  bool _hasGoalAndActivity(RegisterState current) {
    final params = current.params;
    return params.goal.trim().isNotEmpty &&
        params.activityLevel.trim().isNotEmpty;
  }

  void _emitParams(RegisterParameters params) {
    emit(state.copyWith(params: params));
  }
}
