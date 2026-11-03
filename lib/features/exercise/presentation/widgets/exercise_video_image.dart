import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/youtube/youtube_video_thumbnail.dart';
import 'package:flutter/material.dart';

class ExerciseVideoImage extends StatelessWidget {
  final String? videoId;

  const ExerciseVideoImage({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    final id = videoId;

    return id == null
        ? ColoredBox(color: context.colors.card)
        : ThumbnailImage(videoId: id);
  }
}
