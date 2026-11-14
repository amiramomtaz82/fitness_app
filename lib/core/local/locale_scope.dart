import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../base/ui_events.dart';
import '../di/di.dart';
import 'locale_cubit.dart';
import 'locale_intent.dart';
import 'locale_ui_event.dart';

class LocaleScope extends StatefulWidget {
  final Widget child;

  const LocaleScope({required this.child, super.key});

  @override
  State<LocaleScope> createState() => _LocaleScopeState();
}

class _LocaleScopeState extends State<LocaleScope> {
  late final LocaleCubit _cubit = getIt<LocaleCubit>();
  late final StreamSubscription<BaseUiEvent> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _cubit.eventStream.listen(_applyEvent);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _cubit.doIntent(const LoadSavedLocaleIntent());
    });
  }

  void _applyEvent(BaseUiEvent event) {
    if (!mounted) return;
    if (event case LocaleChangedEvent(:final locale)) {
      context.setLocale(locale);
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(value: _cubit, child: widget.child);
  }
}
