import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view/widgets/group_stat_chip.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PopularTrainingGroupStats extends StatelessWidget {
  final int exercisesCount;
  final String levelName;
  final String muscleName;

  const PopularTrainingGroupStats({
    super.key,
    required this.exercisesCount,
    required this.levelName,
    required this.muscleName,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          LocaleKeys.exercises_group_info.tr(),
          style: AppTextStyles.white20bold,
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 8.h,
          children: [
            GroupStatChip(
              icon: Icons.format_list_numbered_rounded,
              label: LocaleKeys.exercises_exercises_count.tr(
                args: ['$exercisesCount'],
              ),
            ),
            GroupStatChip(
              icon: Icons.leaderboard_rounded,
              label: LocaleKeys.exercises_labeled_value.tr(
                args: [LocaleKeys.exercises_level.tr(), levelName],
              ),
            ),
            GroupStatChip(
              icon: Icons.fitness_center_rounded,
              label: LocaleKeys.exercises_labeled_value.tr(
                args: [LocaleKeys.exercises_muscle.tr(), muscleName],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
