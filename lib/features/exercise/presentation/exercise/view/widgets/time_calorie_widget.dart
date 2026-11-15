import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TimeCalorieWidget extends StatelessWidget {
  final String? time;
  final String? calories;

  const TimeCalorieWidget({super.key, this.time, this.calories});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final timeText = time ?? LocaleKeys.exercises_min_30.tr();
    final caloriesValue = calories ?? '130';

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildPill(
          context: context,
          child: Text(
            timeText,
            style: AppTextStyles.white14bold.copyWith(
              fontSize: 12.sp,
              letterSpacing: 0.5,
            ),
          ),
        ),
        _buildPill(
          context: context,
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: caloriesValue,
                  style: AppTextStyles.white14bold.copyWith(
                    color: colors.primary,
                    fontSize: 12.sp,
                  ),
                ),
                TextSpan(
                  text: ' ${LocaleKeys.exercises_cal.tr()}',
                  style: AppTextStyles.white14bold.copyWith(
                    color: colors.white,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPill({required BuildContext context, required Widget child}) {
    final colors = context.colors;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: colors.grey.withValues(alpha: 0.4),
          width: 1.2,
        ),
      ),
      child: Center(child: child),
    );
  }
}
