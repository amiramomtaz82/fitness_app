import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/exercise_chevron.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExerciseVideoTile extends StatelessWidget {
  final String labelKey;
  final VoidCallback onTap;

  const ExerciseVideoTile({
    super.key,
    required this.labelKey,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          children: [
            Icon(
              Icons.play_circle_outline_rounded,
              color: colors.secondary,
              size: 24.r,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(labelKey.tr(), style: AppTextStyles.white14regular),
            ),
            const ExerciseChevron(),
          ],
        ),
      ),
    );
  }
}
