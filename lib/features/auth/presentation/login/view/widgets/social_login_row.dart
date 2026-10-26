import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/contants/app_assets.dart';
import '../../../../../../core/theme/context.extension.dart';
import '../../view_model/login_cubit.dart';
import '../../view_model/login_intent.dart';

class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LoginCubit>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SocialLoginButton(
          key: const Key('facebookBtn'),
          icon: Image.asset(AppAssets.facebook),
          onTap: () => cubit.doIntent(const SignInWithFacebookIntent()),
        ),
        SizedBox(width: 16.w),
        SocialLoginButton(
          key: const Key('googleBtn'),
          icon: Image.asset(AppAssets.google),
          onTap: () => cubit.doIntent(const SignInWithGoogleIntent()),
        ),
        SizedBox(width: 16.w),
        SocialLoginButton(
          icon: Icon(Icons.apple, color: context.colors.white, size: 20.r),
        ),
      ],
    );
  }
}

class SocialLoginButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback? onTap;

  const SocialLoginButton({super.key, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 40.r,
        height: 40.r,
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: context.colors.inputFillTranslucent,
        ),
        child: icon,
      ),
    );
  }
}
