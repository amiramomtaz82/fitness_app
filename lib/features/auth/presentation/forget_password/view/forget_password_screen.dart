import 'package:fitness_app/app/go_routes/routes_names.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/mixin/ui_event_handler_mixin.dart';
import 'package:fitness_app/core/widgets/app_background_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../view_model/forget_password_cubit.dart';
import '../view_model/forget_password_event.dart';
import '../view_model/forget_password_state.dart';
import 'widgets/email_step_view.dart';
import 'widgets/forget_password_top_bar.dart';
import 'widgets/otp_step_view.dart';
import 'widgets/reset_password_step_view.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen>
    with UiEventMixin<ForgetPasswordScreen, ForgetPasswordState, BaseUiEvent> {
  @override
  late final ForgetPasswordCubit cubit = context.read<ForgetPasswordCubit>();

  void _handleBack(ForgetPasswordState state) {
    if (state.isFirstStep) {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go(AppRoutes.login);
      }
    } else {
      cubit.onEvent(const GoToPreviousStep());
    }
  }

  Widget _stepContent(ForgetPasswordStep step) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      child: switch (step) {
        ForgetPasswordStep.email => const EmailStepView(key: ValueKey('email')),
        ForgetPasswordStep.otp => const OtpStepView(key: ValueKey('otp')),
        ForgetPasswordStep.resetPassword => const ResetPasswordStepView(
          key: ValueKey('reset'),
        ),
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ForgetPasswordCubit, ForgetPasswordState>(
      buildWhen: (previous, current) => previous.step != current.step,
      builder: (context, state) {
        return PopScope(
          canPop: state.isFirstStep,
          onPopInvokedWithResult: (didPop, _) {
            if (!didPop) _handleBack(state);
          },
          child: AppBackgroundScaffold(
            child: Column(
              children: [
                ForgetPasswordTopBar(onBack: () => _handleBack(state)),
                Expanded(child: _stepContent(state.step)),
              ],
            ),
          ),
        );
      },
    );
  }
}
