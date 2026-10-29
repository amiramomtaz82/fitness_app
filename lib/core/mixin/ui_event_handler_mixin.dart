import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../generated/locale_keys.g.dart';
import '../base/base_cubit.dart';
import '../base/cubit_message.dart';
import '../base/ui_events.dart';
import '../error/failures.dart'; // ✅ Added to recognize Failure types

mixin UiEventMixin<W extends StatefulWidget, S, E extends BaseUiEvent>
    on State<W> {
  BaseCubit<S, E> get cubit;
  StreamSubscription<E>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = cubit.eventStream.listen(_handleUiEvent);
  }

  // ✅ 1. Restored: The method that listens to stream events
  void _handleUiEvent(E event) {
    if (!mounted || !_routeIsCurrent) return;

    switch (event) {
      case final CommonUiEvent commonEvent:
        handleCommonEvents(commonEvent);
      default:
        handleCustomEvents(event);
    }
  }

  /// Covered routes stay mounted after a push and still hear the shared cubit.
  /// Only the visible route should navigate or throw on an event it does not own.
  bool get _routeIsCurrent {
    final route = ModalRoute.of(context);
    return route == null || route.isCurrent;
  }

  /// 2. Function to handle common UI events
  void handleCommonEvents(CommonUiEvent event) {
    switch (event) {
      // ✅ Success Event: Maps Enum -> Localized String
      case ShowSuccessSnackBarEvent(:final type):
        final message = _mapSuccessTypeToMessage(type);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );

      // ✅ Error Event: Maps Failure -> Localized String
      case ShowErrorSnackBarEvent(:final failure):
        final message = _mapFailureToMessage(failure);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );

      case NavigateEvent():
        context.push(event.route, extra: event.arguments);

      case NavigateReplacementEvent():
        context.go(event.route, extra: event.arguments);

      case PopEvent():
        if (context.canPop()) {
          context.pop(event.result);
        }
    }
  }

  /// ✅ 3. Added: Switch-case mapping Failure -> User-facing localized string in UI
  String _mapFailureToMessage(Failure failure) {
    if (failure.serverMessage != null && failure.serverMessage!.isNotEmpty) {
      return failure.serverMessage!;
    }

    return switch (failure) {
      NetworkFailure() => LocaleKeys.errors_no_internet_connection.tr(),
      UnauthorizedFailure() => LocaleKeys.errors_session_expired.tr(),
      ForbiddenFailure() => LocaleKeys.errors_no_permission.tr(),
      NotFoundFailure() => LocaleKeys.errors_data_not_found.tr(),
      ValidationFailure() => LocaleKeys.errors_invalid_fields.tr(),
      ServerFailure() => LocaleKeys.errors_internal_server_error.tr(),
      SocialAccountFailure(:final provider) => switch (provider) {
        SocialProvider.google => LocaleKeys.auth_forgot_password_google.tr(),
        SocialProvider.facebook => LocaleKeys.auth_forgot_password_facebook.tr(),
      },
      UnknownFailure() => LocaleKeys.errors_something_went_wrong.tr(),
    };
  }

  /// ✅ 4. Switch-case mapping Enum -> User-facing localized string in UI
  String _mapSuccessTypeToMessage(CubitMessageType type) {
    return switch (type) {
      CubitMessageType.loginSuccess => LocaleKeys.auth_welcome_back.tr(),
      CubitMessageType.registerSuccess => LocaleKeys.auth_done.tr(),
      CubitMessageType.otpSent => LocaleKeys.auth_sent_otp.tr(),
      CubitMessageType.passwordChanged => LocaleKeys.auth_done.tr(),
      CubitMessageType.logoutSuccess => LocaleKeys.common_done.tr(),
      CubitMessageType.profileUpdated => LocaleKeys.common_save.tr(),
      CubitMessageType.planCreated => LocaleKeys.common_done.tr(),
      CubitMessageType.operationSuccess => LocaleKeys.common_done.tr(),
      CubitMessageType.changesSaved => LocaleKeys.common_save.tr(),
    };
  }

  /// 5. Function to handle custom UI events
  void handleCustomEvents(E event) {
    switch (event) {
      default:
        throw Exception(
          'Unhandled custom event: ${event.runtimeType}. '
          'Override handleCustomEvents in your State class to handle it.',
        );
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
