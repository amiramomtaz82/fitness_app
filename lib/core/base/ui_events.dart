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

class ShowSnackBarEvent extends CommonUiEvent {
  final String message;
  final bool isError;

  const ShowSnackBarEvent({
    required this.message,
    this.isError = false,
  });
}

class NavigateEvent extends CommonUiEvent {
  final String route;
  final Object? arguments;

  const NavigateEvent(
    this.route, {
    this.arguments,
  });
}

class NavigateReplacementEvent extends CommonUiEvent {
  final String route;
  final Object? arguments;

  const NavigateReplacementEvent(
    this.route, {
    this.arguments,
  });
}

class PopEvent extends CommonUiEvent {
  final Object? result;

  const PopEvent([this.result]);
}

class ShowDialogEvent extends CommonUiEvent {
  final String title;
  final String message;
  final String? actionText;

  const ShowDialogEvent({
    required this.title,
    required this.message,
    this.actionText,
  });
}