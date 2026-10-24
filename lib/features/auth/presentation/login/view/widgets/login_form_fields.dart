import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/contants/app_assets.dart';
import '../../../../../../core/theme/context.extension.dart';
import '../../../../../../core/theme/text_styles.dart';
import '../../../../../../core/validation/form_validators.dart';
import '../../../../../../core/validation/validation_mapper.dart';
import '../../../../../../core/widgets/app_text_form_field.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../view_model/login_cubit.dart';
import '../../view_model/login_intent.dart';
import '../../view_model/login_state.dart';

class LoginFormFields extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const LoginFormFields({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AppTextFormField(
          key: const Key('emailField'),
          controller: emailController,
          hintText: LocaleKeys.auth_email.tr(),
          prefixIcon: AppAssets.mail,
          keyboardType: TextInputType.emailAddress,
          validator: (value) =>
              FormValidators.validateEmail(value)?.toMessage(),
        ),
        SizedBox(height: 16.h),
        _PasswordField(controller: passwordController),
        SizedBox(height: 12.h),
        const _ForgetPasswordLink(),
      ],
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;

  const _PasswordField({required this.controller});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<LoginCubit, LoginState, bool>(
      selector: (state) => state.isPasswordObscured,
      builder: (context, isObscured) {
        return AppTextFormField(
          key: const Key('passwordField'),
          controller: controller,
          hintText: LocaleKeys.auth_password.tr(),
          prefixIcon: AppAssets.lock,
          obscureText: isObscured,
          textInputAction: TextInputAction.done,
          validator: (value) =>
              FormValidators.validateRequired(value)?.toMessage(),
          suffix: _PasswordVisibilityToggle(isObscured: isObscured),
        );
      },
    );
  }
}

class _PasswordVisibilityToggle extends StatelessWidget {
  final bool isObscured;

  const _PasswordVisibilityToggle({required this.isObscured});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('togglePasswordBtn'),
      onPressed: () => context.read<LoginCubit>().doIntent(
        const TogglePasswordVisibilityIntent(),
      ),
      icon: Icon(
        isObscured ? Icons.visibility_outlined : Icons.visibility_off_outlined,
        size: 20.r,
        color: context.colors.white,
      ),
    );
  }
}

class _ForgetPasswordLink extends StatelessWidget {
  const _ForgetPasswordLink();

  @override
  Widget build(BuildContext context) {
    final primary = context.colors.primary;
    return GestureDetector(
      key: const Key('forgotPasswordBtn'),
      onTap: () => context.read<LoginCubit>().doIntent(
        const NavigateToForgetPasswordIntent(),
      ),
      child: Text(
        LocaleKeys.auth_forgot_password.tr(),
        style: AppTextStyles.orange12regular.copyWith(
          fontSize: 12.sp,
          color: primary,
          decoration: TextDecoration.underline,
          decorationColor: primary,
        ),
      ),
    );
  }
}
