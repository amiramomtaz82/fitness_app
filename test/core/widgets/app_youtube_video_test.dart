import 'dart:async';

import 'package:fitness_app/core/widgets/app_youtube_video.dart';
import 'package:fitness_app/core/youtube/youtube_video_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../helpers/test_app.dart';

const _watchUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
const _shortsUrl = 'https://www.youtube.com/shorts/dQw4w9WgXcQ';
const _playKey = Key('app_youtube_video_play');
const _backKey = Key('app_youtube_video_back');
const _unavailableKey = Key('app_youtube_video_unavailable');
const _playerKey = Key('app_youtube_video_player');
const _errorKey = Key('app_youtube_video_error');
const _retryKey = Key('app_youtube_video_retry');

void main() {
  Widget video(
    String url, {
    bool showBackButton = false,
    VoidCallback? onBack,
    double aspectRatio = 16 / 9,
    YoutubeVideoControllerFactory? createController,
  }) {
    return makeTestableComponent(
      AppYoutubeVideo(
        videoUrl: url,
        showBackButton: showBackButton,
        onBack: onBack,
        aspectRatio: aspectRatio,
        createController: createController,
      ),
    );
  }

  group('AppYoutubeVideo —', () {
    testWidgets('shows a thumbnail and play button for a supported URL', (
      tester,
    ) async {
      await tester.pumpWidget(video(_watchUrl));

      expect(find.byKey(_playKey), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
      expect(find.byKey(_unavailableKey), findsNothing);
      expect(find.byKey(_backKey), findsNothing);
      expect(
        tester.widget<AspectRatio>(find.byType(AspectRatio)).aspectRatio,
        16 / 9,
      );
    });

    testWidgets('uses the aspect ratio given by the parent', (tester) async {
      await tester.pumpWidget(video(_shortsUrl, aspectRatio: 4 / 3));

      expect(
        tester.widget<AspectRatio>(find.byType(AspectRatio)).aspectRatio,
        4 / 3,
      );
      expect(find.byKey(_playKey), findsOneWidget);
    });

    testWidgets('keeps an empty or malformed URL on a stable placeholder', (
      tester,
    ) async {
      await tester.pumpWidget(video(''));

      expect(find.byKey(_unavailableKey), findsOneWidget);
      expect(find.byKey(_playKey), findsNothing);
      expect(find.byType(Image), findsNothing);

      await tester.pumpWidget(video('https://example.com/watch?v=dQw4w9WgXcQ'));

      expect(find.byKey(_unavailableKey), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the back button and calls onBack', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        video('', showBackButton: true, onBack: () => taps++),
      );

      await tester.tap(find.byKey(_backKey));
      await tester.pump();

      expect(taps, 1);
      expect(find.byKey(_playKey), findsNothing);
    });

    testWidgets('a back tap does not start playback', (tester) async {
      await tester.pumpWidget(video(_watchUrl, showBackButton: true));

      await tester.tap(find.byKey(_backKey));
      await tester.pump();

      expect(find.byKey(_playKey), findsOneWidget);
      expect(find.byType(YoutubePlayer), findsNothing);
    });

    testWidgets('shows a play button for a raw video id', (tester) async {
      await tester.pumpWidget(video('dQw4w9WgXcQ'));

      expect(find.byKey(_playKey), findsOneWidget);
      expect(find.byKey(_unavailableKey), findsNothing);
    });

    testWidgets('accepts a null back callback', (tester) async {
      await tester.pumpWidget(video('', showBackButton: true));

      await tester.tap(find.byKey(_backKey));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('swaps the URL and disposes without throwing', (tester) async {
      await tester.pumpWidget(video(_watchUrl, showBackButton: true));
      expect(find.byKey(_playKey), findsOneWidget);

      await tester.pumpWidget(video(_shortsUrl));
      expect(find.byKey(_playKey), findsOneWidget);
      expect(find.byKey(_backKey), findsNothing);

      await tester.pumpWidget(video('not a video'));
      expect(find.byKey(_unavailableKey), findsOneWidget);
      expect(find.byKey(_playKey), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(tester.takeException(), isNull);
    });

    testWidgets('replaces the thumbnail with the player after Play', (
      tester,
    ) async {
      final created = <FakeYoutubeVideoController>[];
      await tester.pumpWidget(
        video(
          _watchUrl,
          createController: (videoId) => track(created, videoId),
        ),
      );

      await tester.tap(find.byKey(_playKey));
      await tester.pump();

      expect(created, hasLength(1));
      expect(created.single.videoId, 'dQw4w9WgXcQ');
      expect(find.byKey(_playerKey), findsOneWidget);
      expect(find.byKey(_playKey), findsNothing);
      expect(find.byType(YoutubePlayer), findsNothing);
    });

    testWidgets('shows the error state when the player cannot be created', (
      tester,
    ) async {
      await tester.pumpWidget(
        video(_watchUrl, createController: (_) => throw StateError('open')),
      );

      await tester.tap(find.byKey(_playKey));
      await tester.pump();

      expect(find.byKey(_errorKey), findsOneWidget);
      expect(find.byKey(_playerKey), findsNothing);
      expect(tester.takeException(), isNull);
    });

    testWidgets('shows the error state when playback fails after cue', (
      tester,
    ) async {
      final fake = FakeYoutubeVideoController('dQw4w9WgXcQ')..playError = true;
      await tester.pumpWidget(video(_watchUrl, createController: (_) => fake));

      await tester.tap(find.byKey(_playKey));
      await tester.pump();
      fake.emit(YoutubePlayerValue(playerState: PlayerState.cued));
      await tester.pump();
      await tester.pump();

      expect(fake.playCalls, 1);
      expect(find.byKey(_errorKey), findsOneWidget);
      expect(find.byKey(_playerKey), findsOneWidget);
      expect(find.byKey(_retryKey), findsNothing);
    });

    testWidgets('retries only from the retry button after a failed open', (
      tester,
    ) async {
      var opens = 0;
      await tester.pumpWidget(
        video(
          _watchUrl,
          createController: (_) {
            opens++;
            throw StateError('open');
          },
        ),
      );

      await tester.tap(find.byKey(_playKey));
      await tester.pump();

      expect(opens, 1);
      expect(find.byKey(_errorKey), findsOneWidget);
      expect(find.byKey(_playKey), findsNothing);
      expect(find.byKey(_retryKey), findsOneWidget);

      final errorTopLeft = tester.getRect(find.byKey(_errorKey)).topLeft;
      await tester.tapAt(errorTopLeft + const Offset(8, 8));
      await tester.pump();

      expect(opens, 1);

      await tester.tap(find.byKey(_retryKey));
      await tester.pump();

      expect(opens, 2);
      expect(tester.takeException(), isNull);
    });

    testWidgets('keeps the back button tappable after Play', (tester) async {
      var taps = 0;
      final fake = FakeYoutubeVideoController('dQw4w9WgXcQ');
      await tester.pumpWidget(
        video(
          _watchUrl,
          showBackButton: true,
          onBack: () => taps++,
          createController: (_) => fake,
        ),
      );

      await tester.tap(find.byKey(_playKey));
      await tester.pump();
      await pumpUntilFound(tester, find.byKey(_backKey));

      expect(find.byKey(_backKey), findsOneWidget);
      await tester.tap(find.byKey(_backKey));
      await tester.pump();
      expect(taps, 1);

      fake.emit(
        YoutubePlayerValue(
          fullScreenOption: const FullScreenOption(enabled: true),
        ),
      );
      await tester.pump();

      expect(find.byKey(_backKey), findsNothing);
    });

    testWidgets(
      'shows and clears the player error reported by the controller',
      (tester) async {
        final fake = FakeYoutubeVideoController('dQw4w9WgXcQ');
        await tester.pumpWidget(
          video(_watchUrl, createController: (_) => fake),
        );

        await tester.tap(find.byKey(_playKey));
        await tester.pump();
        fake.emit(YoutubePlayerValue(error: YoutubeError.notEmbeddable));
        await tester.pump();
        await tester.pump();

        expect(find.byKey(_errorKey), findsOneWidget);

        fake.emit(YoutubePlayerValue(playerState: PlayerState.playing));
        await tester.pump();
        await tester.pump();

        expect(find.byKey(_errorKey), findsNothing);
        expect(fake.playCalls, 0);
      },
    );

    testWidgets('closes the player when the URL changes and when disposed', (
      tester,
    ) async {
      final created = <FakeYoutubeVideoController>[];
      await tester.pumpWidget(
        video(
          _watchUrl,
          createController: (videoId) =>
              track(created, videoId)..closeError = true,
        ),
      );

      await tester.tap(find.byKey(_playKey));
      await tester.pump();

      await tester.pumpWidget(
        video(
          _shortsUrl,
          createController: (videoId) => track(created, videoId),
        ),
      );
      await tester.pump();

      expect(created.first.closed, isTrue);
      expect(find.byKey(_playKey), findsOneWidget);
      expect(find.byKey(_playerKey), findsNothing);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}

Future<void> pumpUntilFound(WidgetTester tester, Finder finder) async {
  for (var attempt = 0; attempt < 6; attempt++) {
    if (finder.evaluate().isNotEmpty) return;
    await tester.pump();
  }
}

FakeYoutubeVideoController track(
  List<FakeYoutubeVideoController> created,
  String videoId,
) {
  final controller = FakeYoutubeVideoController(videoId);
  created.add(controller);
  return controller;
}

class FakeYoutubeVideoController implements YoutubeVideoController {
  FakeYoutubeVideoController(this.videoId);

  final String videoId;
  final StreamController<YoutubePlayerValue> values =
      StreamController<YoutubePlayerValue>.broadcast();
  var closed = false;
  var closeError = false;
  var playCalls = 0;
  var playError = false;

  void emit(YoutubePlayerValue value) => values.add(value);

  @override
  StreamSubscription<YoutubePlayerValue> listen(
    void Function(YoutubePlayerValue value) onData,
  ) {
    return values.stream.listen(onData);
  }

  @override
  Future<void> play() async {
    playCalls++;
    if (playError) throw StateError('play');
  }

  @override
  Future<void> close() async {
    closed = true;
    await values.close();
    if (closeError) throw StateError('close');
  }

  @override
  Widget buildPlayer({
    required BuildContext context,
    required double aspectRatio,
    required Color backgroundColor,
    required Widget Function(BuildContext context, bool isFullscreen) controls,
  }) {
    return ColoredBox(color: backgroundColor, child: controls(context, false));
  }
}
