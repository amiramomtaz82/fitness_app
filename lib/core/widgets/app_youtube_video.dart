import 'dart:async';

import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/youtube/youtube_video_id.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Plays [videoUrl] inside the widget. A video that disallows embedding
/// stays on the error state.
class AppYoutubeVideo extends StatefulWidget {
  const AppYoutubeVideo({
    super.key,
    required this.videoUrl,
    this.showBackButton = false,
    this.onBack,
    this.aspectRatio = 16 / 9,
  });

  final String videoUrl;
  final bool showBackButton;
  final VoidCallback? onBack;
  final double aspectRatio;

  @override
  State<AppYoutubeVideo> createState() => AppYoutubeVideoState();
}

class AppYoutubeVideoState extends State<AppYoutubeVideo> {
  YoutubePlayerController? _controller;
  StreamSubscription<YoutubePlayerValue>? _subscription;
  String? _videoId;
  bool _awaitingPlay = false;
  bool _playbackFailed = false;

  @override
  void initState() {
    super.initState();
    _videoId = youtubeVideoId(widget.videoUrl);
  }

  @override
  void didUpdateWidget(covariant AppYoutubeVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl == widget.videoUrl) return;
    releaseController();
    _videoId = youtubeVideoId(widget.videoUrl);
  }

  @override
  void dispose() {
    releaseController();
    super.dispose();
  }

  void play() {
    final videoId = _videoId;
    if (videoId == null || _controller != null) return;
    try {
      final controller = newController(videoId);
      _subscription = controller.listen(onPlayerValue);
      setState(() => _controller = controller);
    } catch (_) {
      _awaitingPlay = false;
      setState(() => _playbackFailed = true);
    }
  }

  YoutubePlayerController newController(String videoId) {
    _awaitingPlay = true;
    return YoutubePlayerController.fromVideoId(
      videoId: videoId,
      autoPlay: false,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: false,
        playsInline: true,
      ),
    );
  }

  void onPlayerValue(YoutubePlayerValue value) {
    final controller = _controller;
    if (!mounted || controller == null) return;
    playWhenCued(controller, value);
    if (value.hasError == _playbackFailed) return;
    setState(() => _playbackFailed = value.hasError);
  }

  void playWhenCued(
    YoutubePlayerController controller,
    YoutubePlayerValue value,
  ) {
    if (!_awaitingPlay || value.playerState != PlayerState.cued) return;
    _awaitingPlay = false;
    unawaited(startPlayback(controller));
  }

  Future<void> startPlayback(YoutubePlayerController controller) async {
    try {
      await controller.playVideo();
    } catch (_) {
      if (!mounted || !identical(_controller, controller)) return;
      setState(() => _playbackFailed = true);
    }
  }

  void releaseController() {
    _subscription?.cancel();
    _subscription = null;
    final controller = _controller;
    _controller = null;
    _awaitingPlay = false;
    _playbackFailed = false;
    if (controller == null) return;
    controller.close().ignore();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: ColoredBox(
        color: context.colors.background,
        child: Stack(
          fit: StackFit.expand,
          children: [
            surface(controller),
            if (_playbackFailed && controller == null) const PlaybackFailure(),
            if (widget.showBackButton && controller == null)
              BackOverlay(onBack: widget.onBack),
          ],
        ),
      ),
    );
  }

  Widget surface(YoutubePlayerController? controller) {
    final videoId = _videoId;
    if (videoId == null) return const UnavailableSurface();
    if (controller == null) {
      return ThumbnailSurface(videoId: videoId, onPlay: play);
    }
    return ActivePlayer(
      key: ValueKey(videoId),
      controller: controller,
      aspectRatio: widget.aspectRatio,
      showBackButton: widget.showBackButton,
      onBack: widget.onBack,
      showFailure: _playbackFailed,
    );
  }
}

class ActivePlayer extends StatelessWidget {
  const ActivePlayer({
    super.key,
    required this.controller,
    required this.aspectRatio,
    required this.showBackButton,
    required this.onBack,
    required this.showFailure,
  });

  final YoutubePlayerController controller;
  final double aspectRatio;
  final bool showBackButton;
  final VoidCallback? onBack;
  final bool showFailure;

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: controller,
      aspectRatio: aspectRatio,
      autoFullScreen: false,
      enableFullScreenOnVerticalDrag: false,
      gestureRecognizers: const {},
      backgroundColor: context.colors.background,
      // The player WebView covers a back button placed outside this builder.
      controlsBuilder: controls,
    );
  }

  Widget controls(BuildContext context, bool isFullscreen) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (showFailure) const PlaybackFailure(),
        if (showBackButton && !isFullscreen) BackOverlay(onBack: onBack),
      ],
    );
  }
}

class ThumbnailSurface extends StatelessWidget {
  const ThumbnailSurface({
    super.key,
    required this.videoId,
    required this.onPlay,
  });

  final String videoId;
  final VoidCallback onPlay;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPlay,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ThumbnailImage(videoId: videoId),
          const Center(child: PlayButton()),
        ],
      ),
    );
  }
}

class ThumbnailImage extends StatelessWidget {
  const ThumbnailImage({super.key, required this.videoId});

  final String videoId;

  @override
  Widget build(BuildContext context) {
    return Image.network(
      YoutubePlayerController.getThumbnail(
        videoId: videoId,
        quality: ThumbnailQuality.high,
      ),
      fit: BoxFit.cover,
      loadingBuilder: (_, child, progress) =>
          progress == null ? child : surface(context),
      errorBuilder: (_, _, _) => surface(context),
    );
  }

  Widget surface(BuildContext context) {
    return ColoredBox(color: context.colors.surface);
  }
}

class UnavailableSurface extends StatelessWidget {
  const UnavailableSurface({super.key});

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('app_youtube_video_unavailable'),
      color: context.colors.background,
    );
  }
}

class PlaybackFailure extends StatelessWidget {
  const PlaybackFailure({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ColoredBox(
        key: const Key('app_youtube_video_error'),
        color: context.colors.background.withValues(alpha: 0.72),
        child: Center(
          child: Icon(
            Icons.error_outline,
            color: context.colors.white,
            size: 36.r,
          ),
        ),
      ),
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

class BackOverlay extends StatelessWidget {
  const BackOverlay({super.key, required this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: 12.h,
      start: 12.w,
      child: VideoBackButton(onPressed: onBack),
    );
  }
}

class VideoBackButton extends StatelessWidget {
  const VideoBackButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.surface.withValues(alpha: 0.72),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        key: const Key('app_youtube_video_back'),
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: SizedBox(
          width: 40.r,
          height: 40.r,
          child: Icon(
            Icons.arrow_back_ios_new,
            color: colors.primary,
            size: 18.r,
          ),
        ),
      ),
    );
  }
}
