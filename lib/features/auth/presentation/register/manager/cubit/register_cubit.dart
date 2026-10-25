import 'dart:async';

import 'package:injectable/injectable.dart';

import '../../../../../../core/base/base_cubit.dart';
import '../../../../../../core/base/cubit_message.dart';
import '../../../../../../core/base/ui_events.dart';
import '../../../../../../core/base_response/base_response.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/resource/resource.dart';
import '../../../../../../core/validation/form_validators.dart';
import '../../../../../../core/validation/validation_errors.dart';
import '../../../../domain/entities/register_parameters.dart';
import '../../../../domain/entities/user_entity.dart';
import '../../../../domain/use_cases/register_use_case.dart';
import '../../registration_measurement_rules.dart';
import '../../registration_options.dart';
import 'register_intent.dart';
import 'register_state.dart';
import 'registration_validation_event.dart';

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
      case ReleasePagingIntent():
        _releasePaging();
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
    final error = _ageError(age);
    if (error != null) {
      emitEvent(RegistrationValidationEvent(error));
      return;
    }
    _emitParams(state.params.copyWith(age: age));
  }

  void _selectWeight(num weight) {
    final error = _weightError(weight);
    if (error != null) {
      emitEvent(RegistrationValidationEvent(error));
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
    final error = _stepError(state);
    if (error != null) {
      emitEvent(RegistrationValidationEvent(error));
      return;
    }
    if (state.currentStep >= RegistrationMeasurementRules.lastStepIndex) {
      return;
    }
    _advanceStep();
  }

  void _advanceStep() {
    final nextStep = state.currentStep + 1;
    final params = RegistrationMeasurementRules.withStepDefaults(
      nextStep,
      state.params,
    );
    emit(state.copyWith(currentStep: nextStep, params: params, isPaging: true));
    emitEvent(RegistrationStepChangedEvent(nextStep));
  }

  void _goBack() {
    if (state.currentStep == RegistrationMeasurementRules.firstStepIndex) {
      emitEvent(const PopEvent());
      return;
    }
    final step = state.currentStep - 1;
    emit(state.copyWith(currentStep: step, isPaging: true));
    emitEvent(RegistrationStepChangedEvent(step));
  }

  void _releasePaging() {
    if (!state.isPaging) return;
    emit(state.copyWith(isPaging: false));
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
    _publishRegistration(result);
  }

  void _publishRegistration(BaseResponse<UserEntity> result) {
    switch (result) {
      case SuccessResponse(:final data):
        _showSuccess(data);
      case final ErrorResponse<UserEntity> response:
        _showFailure(response.failure);
    }
  }

  void _showSuccess(UserEntity user) {
    emit(state.copyWith(registerResource: Resource.success(user)));
    emitSuccess(CubitMessageType.registerSuccess);
  }

  void _showFailure(Failure failure) {
    emit(state.copyWith(registerResource: Resource.error(failure)));
    emitFailure(failure);
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

  bool _canLeave(RegisterState current) => _stepError(current) == null;

  ValidationError? _stepError(RegisterState current) {
    final params = current.params;
    return switch (current.currentStep) {
      0 => FormValidators.validateGender(params.gender),
      1 => _ageError(params.age),
      2 => _weightError(params.weight),
      3 => _heightError(params.height),
      4 => _choiceError(current.selectedGoal != null),
      5 => _choiceError(current.selectedActivity != null),
      _ => ValidationError.empty,
    };
  }

  ValidationError? _choiceError(bool selected) {
    if (selected) return null;
    return ValidationError.empty;
  }

  ValidationError? _ageError(int age) {
    if (RegistrationMeasurementRules.isValidAge(age)) return null;
    if (RegistrationMeasurementRules.isAgeUnset(age)) {
      return ValidationError.empty;
    }
    if (age < RegistrationMeasurementRules.minimumAge) {
      return ValidationError.valueBelowMinimum;
    }
    return ValidationError.valueAboveMaximum;
  }

  ValidationError? _weightError(num weight) {
    if (RegistrationMeasurementRules.isValidWeight(weight)) return null;
    if (RegistrationMeasurementRules.isWeightUnset(weight)) {
      return ValidationError.empty;
    }
    if (weight < RegistrationMeasurementRules.minimumWeightKg) {
      return ValidationError.valueBelowMinimum;
    }
    return ValidationError.valueAboveMaximum;
  }

  ValidationError? _heightError(num height) {
    if (RegistrationMeasurementRules.isValidHeight(height)) return null;
    if (RegistrationMeasurementRules.isHeightUnset(height)) {
      return ValidationError.empty;
    }
    if (height < RegistrationMeasurementRules.minimumHeightCm) {
      return ValidationError.valueBelowMinimum;
    }
    return ValidationError.valueAboveMaximum;
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
