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
        child: foodMediaStack(videoUrl, thumbnailUrl, video, caption),
      ),
    );
  }
}

Widget foodMediaStack(
  String? videoUrl,
  String? thumbnailUrl,
  Widget video,
  Widget caption,
) {
  return Stack(
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
  );
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
    final photo = foodPhotoFrame(image);
    if (!blurred) {
      return photo;
    }
    return ClipRect(
      child: ImageFiltered(imageFilter: foodCardBlur, child: photo),
    );
  }
}

Widget foodPhotoFrame(ImageProvider? image) {
  final provider = image;
  if (provider == null) {
    return const ColoredBox(color: foodDetailsPanel);
  }
  return FoodDetailsPhotoImage(image: provider);
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

String foodThumbnailUrl(String videoId) {
  return YoutubePlayerController.getThumbnail(
    videoId: videoId,
    quality: ThumbnailQuality.high,
    format: ThumbnailFormat.jpeg,
  );
}

NetworkImage foodThumbnail(String videoId) {
  return NetworkImage(foodThumbnailUrl(videoId));
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
        child: const DecoratedBox(decoration: foodShadeDecoration),
      ),
    );
  }
}

const foodShadeDecoration = BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x00242424), Color(0x99242424), Color(0xF2242424)],
    stops: [0, 0.45, 1],
  ),
);
