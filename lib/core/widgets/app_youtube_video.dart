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
  State<AppYoutubeVideo> createState() => _AppYoutubeVideoState();
}

class _AppYoutubeVideoState extends State<AppYoutubeVideo> {
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
    _releaseController();
    _videoId = youtubeVideoId(widget.videoUrl);
  }

  @override
  void dispose() {
    _releaseController();
    super.dispose();
  }

  void _play() {
    final videoId = _videoId;
    if (videoId == null || _controller != null) return;
    try {
      final controller = _newController(videoId);
      _subscription = controller.listen(_onPlayerValue);
      setState(() => _controller = controller);
    } catch (_) {
      _awaitingPlay = false;
      setState(() => _playbackFailed = true);
    }
  }

  YoutubePlayerController _newController(String videoId) {
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

  void _onPlayerValue(YoutubePlayerValue value) {
    final controller = _controller;
    if (!mounted || controller == null) return;
    _playWhenCued(controller, value);
    if (value.hasError == _playbackFailed) return;
    setState(() => _playbackFailed = value.hasError);
  }

  void _playWhenCued(
    YoutubePlayerController controller,
    YoutubePlayerValue value,
  ) {
    if (!_awaitingPlay || value.playerState != PlayerState.cued) return;
    _awaitingPlay = false;
    unawaited(_startPlayback(controller));
  }

  Future<void> _startPlayback(YoutubePlayerController controller) async {
    try {
      await controller.playVideo();
    } catch (_) {
      if (!mounted || !identical(_controller, controller)) return;
      setState(() => _playbackFailed = true);
    }
  }

  void _releaseController() {
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
            _surface(controller),
            if (_playbackFailed && controller == null) const _PlaybackFailure(),
            if (widget.showBackButton && controller == null)
              _BackOverlay(onBack: widget.onBack),
          ],
        ),
      ),
    );
  }

  Widget _surface(YoutubePlayerController? controller) {
    final videoId = _videoId;
    if (videoId == null) return const _UnavailableSurface();
    if (controller == null) {
      return _ThumbnailSurface(videoId: videoId, onPlay: _play);
    }
    return _ActivePlayer(
      key: ValueKey(videoId),
      controller: controller,
      aspectRatio: widget.aspectRatio,
      showBackButton: widget.showBackButton,
      onBack: widget.onBack,
      showFailure: _playbackFailed,
    );
  }
}

class _ActivePlayer extends StatelessWidget {
  const _ActivePlayer({
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
      controlsBuilder: _controls,
    );
  }

  Widget _controls(BuildContext context, bool isFullscreen) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (showFailure) const _PlaybackFailure(),
        if (showBackButton && !isFullscreen) _BackOverlay(onBack: onBack),
      ],
    );
  }
}

class _ThumbnailSurface extends StatelessWidget {
  const _ThumbnailSurface({required this.videoId, required this.onPlay});

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
          _ThumbnailImage(videoId: videoId),
          const Center(child: _PlayButton()),
        ],
      ),
    );
  }
}

class _ThumbnailImage extends StatelessWidget {
  const _ThumbnailImage({required this.videoId});

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
          progress == null ? child : _surface(context),
      errorBuilder: (_, _, _) => _surface(context),
    );
  }

  Widget _surface(BuildContext context) {
    return ColoredBox(color: context.colors.surface);
  }
}

class _UnavailableSurface extends StatelessWidget {
  const _UnavailableSurface();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      key: const Key('app_youtube_video_unavailable'),
      color: context.colors.background,
    );
  }
}

class _PlaybackFailure extends StatelessWidget {
  const _PlaybackFailure();

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

class _PlayButton extends StatelessWidget {
  const _PlayButton();

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

class _BackOverlay extends StatelessWidget {
  const _BackOverlay({required this.onBack});

  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return PositionedDirectional(
      top: 12.h,
      start: 12.w,
      child: _VideoBackButton(onPressed: onBack),
    );
  }
}

class _VideoBackButton extends StatelessWidget {
  const _VideoBackButton({required this.onPressed});

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
