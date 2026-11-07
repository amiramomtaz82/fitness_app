import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/mixin/ui_event_handler_mixin.dart';
import 'package:fitness_app/core/validation/validation_mapper.dart';
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
  final ValueNotifier<bool> _obscureCurrentPassword = ValueNotifier(true);
  final ValueNotifier<bool> _obscureNewPassword = ValueNotifier(true);
  final ValueNotifier<bool> _obscureConfirmPassword = ValueNotifier(true);

  @override
  BaseCubit<ChangePasswordState, BaseUiEvent> get cubit =>
      context.read<ChangePasswordCubit>();

  @override
  void dispose() {
    _obscureCurrentPassword.dispose();
    _obscureNewPassword.dispose();
    _obscureConfirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CustomColors>()!;

    return AppBackgroundScaffold(
      child: SingleChildScrollView(
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
              field: ChangePasswordField.currentPassword,
              obscureNotifier: _obscureCurrentPassword,
            ),

            SizedBox(height: 20.h),

            _PasswordField(
              label: LocaleKeys.profile_new_password.tr(),
              field: ChangePasswordField.newPassword,
              obscureNotifier: _obscureNewPassword,
            ),

            SizedBox(height: 20.h),

            _PasswordField(
              label: LocaleKeys.profile_confirm_password.tr(),
              field: ChangePasswordField.confirmPassword,
              obscureNotifier: _obscureConfirmPassword,
            ),

            SizedBox(height: 40.h),

            BlocSelector<ChangePasswordCubit, ChangePasswordState, bool>(
              selector: (state) => state.isChanging,
              builder: (context, isChanging) {
                return SizedBox(
                  width: double.infinity,
                  height: 54.h,
                  child: ElevatedButton(
                    onPressed: isChanging
                        ? null
                        : () {
                            context.read<ChangePasswordCubit>().doIntent(
                              const SubmitChangePasswordIntent(),
                            );
                          },
                    child: isChanging
                        ? SizedBox(
                            width: 22.w,
                            height: 22.w,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : Text(LocaleKeys.profile_done.tr()),
                  ),
                );
              },
            ),

            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final String label;
  final ChangePasswordField field;
  final ValueNotifier<bool> obscureNotifier;

  const _PasswordField({
    required this.label,
    required this.field,
    required this.obscureNotifier,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<CustomColors>()!;

    return BlocSelector<
      ChangePasswordCubit,
      ChangePasswordState,
      ValidationError?
    >(
      selector: (state) => state.errorOf(field),
      builder: (context, error) {
        return ValueListenableBuilder<bool>(
          valueListenable: obscureNotifier,
          builder: (context, obscureText, child) {
            return TextField(
              onChanged: (value) {
                context.read<ChangePasswordCubit>().doIntent(
                  UpdatePasswordFieldIntent(field, value),
                );
              },
              obscureText: obscureText,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: colors.textPrimary),
              decoration: InputDecoration(
                hintText: label,
                hintStyle: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: colors.hint),
                prefixIcon: Icon(
                  Icons.lock_outline,
                  color: colors.textSecondary,
                ),
                suffixIcon: IconButton(
                  onPressed: () {
                    obscureNotifier.value = !obscureNotifier.value;
                  },
                  icon: Icon(
                    obscureText
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: colors.textSecondary,
                  ),
                ),
                errorText: error?.toMessage(),
              ),
            );
          },
        );
      },
    );
  }
}
