import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../../core/contants/app_assets.dart';
import '../../../../../../../core/theme/text_styles.dart';
import '../../../../../../../generated/locale_keys.g.dart';


class RegisterHeader extends StatelessWidget {
  const RegisterHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.asset(AppAssets.logo, height: 70.h, width: 70.w),
        SizedBox(height: 16.h),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                LocaleKeys.auth_hey_there.tr(),
                style: AppTextStyles.white18regular
              ),
              SizedBox(height: 4.h),
              Text(
                LocaleKeys.auth_create_an_account.tr(),
                style: AppTextStyles.white20bold,
              ),
            ],
          ),
        ),
      ],
    );
  }
}