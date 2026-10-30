import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../../../../../core/youtube/youtube_video_id.dart';
import 'food_details_nutrition.dart';

const foodPlayerAspectRatio = 16 / 9;

const foodMediaAspectRatio = 375 / 430;

const foodPlayerShareOfMedia = foodMediaAspectRatio / foodPlayerAspectRatio;

const foodMediaBottomBand = 1 - foodPlayerShareOfMedia;

class FoodDetailsMedia extends StatelessWidget {
  const FoodDetailsMedia({
    super.key,
    required this.videoUrl,
    required this.thumbnailUrl,
    required this.video,
    required this.caption,
  });

  final String? videoUrl;
  final String? thumbnailUrl;
  final Widget video;
  final Widget caption;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
      child: AspectRatio(
        aspectRatio: foodMediaAspectRatio,
        child: Stack(
          children: [
            Positioned.fill(
              child: FoodDetailsPhoto(
                image: foodBackdropImage(videoUrl, thumbnailUrl),
              ),
            ),
            video,
            const Positioned.fill(child: FoodDetailsShadeBand()),
            caption,
          ],
        ),
      ),
    );
  }
}

class FoodDetailsPhoto extends StatelessWidget {
  const FoodDetailsPhoto({
    super.key,
    required this.image,
    this.blurred = false,
  });

  final ImageProvider? image;
  final bool blurred;

  @override
  Widget build(BuildContext context) {
    final image = this.image;
    return ClipRect(
      clipBehavior: blurred ? Clip.hardEdge : Clip.none,
      child: ImageFiltered(
        enabled: blurred,
        imageFilter: foodCardBlur,
        child: image == null
            ? const ColoredBox(color: foodDetailsPanel)
            : FoodDetailsPhotoImage(image: image),
      ),
    );
  }
}

class FoodDetailsPhotoImage extends StatelessWidget {
  const FoodDetailsPhotoImage({super.key, required this.image});

  final ImageProvider image;

  @override
  Widget build(BuildContext context) {
    return Image(
      image: image,
      fit: BoxFit.cover,
      alignment: Alignment.topCenter,
      gaplessPlayback: true,
      errorBuilder: foodBackdropFallback,
      loadingBuilder: foodBackdropLoading,
    );
  }
}

ImageProvider? foodBackdropImage(String? videoUrl, String? thumbnailUrl) {
  final photo = mealPhoto(thumbnailUrl);
  if (photo != null) {
    return photo;
  }
  final videoId = extractYoutubeVideoId(videoUrl ?? '');
  if (videoId == null) {
    return null;
  }
  return foodThumbnail(videoId);
}

ImageProvider? mealPhoto(String? thumbnailUrl) {
  final url = thumbnailUrl?.trim() ?? '';
  if (url.isEmpty) {
    return null;
  }
  return NetworkImage(url);
}

NetworkImage foodThumbnail(String videoId) {
  return NetworkImage(
    YoutubePlayerController.getThumbnail(
      videoId: videoId,
      quality: ThumbnailQuality.high,
      format: ThumbnailFormat.jpeg,
    ),
  );
}

Widget foodBackdropFallback(BuildContext context, Object error, StackTrace? _) {
  return const ColoredBox(color: foodDetailsPanel);
}

Widget foodBackdropLoading(
  BuildContext context,
  Widget child,
  ImageChunkEvent? progress,
) {
  if (progress == null) {
    return child;
  }
  return const ColoredBox(color: foodDetailsPanel);
}

class FoodDetailsShadeBand extends StatelessWidget {
  const FoodDetailsShadeBand({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: Align(
        alignment: Alignment.bottomCenter,
        child: FractionallySizedBox(
          heightFactor: foodMediaBottomBand,
          widthFactor: 1,
          child: FoodDetailsShadeFill(),
        ),
      ),
    );
  }
}

class FoodDetailsShadeFill extends StatelessWidget {
  const FoodDetailsShadeFill({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: foodCaptionBlur,
        child: DecoratedBox(decoration: foodShadeDecoration),
      ),
    );
  }
}

final foodShadeDecoration = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      foodDetailsPanel.withValues(alpha: 0),
      foodDetailsPanel.withValues(alpha: 0x99 / 0xFF),
      foodDetailsPanel.withValues(alpha: 0xF2 / 0xFF),
    ],
    stops: const [0, 0.45, 1],
  ),
);
