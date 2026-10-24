import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/context.extension.dart';
import '../../../../../../core/theme/text_styles.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../view_model/login_cubit.dart';
import '../../view_model/login_intent.dart';

class RegisterPrompt extends StatelessWidget {
  const RegisterPrompt({super.key});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4.w,
      children: [
        Text(
          LocaleKeys.auth_dont_have_account.tr(),
          style: AppTextStyles.white14regular.copyWith(fontSize: 14.sp),
        ),
        GestureDetector(
          key: const Key('registerBtn'),
          onTap: () => context.read<LoginCubit>().doIntent(
            const NavigateToRegisterIntent(),
          ),
          child: Text(
            LocaleKeys.auth_register.tr(),
            style: AppTextStyles.darkOrange14Bold.copyWith(
              fontSize: 14.sp,
              color: context.colors.primary,
              decoration: TextDecoration.underline,
              decorationColor: context.colors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
