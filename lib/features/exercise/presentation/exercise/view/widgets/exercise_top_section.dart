import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/core/widgets/app_catgory_tab_bar.dart';
import 'package:fitness_app/core/youtube/youtube_player_overlay.dart';
import 'package:fitness_app/core/youtube/youtube_video_thumbnail.dart';
import 'package:fitness_app/features/exercise/domain/entities/difficulty_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'time_calorie_widget.dart';

class ExerciseTopSection extends StatelessWidget {
  final String? videoId;
  final String muscleName;
  final String? title;
  final String? description;
  final String? timeText;
  final String? caloriesText;
  final List<DifficultyLevelEntity> difficultyLevels;
  final String? selectedDifficultyId;
  final ValueChanged<int> onCategorySelected;
  final VoidCallback onBack;
  final VoidCallback? onPlayVideo;

  const ExerciseTopSection({
    super.key,
    required this.videoId,
    required this.muscleName,
    this.title,
    this.description,
    this.timeText,
    this.caloriesText,
    required this.difficultyLevels,
    required this.selectedDifficultyId,
    required this.onCategorySelected,
    required this.onBack,
    this.onPlayVideo,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final headerTitle = title ??
        (muscleName.isNotEmpty ? '$muscleName Exercise' : 'Chest Exercise');
    final headerDescription = description ??
        'Lorem Ipsum Dolor Sit Amet Consectetur. Tempus Volutpat Ut Nisi Morbi.';

    final categories = difficultyLevels.isNotEmpty
        ? difficultyLevels.map((d) => d.name).toList()
        : const ['Beginner', 'Intermediate', 'Advanced'];

    final selectedIndex = difficultyLevels.isNotEmpty
        ? difficultyLevels.indexWhere((d) => d.id == selectedDifficultyId)
        : 0;

    final effectiveIndex = selectedIndex >= 0 ? selectedIndex : 0;

    return Stack(
      children: [
        // Background Video Thumbnail Surface
        Positioned.fill(
          child: videoId != null && videoId!.isNotEmpty
              ? ThumbnailSurface(
                  videoId: videoId!,
                  onPlay: onPlayVideo,
                )
              : const UnavailableSurface(),
        ),

        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.4),
                    Colors.black.withValues(alpha: 0.7),
                    colors.background.withValues(alpha: 0.95),
                    colors.background,
                  ],
                  stops: const [0.0, 0.4, 0.8, 1.0],
                ),
              ),
            ),
          ),
        ),

        SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                child: Row(
                  children: [
                    VideoBackButton(onPressed: onBack),
                  ],
                ),
              ),

              SizedBox(height: 12.h),

              // Title
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Text(
                  headerTitle,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.white20bold.copyWith(
                    fontSize: 24.sp,
                    color: colors.white,
                  ),
                ),
              ),

              SizedBox(height: 8.h),

              // Description
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.w),
                child: Text(
                  headerDescription,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.white14regular.copyWith(
                    color: colors.grey,
                    fontSize: 13.sp,
                    height: 1.3,
                  ),
                ),
              ),

              SizedBox(height: 16.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: TimeCalorieWidget(
                  time: timeText,
                  calories: caloriesText,
                ),
              ),

              SizedBox(height: 16.h),
              AppCategoryTabBar(
                categories: categories,
                selectedIndex: effectiveIndex,
                onCategorySelected: onCategorySelected,
              ),

              SizedBox(height: 8.h),
            ],
          ),
        ),
      ],
    );
  }
}
