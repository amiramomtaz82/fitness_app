import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../../../../core/theme/app_colors.dart';
import '../../../../../../../core/theme/text_styles.dart';
import '../../../../../../../generated/locale_keys.g.dart';

class RegisterNextButton extends StatelessWidget {
  final VoidCallback onPressed;

  const RegisterNextButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 40.h,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24.r),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          LocaleKeys.common_next.tr(),
          style: AppTextStyles.white14bold,
        ),
      ),
    );
  }
}
