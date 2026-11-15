import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/widgets/app_image_placeholder.dart';
import 'package:fitness_app/core/youtube/youtube_video_thumbnail.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';

class ExerciseVideoImage extends StatelessWidget {
  final String? videoId;

  const ExerciseVideoImage({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    final id = videoId;

    return id == null
        ? AppImagePlaceholder(message: LocaleKeys.exercises_not_available.tr())
        : ThumbnailImage(videoId: id);
  }
}
