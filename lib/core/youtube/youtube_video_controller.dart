import 'dart:async';

import 'package:flutter/material.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

typedef YoutubeVideoControllerFactory =
    YoutubeVideoController Function(String videoId);

abstract class YoutubeVideoController {
  StreamSubscription<YoutubePlayerValue> listen(
    void Function(YoutubePlayerValue value) onData,
  );

  Future<void> play();

  Future<void> close();

  Widget buildPlayer({
    required BuildContext context,
    required double aspectRatio,
    required Color backgroundColor,
    required Widget Function(BuildContext context, bool isFullscreen) controls,
  });
}

class IframeYoutubeVideoController implements YoutubeVideoController {
  IframeYoutubeVideoController(this.player);

  final YoutubePlayerController player;

  factory IframeYoutubeVideoController.open(String videoId) {
    return IframeYoutubeVideoController(
      YoutubePlayerController.fromVideoId(
        videoId: videoId,
        autoPlay: false,
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: false,
          playsInline: true,
          showVideoAnnotations: false,
          strictRelatedVideos: true,
        ),
      ),
    );
  }

  @override
  StreamSubscription<YoutubePlayerValue> listen(
    void Function(YoutubePlayerValue value) onData,
  ) {
    return player.listen(onData);
  }

  @override
  Future<void> play() => player.playVideo();

  @override
  Future<void> close() => player.close();

  @override
  Widget buildPlayer({
    required BuildContext context,
    required double aspectRatio,
    required Color backgroundColor,
    required Widget Function(BuildContext context, bool isFullscreen) controls,
  }) {
    return YoutubePlayer(
      controller: player,
      aspectRatio: aspectRatio,
      autoFullScreen: false,
      enableFullScreenOnVerticalDrag: false,
      gestureRecognizers: const {},
      backgroundColor: backgroundColor,
      controlsBuilder: controls,
    );
  }
}
