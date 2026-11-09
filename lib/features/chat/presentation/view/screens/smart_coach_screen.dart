import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/base/ui_events.dart';
import '../../../../../core/mixin/ui_event_handler_mixin.dart';
import '../../../../../core/widgets/app_background_scaffold.dart';
import '../../view_model/smart_coach_cubit.dart';
import '../../view_model/smart_coach_intent.dart';
import '../../view_model/smart_coach_state.dart';
import '../widgets/coach_chat_view.dart';
import '../widgets/coach_welcome_view.dart';
import '../widgets/previous_conversations_drawer.dart';

class SmartCoachScreen extends StatefulWidget {
  const SmartCoachScreen({super.key});

  @override
  State<SmartCoachScreen> createState() => _SmartCoachScreenState();
}

class _SmartCoachScreenState extends State<SmartCoachScreen>
    with UiEventMixin<SmartCoachScreen, SmartCoachState, BaseUiEvent> {
  @override
  SmartCoachCubit get cubit => context.read<SmartCoachCubit>();

  @override
  void initState() {
    super.initState();
    cubit.doIntent(const LoadCoachIntent());
  }

  @override
  Widget build(BuildContext context) {
    final hasStarted = context.select<SmartCoachCubit, bool>(
      (cubit) => cubit.state.hasStarted,
    );

    return AppBackgroundScaffold(
      overlayOpacity: 0.7,
      endDrawer: hasStarted ? const PreviousConversationsDrawer() : null,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: hasStarted
            ? const CoachChatView(key: ValueKey('chat'))
            : const CoachWelcomeView(key: ValueKey('welcome')),
      ),
    );
  }
}
