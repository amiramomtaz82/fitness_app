import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/theme/app_colors.dart';

class SocialButton extends StatelessWidget {
  final String? icon;
  final IconData? appleIcon;
  final VoidCallback onTap;

SocialButton({this.icon, this.appleIcon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24.r),
      child: Container(
        width: 40.r,
        height: 40.r,
        decoration: BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,

        ),
        alignment: Alignment.center,
        child: appleIcon != null
            ? Icon(appleIcon, color: AppColors.white, size: 26.r)
            : Image.asset(icon!, width: 25.r, height: 25.r),
      ),
    );
  }
}