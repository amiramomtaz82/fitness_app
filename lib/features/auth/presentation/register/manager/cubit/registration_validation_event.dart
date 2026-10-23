import '../../../../../../core/base/ui_events.dart';
import '../../../../../../core/validation/validation_errors.dart';

class RegistrationValidationEvent extends BaseUiEvent {
  final ValidationError error;

  const RegistrationValidationEvent(this.error);
}

class RegistrationStepChangedEvent extends BaseUiEvent {
  final int step;

  const RegistrationStepChangedEvent(this.step);
}
