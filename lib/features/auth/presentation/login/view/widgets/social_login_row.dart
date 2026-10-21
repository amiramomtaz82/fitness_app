import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/contants/app_assets.dart';
import '../../../../../../core/theme/context.extension.dart';

class SocialLoginRow extends StatelessWidget {
  const SocialLoginRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SocialLoginButton(icon: Image.asset(AppAssets.facebook)),
        SizedBox(width: 16.w),
        SocialLoginButton(icon: Image.asset(AppAssets.google)),
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
