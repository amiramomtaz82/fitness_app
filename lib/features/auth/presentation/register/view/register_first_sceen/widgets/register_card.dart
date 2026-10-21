import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../../../../../../core/contants/app_assets.dart';
import '../../../../../../../core/go_routes/routes_names.dart';
import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/text_styles.dart';
import '../../../../../../../core/validation/form_validators.dart';
import '../../../../../../../core/validation/validation_mapper.dart';
import '../../../../../../../generated/locale_keys.g.dart';
import '../../../manager/cubit/register_cubit.dart';
import '../../../manager/cubit/register_intent.dart';
import '../../../manager/cubit/register_state.dart';
import 'register_footer.dart';
import 'register_input_field.dart';
import 'register_next_button.dart';
import 'register_social_buttons.dart';

class RegisterCard extends StatefulWidget {
  const RegisterCard({super.key});

  @override
  State<RegisterCard> createState() => _RegisterCardState();
}

class _RegisterCardState extends State<RegisterCard> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_formKey.currentState?.validate() ?? false) {

      context.read<RegisterCubit>().doIntent(
        SubmitAccountCredentialsIntent(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );


      context.push(AppRoutes.multiStepRegistration);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(50.r),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: EdgeInsetsDirectional.symmetric(horizontal: 20.w, vertical: 28.h),
          decoration: BoxDecoration(
            color: const Color(0xFF242424).withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(50.r),
            border: Border.all(color: AppColors.white.withValues(alpha: 0.08)),
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(LocaleKeys.auth_register.tr(), style: AppTextStyles.white20bold),
                SizedBox(height: 20.h),
                RegisterInputField(
                  controller: _firstNameController,
                  hintText: LocaleKeys.auth_first_name.tr(),
                  iconAsset: AppAssets.user,
                  validator: (v) => FormValidators.validateRequired(v)?.toMessage(),
                ),
                SizedBox(height: 12.h),
                RegisterInputField(
                  controller: _lastNameController,
                  hintText: LocaleKeys.auth_last_name.tr(),
                  iconAsset: AppAssets.user,
                  validator: (v) => FormValidators.validateRequired(v)?.toMessage(),
                ),
                SizedBox(height: 12.h),
                RegisterInputField(
                  controller: _emailController,
                  hintText: LocaleKeys.auth_email.tr(),
                  iconAsset: AppAssets.mail,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) => FormValidators.validateEmail(v)?.toMessage(),
                ),
                SizedBox(height: 12.h),
                BlocBuilder<RegisterCubit, RegisterState>(
                  buildWhen: (p, c) => p.isPasswordObscured != c.isPasswordObscured,
                  builder: (context, state) {
                    return RegisterInputField(
                      controller: _passwordController,
                      hintText: LocaleKeys.auth_password.tr(),
                      iconAsset: AppAssets.lock,
                      isPassword: true,
                      isObscured: state.isPasswordObscured,
                      onToggleObscure: () => context
                          .read<RegisterCubit>()
                          .doIntent(const TogglePasswordVisibilityIntent()),
                      validator: (v) => FormValidators.validatePassword(v)?.toMessage(),
                    );
                  },
                ),
                SizedBox(height: 16.h),
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.darkGrey)),
                    Padding(
                      padding: EdgeInsetsDirectional.symmetric(horizontal: 10.w),
                      child: Text(LocaleKeys.auth_or.tr(), style: AppTextStyles.grey12regular),
                    ),
                    const Expanded(child: Divider(color: AppColors.darkGrey)),
                  ],
                ),
                SizedBox(height: 14.h),
                const RegisterSocialButtons(),
                SizedBox(height: 20.h),
                RegisterNextButton(onPressed: _onNext),
                SizedBox(height: 16.h),
                const RegisterFooter(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}