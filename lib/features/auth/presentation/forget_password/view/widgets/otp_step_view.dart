import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/validation/form_validators.dart';
import 'package:fitness_app/core/validation/validation_mapper.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view/widgets/app_otp_field.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../view_model/forget_password_config.dart';
import '../../view_model/forget_password_cubit.dart';
import '../../view_model/forget_password_event.dart';
import 'resend_code_button.dart';
import 'step_layout.dart';

class OtpStepView extends StatefulWidget {
  const OtpStepView({super.key});

  @override
  State<OtpStepView> createState() => _OtpStepViewState();
}

class _OtpStepViewState extends State<OtpStepView> {
  String _code = '';
  final ValueNotifier<String?> _errorNotifier = ValueNotifier<String?>(null);

  @override
  void dispose() {
    _errorNotifier.dispose();
    super.dispose();
  }

  void _verify(String value) {
    final error = FormValidators.validateOtp(
      value,
      length: ForgetPasswordConfig.otpLength,
    )?.toMessage();

    if (error != null) {
      _errorNotifier.value = error;
      return;
    }

    _errorNotifier.value = null;
    FocusScope.of(context).unfocus();
    context.read<ForgetPasswordCubit>().onEvent(
      VerifyResetCode(otp: value.trim()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isVerifying = context.select(
      (ForgetPasswordCubit c) => c.state.verifyCode.isLoading,
    );
    final isResending = context.select(
      (ForgetPasswordCubit c) => c.state.resendCode.isLoading,
    );
    final resendSecondsLeft = context.select(
      (ForgetPasswordCubit c) => c.state.resendSecondsLeft,
    );
    final colors = context.colors;

    return StepLayout(
      title: LocaleKeys.auth_otp_code.tr(),
      subtitle: LocaleKeys.auth_enter_otp_check_email.tr(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AppOtpField(
            key: const Key('otpField'),
            length: ForgetPasswordConfig.otpLength,
            enabled: !isVerifying,
            errorNotifier: _errorNotifier,
            onChanged: (value) => _code = value,
            onCompleted: _verify,
          ),
          SizedBox(height: 10.h),
          ElevatedButton(
            key: const Key('confirmButton'),
            onPressed: isVerifying ? null : () => _verify(_code),
            child: isVerifying
                ? SizedBox(
                    height: 22.w,
                    width: 22.w,
                    child: const CircularProgressIndicator(strokeWidth: 2.4),
                  )
                : Text(LocaleKeys.auth_confirm.tr()),
          ),
          SizedBox(height: 16.h),
          Text(
            LocaleKeys.auth_didnt_receive_code.tr(),
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14.sp, color: colors.textPrimary),
          ),
          Center(
            child: ResendCodeButton(
              key: const Key('resendButton'),
              isResending: isResending,
              secondsLeft: resendSecondsLeft,
              onResend: () => context.read<ForgetPasswordCubit>().onEvent(
                const ResendResetCode(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
