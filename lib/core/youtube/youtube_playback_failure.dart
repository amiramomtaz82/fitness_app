import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PlaybackFailure extends StatelessWidget {
  const PlaybackFailure({super.key, this.onRetry});

  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final retry = onRetry;
    final icon = Icon(
      Icons.error_outline,
      color: context.colors.white,
      size: 36.r,
    );
    if (retry == null) {
      return IgnorePointer(
        child: ColoredBox(
          key: const Key('app_youtube_video_error'),
          color: context.colors.background.withValues(alpha: 0.72),
          child: Center(child: icon),
        ),
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        AbsorbPointer(
          child: ColoredBox(
            key: const Key('app_youtube_video_error'),
            color: context.colors.background.withValues(alpha: 0.72),
            child: const SizedBox.expand(),
          ),
        ),
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              icon,
              SizedBox(height: 12.h),
              GestureDetector(
                key: const Key('app_youtube_video_retry'),
                onTap: retry,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: context.colors.surface.withValues(alpha: 0.72),
                    shape: BoxShape.circle,
                  ),
                  child: Padding(
                    padding: EdgeInsets.all(10.r),
                    child: Icon(
                      Icons.refresh,
                      color: context.colors.white,
                      size: 36.r,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
