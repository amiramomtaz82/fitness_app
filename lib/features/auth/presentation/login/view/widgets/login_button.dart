import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/theme/context.extension.dart';
import '../../../../../../core/theme/text_styles.dart';
import '../../../../../../generated/locale_keys.g.dart';
import '../../view_model/login_cubit.dart';
import '../../view_model/login_state.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const LoginButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return BlocSelector<LoginCubit, LoginState, bool>(
      selector: (state) => state.loginResource.isLoading,
      builder: (context, isLoading) {
        return ElevatedButton(
          key: const Key('loginBtn'),
          onPressed: isLoading ? null : onPressed,
          child: isLoading
              ? const _ButtonLoader()
              : Text(
                  LocaleKeys.auth_login.tr(),
                  style: AppTextStyles.white14bold.copyWith(fontSize: 14.sp),
                ),
        );
      },
    );
  }
}

class _ButtonLoader extends StatelessWidget {
  const _ButtonLoader();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20.r,
      height: 20.r,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: context.colors.white,
      ),
    );
  }
}
