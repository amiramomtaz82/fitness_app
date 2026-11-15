import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/core/youtube/youtube_video_id.dart';
import 'package:fitness_app/core/youtube/youtube_video_thumbnail.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExerciseListItem extends StatelessWidget {
  final ExerciseEntity exercise;
  final bool isPlaying;
  final VoidCallback onPlay;

  const ExerciseListItem({
    super.key,
    required this.exercise,
    this.isPlaying = false,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final videoUrl = exercise.shortVideoUrl.isNotEmpty
        ? exercise.shortVideoUrl
        : exercise.explanationVideoUrl;
    final videoId = extractYoutubeVideoId(videoUrl);

    final equipmentText = exercise.primaryEquipment.isNotEmpty
        ? exercise.primaryEquipment
        : 'Barbell';
    final difficultyText = exercise.difficultyLevel.isNotEmpty
        ? exercise.difficultyLevel
        : 'Beginner';
    final subtitleInfo = '$equipmentText • $difficultyText';

    return InkWell(
      onTap: onPlay,
      child: Container(
        color: isPlaying
            ? colors.surface.withValues(alpha: 0.5)
            : Colors.transparent,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                width: 76.w,
                height: 76.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  border: isPlaying
                      ? Border.all(color: colors.primary, width: 2)
                      : null,
                ),
                child: videoId != null
                    ? ThumbnailImage(videoId: videoId)
                    : Container(
                        color: colors.surface,
                        child: Icon(
                          Icons.fitness_center,
                          color: colors.primary,
                          size: 32.sp,
                        ),
                      ),
              ),
            ),
            SizedBox(width: 14.w),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    exercise.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.white14bold.copyWith(
                      fontSize: 16.sp,
                      color: isPlaying ? colors.primary : colors.white,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '3 Groups * 15 Times',
                    style: AppTextStyles.grey12regular.copyWith(
                      color: colors.grey,
                      fontSize: 12.sp,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitleInfo,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.grey12regular.copyWith(
                      color: colors.hint,
                      fontSize: 11.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 12.w),

            Material(
              color: colors.primary,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onPlay,
                customBorder: const CircleBorder(),
                child: SizedBox(
                  width: 38.r,
                  height: 38.r,
                  child: Icon(
                    isPlaying
                        ? Icons.volume_up_rounded
                        : Icons.play_arrow_rounded,
                    color: colors.white,
                    size: 24.r,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
