import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/contants/app_assets.dart';
import 'package:fitness_app/core/validation/form_validators.dart';
import 'package:fitness_app/core/validation/validation_mapper.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../view_model/forget_password_cubit.dart';
import '../../view_model/forget_password_event.dart';
import 'step_layout.dart';

class EmailStepView extends StatefulWidget {
  const EmailStepView({super.key});

  @override
  State<EmailStepView> createState() => _EmailStepViewState();
}

class _EmailStepViewState extends State<EmailStepView> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_emailController.text.isEmpty) {
      _emailController.text = context.read<ForgetPasswordCubit>().state.email;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<ForgetPasswordCubit>().onEvent(
      SendResetCode(email: _emailController.text.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.select(
      (ForgetPasswordCubit c) => c.state.sendCode.isLoading,
    );

    return StepLayout(
      title: LocaleKeys.auth_forget_password.tr(),
      subtitle: LocaleKeys.auth_enter_your_email.tr(),
      subtitleAbove: true,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              key: const Key('emailField'),
              controller: _emailController,
              enabled: !isSubmitting,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) =>
                  FormValidators.validateEmail(value)?.toMessage(),
              onFieldSubmitted: (_) => _submit(),
              decoration: InputDecoration(
                hintText: LocaleKeys.auth_email.tr(),
                prefixIcon: Image.asset(AppAssets.mail, height: 20, width: 20),
              ),
            ),
            SizedBox(height: 18.h),
            ElevatedButton(
              key: const Key('continueButton'),
              onPressed: isSubmitting ? null : _submit,
              child: isSubmitting
                  ? SizedBox(
                      height: 22.w,
                      width: 22.w,
                      child: const CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : Text(LocaleKeys.auth_sent_otp.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
