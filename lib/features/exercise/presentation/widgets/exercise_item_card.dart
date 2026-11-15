import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/exercise_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExerciseItemCard extends StatelessWidget {
  final String name;
  final String? subtitle;
  final String? videoId;
  final Widget trailing;
  final VoidCallback? onTap;

  const ExerciseItemCard({
    super.key,
    required this.name,
    required this.trailing,
    this.subtitle,
    this.videoId,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final detail = subtitle;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        child: Row(
          children: [
            ExerciseThumbnail(videoId: videoId),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppTextStyles.white14bold,
                  ),
                  if (detail != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      detail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.grey12regular,
                    ),
                  ],
                ],
              ),
            ),
            SizedBox(width: 8.w),
            trailing,
          ],
        ),
      ),
    );
  }
}
