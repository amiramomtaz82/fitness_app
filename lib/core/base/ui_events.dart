import '../error/failures.dart';
import 'cubit_message.dart';

/// Super class for all UI events in the app (common and custom).
abstract class BaseUiEvent {
  const BaseUiEvent();
}

/// Backwards compatibility alias
typedef UiEvent = BaseUiEvent;

/// Sealed class for universal/common events handled across the app.
sealed class CommonUiEvent extends BaseUiEvent {
  const CommonUiEvent();
}

// ==========================================
// NAVIGATION EVENTS
// ==========================================
class NavigateEvent extends CommonUiEvent {
  final String route;
  final Object? arguments;

  const NavigateEvent(this.route, {this.arguments});
}

class NavigateReplacementEvent extends CommonUiEvent {
  final String route;
  final Object? arguments;

  const NavigateReplacementEvent(this.route, {this.arguments});
}

class PopEvent extends CommonUiEvent {
  final Object? result;

  const PopEvent([this.result]);
}

// ==========================================
// FEEDBACK EVENTS (NO RAW STRINGS!)
// ==========================================

/// For errors: carries the Failure object (UI handles localization)
class ShowErrorSnackBarEvent extends CommonUiEvent {
  final Failure failure;
  const ShowErrorSnackBarEvent(this.failure);
}

/// For successes: carries the Enum (UI handles localization)
class ShowSuccessSnackBarEvent extends CommonUiEvent {
  final CubitMessageType type;
  const ShowSuccessSnackBarEvent(this.type);
}