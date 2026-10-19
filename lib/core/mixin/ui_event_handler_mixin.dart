import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../generated/locale_keys.g.dart';
import '../base/base_cubit.dart';
import '../base/ui_events.dart';

mixin UiEventMixin<
W extends StatefulWidget,
S,
E extends BaseUiEvent> on State<W> {
  BaseCubit<S, E> get cubit;
  StreamSubscription<E>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = cubit.eventStream.listen(
      _handleUiEvent,
    );
  }

  void _handleUiEvent(E event) {
    if (!mounted) return;

    switch (event) {
      case final CommonUiEvent commonEvent:
        handleCommonEvents(commonEvent);
      default:
        handleCustomEvents(event);
    }
  }

  /// 1. Function to handle common UI events
  void handleCommonEvents(CommonUiEvent event) {
    switch (event) {
      case ShowSnackBarEvent():
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(event.message.tr()),
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
      case ShowDialogEvent():
        showDialog<void>(
          context: context,
          builder: (_) {
            return AlertDialog(
              title: Text(event.title.tr()),
              content: Text(event.message.tr()),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    event.actionText?.tr() ?? LocaleKeys.common_confirm.tr(),
                  ),
                ),
              ],
            );
          },
        );
    }
  }

  /// 2. Function to handle custom UI events
  /// Screens can override this method if they have custom events.
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