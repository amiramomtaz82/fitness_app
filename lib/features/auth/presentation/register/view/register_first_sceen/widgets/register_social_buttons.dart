import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../../core/contants/app_assets.dart';
import '../../../../../../../core/theme/app_colors.dart';

class RegisterSocialButtons extends StatelessWidget {
  const RegisterSocialButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _SocialButton(icon: AppAssets.facebook, onTap: () {}),
        SizedBox(width: 20.w),
        _SocialButton(icon: AppAssets.google, onTap: () {}),
        SizedBox(width: 20.w),
        _SocialButton(icon: null, appleIcon: Icons.apple, onTap: () {}),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String? icon;
  final IconData? appleIcon;
  final VoidCallback onTap;

  const _SocialButton({this.icon, this.appleIcon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        width: 48.r,
        height: 48.r,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.darkGrey.withValues(alpha: 0.5)),
        ),
        alignment: Alignment.center,
        child: appleIcon != null
            ? Icon(appleIcon, color: AppColors.white, size: 26.r)
            : Image.asset(icon!, width: 20.r, height: 20.r),
      ),
    );
  }
}