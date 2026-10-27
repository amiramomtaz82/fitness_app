import 'dart:async';

import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/youtube/youtube_video_controller.dart';
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
    this.createController,
  });

  final String videoUrl;
  final bool showBackButton;
  final VoidCallback? onBack;
  final double aspectRatio;

  /// Replaces the in-app player. Production leaves this null.
  final YoutubeVideoControllerFactory? createController;

  @override
  State<AppYoutubeVideo> createState() => AppYoutubeVideoState();
}

class AppYoutubeVideoState extends State<AppYoutubeVideo> {
  YoutubeVideoController? _controller;
  StreamSubscription<YoutubePlayerValue>? _subscription;
  String? _videoId;
  bool _awaitingPlay = false;
  bool _playbackFailed = false;
  bool _fullscreen = false;

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

    Future<void> startPlayback(YoutubeVideoController controller) async {
      try {
        await controller.play();
      } catch (_) {
        if (!mounted || !identical(_controller, controller)) return;
        setState(() => _playbackFailed = true);
      }
    }

    void onValue(YoutubePlayerValue value) {
      final controller = _controller;
      if (!mounted || controller == null) return;
      if (_awaitingPlay && value.playerState == PlayerState.cued) {
        _awaitingPlay = false;
        unawaited(startPlayback(controller));
      }
      final fullscreen = value.fullScreenOption.enabled;
      final failed = value.hasError;
      if (fullscreen == _fullscreen && failed == _playbackFailed) return;
      setState(() {
        _fullscreen = fullscreen;
        _playbackFailed = failed;
      });
    }

    final YoutubeVideoController controller;
    try {
      _awaitingPlay = true;
      final create =
          widget.createController ?? IframeYoutubeVideoController.open;
      controller = create(videoId);
    } catch (_) {
      setState(() {
        _awaitingPlay = false;
        _playbackFailed = true;
      });
      return;
    }
    setState(() {
      _controller = controller;
      _playbackFailed = false;
    });
    _subscription = controller.listen(onValue);
  }

  void releaseController() {
    _subscription?.cancel();
    _subscription = null;
    final controller = _controller;
    _controller = null;
    _awaitingPlay = false;
    _playbackFailed = false;
    _fullscreen = false;
    if (controller == null) return;
    controller.close().ignore();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final videoId = _videoId;
    return AspectRatio(
      aspectRatio: widget.aspectRatio,
      child: ColoredBox(
        color: context.colors.background,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (videoId == null)
              const UnavailableSurface()
            else if (controller == null)
              ThumbnailSurface(
                videoId: videoId,
                onPlay: _playbackFailed ? null : play,
              )
            else
              ActivePlayer(
                key: ValueKey(videoId),
                controller: controller,
                aspectRatio: widget.aspectRatio,
                showBackButton: widget.showBackButton,
                onBack: widget.onBack,
                showFailure: _playbackFailed,
                fullscreen: _fullscreen,
              ),
            if (_playbackFailed && controller == null)
              PlaybackFailure(onRetry: play),
            if (widget.showBackButton && controller == null)
              BackOverlay(onBack: widget.onBack),
          ],
        ),
      ),
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
    required this.fullscreen,
  });

  final YoutubeVideoController controller;
  final double aspectRatio;
  final bool showBackButton;
  final VoidCallback? onBack;
  final bool showFailure;
  final bool fullscreen;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        KeyedSubtree(
          key: const Key('app_youtube_video_player'),
          child: controller.buildPlayer(
            context: context,
            aspectRatio: aspectRatio,
            backgroundColor: context.colors.background,
            controls: controls,
          ),
        ),
        if (showBackButton && !fullscreen) PlayerBackButton(onPressed: onBack),
      ],
    );
  }

  Widget controls(BuildContext context, bool _) {
    if (!showFailure) return const SizedBox.shrink();
    return const PlaybackFailure();
  }
}

class ThumbnailSurface extends StatelessWidget {
  const ThumbnailSurface({super.key, required this.videoId, this.onPlay});

  final String videoId;
  final VoidCallback? onPlay;

  @override
  Widget build(BuildContext context) {
    final image = ThumbnailImage(videoId: videoId);
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

class ThumbnailImage extends StatelessWidget {
  const ThumbnailImage({super.key, required this.videoId});

  final String videoId;

  @override
  Widget build(BuildContext context) {
    final devicePixelRatio = MediaQuery.devicePixelRatioOf(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        return Image.network(
          YoutubePlayerController.getThumbnail(
            videoId: videoId,
            quality: ThumbnailQuality.high,
          ),
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
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
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

class PlayerBackButton extends StatefulWidget {
  const PlayerBackButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  State<PlayerBackButton> createState() => PlayerBackButtonState();
}

class PlayerBackButtonState extends State<PlayerBackButton> {
  final LayerLink layerLink = LayerLink();
  final OverlayPortalController portal = OverlayPortalController();

  @override
  void initState() {
    super.initState();
    // The player portal is shown at the end of this frame in release, and one
    // frame later in debug. It absorbs taps during unknown and unStarted.
    // scheduleFrame is required because a post-frame callback does not request
    // the next frame by itself. Showing after that portal keeps this button
    // above it: the last OverlayPortal.show wins.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      WidgetsBinding.instance.scheduleFrame();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        portal.show();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return OverlayPortal.overlayChildLayoutBuilder(
      controller: portal,
      overlayChildBuilder: (context, info) {
        return CompositedTransformFollower(
          link: layerLink,
          showWhenUnlinked: false,
          child: SizedBox(
            width: info.childSize.width,
            height: info.childSize.height,
            child: Stack(children: [BackOverlay(onBack: widget.onPressed)]),
          ),
        );
      },
      child: CompositedTransformTarget(
        link: layerLink,
        child: const SizedBox.expand(),
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
