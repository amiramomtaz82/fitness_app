import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

class ThumbnailSurface extends StatelessWidget {
  const ThumbnailSurface({
    super.key,
    required this.videoId,
    this.onPlay,
    this.showImage = true,
  });

  final String videoId;
  final VoidCallback? onPlay;
  final bool showImage;

  @override
  Widget build(BuildContext context) {
    final image = thumbnailLayer(showImage, videoId);
    final play = onPlay;
    if (play == null) return image;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: play,
      child: Stack(
        fit: StackFit.expand,
        children: [
          image,
          const Center(child: PlayButton()),
        ],
      ),
    );
  }
}

String jpegThumbnailUrl(String videoId) {
  return YoutubePlayerController.getThumbnail(
    videoId: videoId,
    quality: ThumbnailQuality.high,
    format: ThumbnailFormat.jpeg,
  );
}

Widget thumbnailLayer(bool showImage, String videoId) {
  if (!showImage) return const SizedBox.expand();
  return ThumbnailImage(videoId: videoId);
}

class ThumbnailImage extends StatelessWidget {
  const ThumbnailImage({super.key, required this.videoId});

  final String videoId;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Image.network(
          jpegThumbnailUrl(videoId),
          fit: BoxFit.cover,
          gaplessPlayback: true,
          cacheWidth: cachePixels(constraints.maxWidth, devicePixelRatio),
          cacheHeight: cachePixels(constraints.maxHeight, devicePixelRatio),
          loadingBuilder: (_, child, progress) =>
              progress == null ? child : surface(context),
          errorBuilder: (_, _, _) => surface(context),
        );
      },
    );
  }

  int? cachePixels(double size, double devicePixelRatio) {
    if (!size.isFinite || size <= 0) return null;
    return (size * devicePixelRatio).round();
  }

  Widget surface(BuildContext context) {
    return ColoredBox(color: context.colors.surface);
  }
}

class UnavailableSurface extends StatelessWidget {
  const UnavailableSurface({super.key, this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('app_youtube_video_unavailable'),
      color: color ?? context.colors.background,
    );
  }
}

class PlayButton extends StatelessWidget {
  const PlayButton({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return DecoratedBox(
      key: const Key('app_youtube_video_play'),
      decoration: BoxDecoration(
        color: colors.surface.withValues(alpha: 0.72),
        shape: BoxShape.circle,
      ),
      child: Padding(
        padding: EdgeInsets.all(10.r),
        child: Icon(Icons.play_arrow_rounded, color: colors.white, size: 36.r),
      ),
    );
  }
}
