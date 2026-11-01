import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/core/youtube/youtube_video_id.dart';
import 'package:fitness_app/features/exercise/domain/entities/exercise_entity.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/exercise_thumbnail.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/play_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PopularTrainingExerciseCard extends StatelessWidget {
  final ExerciseEntity exercise;
  final VoidCallback onPlay;

  const PopularTrainingExerciseCard({
    super.key,
    required this.exercise,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          ExerciseThumbnail(
            videoId: extractYoutubeVideoId(
              exercise.shortYoutubeDemonstrationLink ?? '',
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.exercise ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.white14bold,
                ),
                SizedBox(height: 4.h),
                Text(
                  exercise.primaryEquipment ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.grey12regular,
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          PlayButton(onPlay: onPlay),
        ],
      ),
    );
  }
}
