import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../core/base/base_cubit.dart';
import '../../../../../core/base/ui_events.dart';
import '../../../../../core/mixin/ui_event_handler_mixin.dart';
import '../../../../../core/widgets/app_background_scaffold.dart';
import '../view_model/login_cubit.dart';
import '../view_model/login_intent.dart';
import '../view_model/login_state.dart';
import 'widgets/login_form_card.dart';
import 'widgets/login_header.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView>
    with UiEventMixin<LoginView, LoginState, BaseUiEvent> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  BaseCubit<LoginState, BaseUiEvent> get cubit => context.read<LoginCubit>();

  void _onLoginPressed() {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    context.read<LoginCubit>().doIntent(
      LoginSubmittedIntent(
        email: _emailController.text,
        password: _passwordController.text,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppBackgroundScaffold(
      overlayOpacity: 0.4,
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const LoginHeader(),
            SizedBox(height: 16.h),
            LoginFormCard(
              formKey: _formKey,
              emailController: _emailController,
              passwordController: _passwordController,
              onLoginPressed: _onLoginPressed,
            ),
          ],
        ),
      ),
    );
  }
}
