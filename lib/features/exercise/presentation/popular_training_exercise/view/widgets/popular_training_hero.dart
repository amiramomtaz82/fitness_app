import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/core/widgets/app_back_button.dart';
import 'package:fitness_app/core/youtube/youtube_video_thumbnail.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/levels_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PopularTrainingHero extends StatelessWidget {
  final String? backgroundVideoId;
  final String title;
  final List<String> levels;
  final String selectedLevel;
  final ValueChanged<String> onLevelSelected;

  const PopularTrainingHero({
    super.key,
    required this.backgroundVideoId,
    required this.title,
    required this.levels,
    required this.selectedLevel,
    required this.onLevelSelected,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final videoId = backgroundVideoId;
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomRadius = BorderRadius.vertical(bottom: Radius.circular(24.r));
    return SizedBox(
      height: 440.h,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: bottomRadius,
              child: videoId != null
                  ? ThumbnailImage(videoId: videoId)
                  : ColoredBox(color: colors.card),
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: bottomRadius,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    colors.background.withValues(alpha: 0.45),
                    colors.background.withValues(alpha: 0.9),
                  ],
                  stops: const [0.3, 0.65, 1.0],
                ),
              ),
            ),
          ),
          PositionedDirectional(
            bottom: 0,
            start: 0,
            end: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(
                    16.w,
                    44.h,
                    16.w,
                    8.h,
                  ),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: AppTextStyles.white20bold.copyWith(
                      fontSize: 22.sp,
                    ),
                  ),
                ),
                LevelsBar(
                  levels: levels,
                  selectedLevel: selectedLevel,
                  onLevelSelected: onLevelSelected,
                ),
              ],
            ),
          ),
          PositionedDirectional(
            top: topInset + 16.h,
            start: 16.w,
            child: const AppBackButton(),
          ),
        ],
      ),
    );
  }
}
