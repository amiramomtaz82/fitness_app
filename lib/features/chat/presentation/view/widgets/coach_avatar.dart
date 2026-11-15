import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../core/contants/app_assets.dart';
import '../../../../../core/theme/app_colors.dart';

class CoachAvatar extends StatelessWidget {
  const CoachAvatar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32.r,
      height: 32.r,
      padding: EdgeInsets.all(3.r),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        shape: BoxShape.circle,
      ),
      child: Image.asset(AppAssets.robot, fit: BoxFit.contain),
    );
  }
}
