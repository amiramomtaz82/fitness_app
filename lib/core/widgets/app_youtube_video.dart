import 'dart:async';

import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/youtube/youtube_playback_failure.dart';
import 'package:fitness_app/core/youtube/youtube_player_overlay.dart';
import 'package:fitness_app/core/youtube/youtube_video_controller.dart';
import 'package:fitness_app/core/youtube/youtube_video_id.dart';
import 'package:fitness_app/core/youtube/youtube_video_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

/// Plays [videoUrl] inside the app.
///
/// Pass [showBackButton] and [onBack] to leave the screen from the video.
/// Leave [createController] null outside tests. A failed play can be retried
/// from the refresh button, which closes the current player and opens another.
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
  State<AppYoutubeVideo> createState() => _AppYoutubeVideoState();
}

class _AppYoutubeVideoState extends State<AppYoutubeVideo> {
  YoutubeVideoController? _controller;
  StreamSubscription<YoutubePlayerValue>? _subscription;
  String? _videoId;
  bool _awaitingPlay = false;
  bool _playFailed = false;
  bool _playerError = false;
  bool _fullscreen = false;

  @override
  void initState() {
    super.initState();
    _videoId = extractYoutubeVideoId(widget.videoUrl);
  }

  @override
  void didUpdateWidget(covariant AppYoutubeVideo oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl == widget.videoUrl) return;
    _releaseController();
    _videoId = extractYoutubeVideoId(widget.videoUrl);
  }

  @override
  void dispose() {
    _releaseController();
    super.dispose();
  }

  void _play() {
    final videoId = _videoId;
    if (videoId == null || _controller != null) return;

    final YoutubeVideoController controller;
    try {
      _awaitingPlay = true;
      final create =
          widget.createController ?? IframeYoutubeVideoController.open;
      controller = create(videoId);
    } catch (_) {
      setState(() {
        _awaitingPlay = false;
        _playFailed = true;
      });
      return;
    }
    setState(() {
      _controller = controller;
      _playFailed = false;
      _playerError = false;
    });
    _subscription = controller.listen(_onPlayerValue);
  }

  void _onPlayerValue(YoutubePlayerValue value) {
    final controller = _controller;
    if (!mounted || controller == null) return;
    if (_awaitingPlay && value.playerState == PlayerState.cued) {
      _awaitingPlay = false;
      unawaited(_startPlayback(controller));
    }
    final fullscreen = value.fullScreenOption.enabled;
    final playerError = value.hasError;
    if (fullscreen == _fullscreen && playerError == _playerError) return;
    setState(() {
      _fullscreen = fullscreen;
      _playerError = playerError;
    });
  }

  Future<void> _startPlayback(YoutubeVideoController controller) async {
    try {
      await controller.play();
    } catch (_) {
      if (!mounted || !identical(_controller, controller)) return;
      setState(() => _playFailed = true);
    }
  }

  void _retryPlay() {
    _releaseController();
    _play();
  }

  void _releaseController() {
    _subscription?.cancel();
    _subscription = null;
    final controller = _controller;
    _controller = null;
    _awaitingPlay = false;
    _playFailed = false;
    _playerError = false;
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
                onPlay: _playFailed ? null : _play,
              )
            else
              _ActivePlayer(
                key: ValueKey(videoId),
                controller: controller,
                aspectRatio: widget.aspectRatio,
                showBackButton: widget.showBackButton,
                onBack: widget.onBack,
                playerError: _playerError,
                playFailed: _playFailed,
                onRetry: _retryPlay,
                fullscreen: _fullscreen,
              ),
            if (_playFailed && controller == null)
              PlaybackFailure(onRetry: _retryPlay),
            if (widget.showBackButton && controller == null)
              BackOverlay(onBack: widget.onBack),
          ],
        ),
      ),
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
    required this.playerError,
    required this.playFailed,
    required this.onRetry,
    required this.fullscreen,
  });

  final YoutubeVideoController controller;
  final double aspectRatio;
  final bool showBackButton;
  final VoidCallback? onBack;
  final bool playerError;
  final bool playFailed;
  final VoidCallback onRetry;
  final bool fullscreen;

  @override
  Widget build(BuildContext context) {
    final showOverlay = playFailed || (showBackButton && !fullscreen);
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
        if (showOverlay)
          PlayerOverlay(
            showBackButton: showBackButton && !fullscreen,
            onBack: onBack,
            playFailed: playFailed,
            onRetry: onRetry,
          ),
      ],
    );
  }

  Widget controls(BuildContext context, bool _) {
    if (!playerError || playFailed) return const SizedBox.shrink();
    return const PlaybackFailure();
  }
}
