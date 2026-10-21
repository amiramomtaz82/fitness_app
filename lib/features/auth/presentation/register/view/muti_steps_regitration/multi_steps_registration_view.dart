import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';

import '../../../../../../core/base/ui_events.dart';
import '../../../../../../core/mixin/ui_event_handler_mixin.dart';
import '../../manager/cubit/register_cubit.dart';
import '../../manager/cubit/register_intent.dart';
import '../../manager/cubit/register_state.dart';
import 'widgets/registration_shell_chrome.dart';

class MultiStepsRegistrationView extends StatelessWidget {
  const MultiStepsRegistrationView({
    super.key,
    this.cubit,
    this.pageController,
  });

  final RegisterCubit? cubit;
  final PageController? pageController;

  @override
  Widget build(BuildContext context) {
    return _RegistrationScope(
      cubit: cubit ?? _cubitFromTree(context),
      child: _RegistrationShell(pageController: pageController),
    );
  }
}

class _RegistrationScope extends StatelessWidget {
  const _RegistrationScope({required this.cubit, required this.child});

  final RegisterCubit? cubit;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final existing = cubit;
    if (existing == null) {
      return BlocProvider(
        lazy: false,
        create: (_) => GetIt.instance<RegisterCubit>(),
        child: child,
      );
    }
    return BlocProvider.value(value: existing, child: child);
  }
}

class _RegistrationShell extends StatefulWidget {
  const _RegistrationShell({this.pageController});

  final PageController? pageController;

  @override
  State<_RegistrationShell> createState() => _RegistrationShellState();
}

class _RegistrationShellState extends State<_RegistrationShell>
    with UiEventMixin<_RegistrationShell, RegisterState, BaseUiEvent> {
  static const _pageMove = Duration(milliseconds: 250);

  late final PageController _pageController;
  bool _isPaging = false;

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
    return BlocConsumer<RegisterCubit, RegisterState>(
      listener: _onState,
      builder: (context, state) {
        return RegistrationShellBody(
          state: state,
          pageController: _pageController,
          isPaging: _isPaging,
          onBack: _onBack,
          onNext: _onNext,
        );
      },
    );
  }

  void _onState(BuildContext context, RegisterState state) {
    _syncPage(state.currentStep);
  }

  void _onBack() => _dispatch(const GoBackIntent());

  void _onNext() => _dispatch(const NextStepIntent());

  void _dispatch(RegisterIntent intent) {
    if (_isPaging) return;
    cubit.doIntent(intent);
  }

  void _syncPage(int step) {
    if (!mounted || !_pageController.hasClients || _isPaging) return;
    final current =
        _pageController.page?.round() ?? _pageController.initialPage;
    if (current == step) return;
    _animateTo(step);
  }

  void _animateTo(int step) {
    _isPaging = true;
    setState(() {});
    _pageController
        .animateToPage(step, duration: _pageMove, curve: Curves.easeOut)
        .whenComplete(_finishPaging);
  }

  void _finishPaging() {
    if (!mounted) return;
    setState(() => _isPaging = false);
  }
}

RegisterCubit? _cubitFromTree(BuildContext context) {
  try {
    return context.read<RegisterCubit>();
  } on ProviderNotFoundException {
    return null;
  }
}
