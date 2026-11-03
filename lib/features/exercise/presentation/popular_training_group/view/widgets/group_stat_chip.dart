import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class GroupStatChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const GroupStatChip({super.key, required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.r, color: colors.secondary),
          SizedBox(width: 6.w),
          Text(
            label,
            style: AppTextStyles.white14regular.copyWith(fontSize: 12.sp),
          ),
        ],
      ),
    );
  }
}
