import '../../../../../../core/base/ui_events.dart';
import '../../../../../../core/validation/validation_errors.dart';

sealed class RegistrationUiEvent extends BaseUiEvent {
  const RegistrationUiEvent();
}

class RegistrationValidationEvent extends RegistrationUiEvent {
  final ValidationError error;

  const RegistrationValidationEvent(this.error);
}

class RegistrationStepChangedEvent extends RegistrationUiEvent {
  final int step;

  const RegistrationStepChangedEvent(this.step);
}
