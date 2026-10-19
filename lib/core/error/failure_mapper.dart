import 'package:easy_localization/easy_localization.dart';
import '../../generated/locale_keys.g.dart';
import '../base/ui_events.dart';
import '../go_routes/routes_names.dart';
import 'failures.dart';

class FailureMapper {
  /// Maps any Failure to a localized user-facing message
  static String mapToMessage(Failure failure) {
    // 1. If the backend returned a custom message, show it
    if (failure.serverMessage != null && failure.serverMessage!.isNotEmpty) {
      return failure.serverMessage!;
    }

    // 2. Otherwise, localize based on the Failure type
    return switch (failure) {
      NetworkFailure() => tr(LocaleKeys.errors_no_internet_connection),
      UnauthorizedFailure() => tr(LocaleKeys.errors_session_expired),
      ForbiddenFailure() => tr(LocaleKeys.errors_no_permission),
      NotFoundFailure() => tr(LocaleKeys.errors_data_not_found),
      ValidationFailure() => tr(LocaleKeys.errors_invalid_fields),
      ServerFailure() => tr(LocaleKeys.errors_internal_server_error),
      UnknownFailure() => tr(LocaleKeys.errors_something_went_wrong),
    };
  }


  /// Maps any Failure to your existing UiEvent system
  static BaseUiEvent mapToUiEvent(Failure failure) {
    return switch (failure) {
      UnauthorizedFailure() => const NavigateReplacementEvent(AppRoutes.login),
      _ => ShowSnackBarEvent(
        message: mapToMessage(failure),
        isError: true,
      ),
    };
  }
}