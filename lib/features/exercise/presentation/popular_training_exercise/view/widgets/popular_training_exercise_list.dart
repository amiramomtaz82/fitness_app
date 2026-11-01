import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/popular_training_exercise_card.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PopularTrainingExerciseList extends StatelessWidget {
  final List<ExerciseEntity> exercises;
  final ValueChanged<ExerciseEntity> onPlay;

  const PopularTrainingExerciseList({
    super.key,
    required this.exercises,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    if (exercises.isEmpty) {
      return Center(
        child: Text(
          LocaleKeys.exercises_no_exercises_found.tr(),
          style: AppTextStyles.white14regular,
        ),
      );
    }

    return SingleChildScrollView(
      padding: EdgeInsetsDirectional.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colors.card.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          children: [
            for (var i = 0; i < exercises.length; i++) ...[
              if (i > 0)
                Divider(
                  height: 1,
                  thickness: 1,
                  indent: 16.w,
                  endIndent: 16.w,
                  color: colors.white.withValues(alpha: 0.08),
                ),
              PopularTrainingExerciseCard(
                exercise: exercises[i],
                onPlay: () => onPlay(exercises[i]),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
