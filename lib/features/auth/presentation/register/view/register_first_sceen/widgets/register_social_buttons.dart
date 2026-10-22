import 'package:fitness_app/features/auth/presentation/register/view/register_first_sceen/widgets/social_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../../core/contants/app_assets.dart';
import '../../../manager/cubit/register_cubit.dart';
import '../../../manager/cubit/register_intent.dart';

class RegisterSocialButtons extends StatelessWidget {
  const RegisterSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SocialButton(icon: AppAssets.facebook, onTap: () {}),
        SizedBox(width: 20.w),
        SocialButton(
          icon: AppAssets.google,
          onTap: () => context.read<RegisterCubit>().doIntent(
            const SignInWithGoogleIntent(),
          ),
        ),
        SizedBox(width: 20.w),
        SocialButton(icon: null, appleIcon: Icons.apple, onTap: () {}),
      ],
    );
  }
}
