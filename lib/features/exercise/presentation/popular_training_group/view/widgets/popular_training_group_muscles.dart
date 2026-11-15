import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view/widgets/group_stat_chip.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PopularTrainingGroupMuscles extends StatelessWidget {
  final List<String> muscleNames;

  const PopularTrainingGroupMuscles({super.key, required this.muscleNames});

  @override
  Widget build(BuildContext context) {
    if (muscleNames.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.exercises_related_muscles.tr(),
          style: AppTextStyles.white20bold,
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            for (final name in muscleNames)
              GroupStatChip(icon: Icons.accessibility_new_rounded, label: name),
          ],
        ),
      ],
    );
  }
}
