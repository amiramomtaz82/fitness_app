import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../../core/base/ui_events.dart';
import '../../../../../../core/mixin/ui_event_handler_mixin.dart';
import '../../../../../../core/validation/validation_errors.dart';
import '../../manager/cubit/register_cubit.dart';
import '../../manager/cubit/register_intent.dart';
import '../../manager/cubit/register_state.dart';
import '../../manager/cubit/registration_validation_event.dart';
import 'registration_validation_message.dart';
import 'widgets/registration_shell_chrome.dart';

class MultiStepsRegistrationView extends StatelessWidget {

  const MultiStepsRegistrationView({super.key, this.pageController});

  final PageController? pageController;

  @override
  Widget build(BuildContext context) {
    return RegistrationShell(pageController: pageController);
  }
}

class RegistrationShell extends StatefulWidget {
  const RegistrationShell({super.key, this.pageController});

  final PageController? pageController;

  @override
  State<RegistrationShell> createState() => RegistrationShellState();
}

class RegistrationShellState extends State<RegistrationShell>
    with UiEventMixin<RegistrationShell, RegisterState, BaseUiEvent> {
  static const _pageMove = Duration(milliseconds: 250);

  late final PageController _pageController;
  bool _isAnimating = false;

  @override
  RegisterCubit get cubit => context.read<RegisterCubit>();

  @override
  void initState() {
    super.initState();
    final step = cubit.state.currentStep;
    _pageController =
        widget.pageController ?? PageController(initialPage: step);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncPage(step));
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RegistrationShellBody(
      pageController: _pageController,
      onBack: _onBack,
      onNext: _onNext,
    );
  }

  @override
  void handleCustomEvents(BaseUiEvent event) {
    switch (event) {
      case RegistrationValidationEvent(:final error):
        _showValidationError(error);
      case RegistrationStepChangedEvent(:final step):
        _syncPage(step);
      default:
        super.handleCustomEvents(event);
    }
  }

  void _showValidationError(ValidationError error) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error.messageKey.tr())));
  }

  void _onBack() => _dispatch(const GoBackIntent());

  void _onNext() => _dispatch(const NextStepIntent());

  void _dispatch(RegisterIntent intent) {
    if (cubit.state.isPaging) return;
    cubit.doIntent(intent);
  }

  void _syncPage(int step) {
    if (!mounted || !_pageController.hasClients || _isAnimating) return;
    final current =
        _pageController.page?.round() ?? _pageController.initialPage;
    if (current == step) {
      _releasePaging();
      return;
    }
    _animateTo(step);
  }

  void _animateTo(int step) {
    _isAnimating = true;
    _pageController
        .animateToPage(step, duration: _pageMove, curve: Curves.easeOut)
        .whenComplete(_releasePaging);
  }

  void _releasePaging() {
    _isAnimating = false;
    if (!mounted || cubit.isClosed) return;
    cubit.doIntent(const ReleasePagingIntent());
  }
}
