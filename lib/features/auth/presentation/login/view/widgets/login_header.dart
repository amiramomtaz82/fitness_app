import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../core/contants/app_assets.dart';
import '../../../../../../core/theme/text_styles.dart';
import '../../../../../../generated/locale_keys.g.dart';

class LoginHeader extends StatelessWidget {
  const LoginHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Image.asset(AppAssets.logo, width: 85.w, height: 60.h),
        ),
        SizedBox(height: 80.h),
        Text(
          LocaleKeys.auth_hey_there.tr(),
          style: AppTextStyles.white18regular.copyWith(fontSize: 18.sp),
        ),
        Text(
          LocaleKeys.auth_welcome_back.tr(),
          style: AppTextStyles.white20bold.copyWith(fontSize: 20.sp),
        ),
      ],
    );
  }
}
