import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/mixin/ui_event_handler_mixin.dart';
import 'package:fitness_app/features/profile/presentation/change_password/view/view_model/change_password_cubit.dart';
import 'package:fitness_app/features/profile/presentation/change_password/view/view_model/change_password_field.dart';
import 'package:fitness_app/features/profile/presentation/change_password/view/view_model/change_password_intent.dart';
import 'package:fitness_app/features/profile/presentation/change_password/view/view_model/change_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:fitness_app/core/base/base_cubit.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/theme/custom_colors.dart';
import 'package:fitness_app/core/validation/validation_errors.dart';
import 'package:fitness_app/core/widgets/app_background_scaffold.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen>
    with UiEventMixin<ChangePasswordScreen, ChangePasswordState, BaseUiEvent> {
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  BaseCubit<ChangePasswordState, BaseUiEvent> get cubit =>
      context.read<ChangePasswordCubit>();

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CustomColors>()!;

    return AppBackgroundScaffold(
      child: BlocBuilder<ChangePasswordCubit, ChangePasswordState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsetsDirectional.symmetric(
              horizontal: 24.w,
              vertical: 24.h,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 32.h),

                Text(
                  LocaleKeys.profile_make_sure_8_characters.tr(),
                  textAlign: TextAlign.start,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: colors.white),
                ),

                SizedBox(height: 4.h),

                Text(
                  LocaleKeys.profile_create_new_password.tr(),
                  textAlign: TextAlign.start,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 24.h),

                _PasswordField(
                  label: LocaleKeys.profile_old_password.tr(),
                  obscureText: _obscureCurrentPassword,
                  errorText: _errorMessage(
                    state.errorOf(ChangePasswordField.currentPassword),
                  ),
                  onChanged: (value) =>
                      _updateField(ChangePasswordField.currentPassword, value),
                  onToggleVisibility: () {
                    setState(() {
                      _obscureCurrentPassword = !_obscureCurrentPassword;
                    });
                  },
                ),

                SizedBox(height: 20.h),

                _PasswordField(
                  label: LocaleKeys.profile_new_password.tr(),
                  obscureText: _obscureNewPassword,
                  errorText: _errorMessage(
                    state.errorOf(ChangePasswordField.newPassword),
                  ),
                  onChanged: (value) =>
                      _updateField(ChangePasswordField.newPassword, value),
                  onToggleVisibility: () {
                    setState(() {
                      _obscureNewPassword = !_obscureNewPassword;
                    });
                  },
                ),

                SizedBox(height: 20.h),

                _PasswordField(
                  label: LocaleKeys.profile_confirm_password.tr(),
                  obscureText: _obscureConfirmPassword,
                  errorText: _errorMessage(
                    state.errorOf(ChangePasswordField.confirmPassword),
                  ),
                  onChanged: (value) =>
                      _updateField(ChangePasswordField.confirmPassword, value),
                  onToggleVisibility: () {
                    setState(() {
                      _obscureConfirmPassword = !_obscureConfirmPassword;
                    });
                  },
                ),

                SizedBox(height: 40.h),

                SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: state.isChanging
                        ? null
                        : () {
                            context.read<ChangePasswordCubit>().doIntent(
                              const SubmitChangePasswordIntent(),
                            );
                          },
                    child: state.isChanging
                        ? SizedBox(
                            width: 22.w,
                            height: 22.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(LocaleKeys.profile_done.tr()),
                  ),
                ),

                SizedBox(height: 24.h),
              ],
            ),
          );
        },
      ),
    );
  }

  void _updateField(ChangePasswordField field, String value) {
    context.read<ChangePasswordCubit>().doIntent(
      UpdatePasswordFieldIntent(field, value),
    );
  }

  String? _errorMessage(ValidationError? error) {
    if (error == null) return null;

    final key = switch (error) {
      ValidationError.empty => LocaleKeys.validation_field_required,
      ValidationError.passwordTooShort =>
        LocaleKeys.validation_password_too_short,
      ValidationError.passwordMissingNumber =>
        LocaleKeys.validation_password_missing_number,
      ValidationError.passwordMissingUppercase =>
        LocaleKeys.validation_password_missing_uppercase,
      ValidationError.passwordMissingLowercase =>
        LocaleKeys.validation_password_missing_lowercase,
      ValidationError.passwordMissingSpecialChar =>
        LocaleKeys.validation_password_missing_special_char,
      ValidationError.passwordsDoNotMatch =>
        LocaleKeys.validation_passwords_dont_match,
      _ => LocaleKeys.validation_field_required,
    };

    return key.tr();
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final String? errorText;
  final ValueChanged<String> onChanged;
  final VoidCallback onToggleVisibility;

  const _PasswordField({
    required this.label,
    required this.obscureText,
    required this.errorText,
    required this.onChanged,
    required this.onToggleVisibility,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CustomColors>()!;

    return TextField(
      onChanged: onChanged,
      obscureText: obscureText,
      style: Theme.of(
        context,
      ).textTheme.bodyLarge?.copyWith(color: colors.textPrimary),
      decoration: InputDecoration(
        hintText: label,
        hintStyle: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: colors.hint),
        prefixIcon: Icon(Icons.lock_outline, color: colors.textSecondary),
        suffixIcon: IconButton(
          onPressed: onToggleVisibility,
          icon: Icon(
            obscureText
                ? Icons.visibility_off_outlined
                : Icons.visibility_outlined,
            color: colors.textSecondary,
          ),
        ),
        errorText: errorText,
      ),
    );
  }
}
