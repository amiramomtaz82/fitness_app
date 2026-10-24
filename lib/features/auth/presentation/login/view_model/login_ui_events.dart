import '../../../../../core/base/ui_events.dart';
import '../../../../../core/error/failures.dart';

class LoginFailedEvent extends BaseUiEvent {
  final Failure failure;

  const LoginFailedEvent(this.failure);
}
