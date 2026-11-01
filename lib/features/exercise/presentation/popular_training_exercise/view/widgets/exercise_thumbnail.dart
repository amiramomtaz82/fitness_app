import 'package:fitness_app/core/youtube/youtube_video_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExerciseThumbnail extends StatelessWidget {
  final String? videoId;

  const ExerciseThumbnail({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    final id = videoId;
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: SizedBox(
        width: 64.w,
        height: 64.h,
        child: id == null
            ? const ColoredBox(color: Colors.transparent)
            : ThumbnailImage(videoId: id),
      ),
    );
  }
}
