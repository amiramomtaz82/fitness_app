import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/theme/text_styles.dart';

class EditTapField extends StatelessWidget {
  final String labelKey;
  final String value;
  final VoidCallback onTap;

  const EditTapField({
    super.key,
    required this.labelKey,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labelKey.tr(), style: AppTextStyles.white14bold),
        SizedBox(height: 8.h),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(30.r),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(30.r),
              border: Border.all(color: colors.border),
              color: colors.white.withValues(alpha: 0.04),
            ),
            child: Text(
              value,
              style: AppTextStyles.white14regular.copyWith(
                color: value.isEmpty ? colors.grey : colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
