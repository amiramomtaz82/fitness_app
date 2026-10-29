import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/contants/app_assets.dart';
import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/validation/form_validators.dart';
import 'package:fitness_app/core/validation/validation_mapper.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../view_model/forget_password_cubit.dart';
import '../../view_model/forget_password_event.dart';
import 'step_layout.dart';

class ResetPasswordStepView extends StatefulWidget {
  const ResetPasswordStepView({super.key});

  @override
  State<ResetPasswordStepView> createState() => _ResetPasswordStepViewState();
}

class _ResetPasswordStepViewState extends State<ResetPasswordStepView> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    context.read<ForgetPasswordCubit>().onEvent(
      SubmitNewPassword(
        password: _passwordController.text,
        confirmPassword: _confirmController.text,
      ),
    );
  }

  InputDecoration _passwordDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Image.asset(AppAssets.lock, height: 20, width: 20),
    );
  }

  Widget _visibilityToggle({
    required bool obscured,
    required VoidCallback onTap,
  }) {
    return IconButton(
      onPressed: onTap,
      icon: Icon(
        obscured ? Icons.visibility_off : Icons.visibility,
        color: context.colors.hint,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = context.select(
      (ForgetPasswordCubit c) => c.state.resetPassword.isLoading,
    );

    return StepLayout(
      title: LocaleKeys.auth_create_new_password.tr(),
      subtitle: LocaleKeys.auth_make_sure_8_characters.tr(),
      subtitleAbove: true,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              key: const Key('passwordField'),
              controller: _passwordController,
              enabled: !isSubmitting,
              obscureText: _obscurePassword,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) =>
                  FormValidators.validatePassword(value)?.toMessage(),
              decoration: _passwordDecoration(LocaleKeys.auth_password.tr())
                  .copyWith(
                    suffixIcon: _visibilityToggle(
                      obscured: _obscurePassword,
                      onTap: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
            ),
            SizedBox(height: 20.h),
            TextFormField(
              key: const Key('confirmPasswordField'),
              controller: _confirmController,
              enabled: !isSubmitting,
              obscureText: _obscureConfirm,
              textInputAction: TextInputAction.done,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => FormValidators.validateConfirmPassword(
                _passwordController.text,
                value,
              )?.toMessage(),
              onFieldSubmitted: (_) => _submit(),
              decoration: _passwordDecoration(LocaleKeys.auth_password.tr())
                  .copyWith(
                    suffixIcon: _visibilityToggle(
                      obscured: _obscureConfirm,
                      onTap: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
            ),
            SizedBox(height: 28.h),
            ElevatedButton(
              key: const Key('resetButton'),
              onPressed: isSubmitting ? null : _submit,
              child: isSubmitting
                  ? SizedBox(
                      height: 22.w,
                      width: 22.w,
                      child: const CircularProgressIndicator(strokeWidth: 2.4),
                    )
                  : Text(LocaleKeys.common_done.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
