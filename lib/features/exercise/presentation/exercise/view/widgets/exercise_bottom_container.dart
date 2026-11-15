import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'exercise_list_item.dart';

class ExerciseBottomContainer extends StatelessWidget {
  final List<ExerciseEntity> exercises;
  final String? activeExerciseId;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  final bool hasMore;
  final VoidCallback onRetry;
  final VoidCallback onLoadMore;
  final ValueChanged<ExerciseEntity> onPlayExercise;

  const ExerciseBottomContainer({
    super.key,
    required this.exercises,
    this.activeExerciseId,
    required this.isLoading,
    required this.isError,
    this.errorMessage,
    required this.hasMore,
    required this.onRetry,
    required this.onLoadMore,
    required this.onPlayExercise,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        child: _buildContent(context),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final colors = context.colors;

    if (isLoading && exercises.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48.h),
          child: CircularProgressIndicator(color: colors.primary),
        ),
      );
    }

    if (isError && exercises.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(24.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: colors.error, size: 48.r),
              SizedBox(height: 12.h),
              Text(
                errorMessage ?? 'An error occurred',
                textAlign: TextAlign.center,
                style: AppTextStyles.grey14bold.copyWith(color: colors.grey),
              ),
              SizedBox(height: 16.h),
              ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: colors.primary,
                  foregroundColor: colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                ),
                child: Text(LocaleKeys.common_retry.tr()),
              ),
            ],
          ),
        ),
      );
    }

    if (exercises.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 48.h, horizontal: 24.w),
          child: Text(
            LocaleKeys.exercises_no_exercises.tr(),
            textAlign: TextAlign.center,
            style: AppTextStyles.grey14bold.copyWith(color: colors.grey),
          ),
        ),
      );
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (scrollInfo) {
        if (scrollInfo.metrics.pixels >=
                scrollInfo.metrics.maxScrollExtent - 100 &&
            hasMore &&
            !isLoading) {
          onLoadMore();
        }
        return false;
      },
      child: ListView.separated(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        itemCount: exercises.length + (hasMore ? 1 : 0),
        separatorBuilder: (_, __) => Divider(
          color: colors.white.withValues(alpha: 0.08),
          height: 1.h,
          indent: 16.w,
          endIndent: 16.w,
        ),
        itemBuilder: (context, index) {
          if (index == exercises.length) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: CircularProgressIndicator(color: colors.primary),
              ),
            );
          }
          final exercise = exercises[index];
          return ExerciseListItem(
            exercise: exercise,
            isPlaying: exercise.id == activeExerciseId,
            onPlay: () => onPlayExercise(exercise),
          );
        },
      ),
    );
  }
}
