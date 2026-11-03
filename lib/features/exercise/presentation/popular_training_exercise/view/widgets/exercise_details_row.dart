import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExerciseDetailsRow extends StatelessWidget {
  final String labelKey;
  final String? value;

  const ExerciseDetailsRow({super.key, required this.labelKey, this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(labelKey.tr(), style: AppTextStyles.grey12regular),
          ),
          SizedBox(width: 12.w),
          Flexible(
            child: Text(
              value ?? LocaleKeys.exercises_not_available.tr(),
              textAlign: TextAlign.end,
              style: AppTextStyles.white14regular,
            ),
          ),
        ],
      ),
    );
  }
}
