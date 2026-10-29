import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/contants/app_assets.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                LocaleKeys.home_hi_user.tr(args: ['Ahmed']),
                style: AppTextStyles.white20bold.copyWith(fontSize: 20.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                LocaleKeys.home_lets_start_your_day.tr(),
                style: AppTextStyles.grey12regular.copyWith(fontSize: 14.sp),
              ),
            ],
          ),
        ),
        Container(
          width: 48.w,
          height: 48.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
            border: Border.all(color: AppColors.darkGrey, width: 1),
          ),
          clipBehavior: Clip.antiAlias,
          child: Image.asset(
            AppAssets.human,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Icon(Icons.person, color: AppColors.white, size: 28.sp);
            },
          ),
        ),
      ],
    );
  }
}
