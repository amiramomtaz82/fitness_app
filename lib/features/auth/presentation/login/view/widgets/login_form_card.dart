import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/context.extension.dart';
import '../../../../../../core/theme/text_styles.dart';
import '../../../../../../generated/locale_keys.g.dart';
import 'login_button.dart';
import 'login_form_fields.dart';
import 'or_divider.dart';
import 'register_prompt.dart';
import 'social_login_row.dart';

class LoginFormCard extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onLoginPressed;

  const LoginFormCard({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.onLoginPressed,
  });

  @override
  Widget build(BuildContext context) {
    return _GlassContainer(
      child: Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            Text(
              LocaleKeys.auth_login.tr(),
              style: AppTextStyles.white24bold.copyWith(
                fontSize: 24.sp,
                color: context.colors.white,
              ),
            ),
            SizedBox(height: 24.h),
            LoginFormFields(
              emailController: emailController,
              passwordController: passwordController,
            ),
            SizedBox(height: 24.h),
            const OrDivider(),
            SizedBox(height: 16.h),
            const SocialLoginRow(),
            SizedBox(height: 32.h),
            LoginButton(onPressed: onLoginPressed),
            SizedBox(height: 12.h),
            const RegisterPrompt(),
          ],
        ),
      ),
    );
  }
}

class _GlassContainer extends StatelessWidget {
  final Widget child;

  const _GlassContainer({required this.child});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
          decoration: BoxDecoration(
            color: context.colors.white.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(50.r),
          ),
          child: child,
        ),
      ),
    );
  }
}
