import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/widgets/app_youtube_video.dart';
import 'package:flutter/material.dart';

class ExerciseVideoView extends StatelessWidget {
  final String videoUrl;

  const ExerciseVideoView({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AppYoutubeVideo(
          videoUrl: videoUrl,
          showBackButton: true,
          onBack: () => Navigator.maybePop(context),
        ),
      ),
    );
  }
}
