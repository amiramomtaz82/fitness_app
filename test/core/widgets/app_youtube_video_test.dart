import 'package:fitness_app/core/widgets/app_youtube_video.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../helpers/test_app.dart';

const _watchUrl = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
const _shortsUrl = 'https://www.youtube.com/shorts/dQw4w9WgXcQ';
const _playKey = Key('app_youtube_video_play');
const _backKey = Key('app_youtube_video_back');
const _unavailableKey = Key('app_youtube_video_unavailable');

void main() {
  Widget video(
    String url, {
    bool showBackButton = false,
    VoidCallback? onBack,
    double aspectRatio = 16 / 9,
  }) {
    return makeTestableComponent(
      AppYoutubeVideo(
        videoUrl: url,
        showBackButton: showBackButton,
        onBack: onBack,
        aspectRatio: aspectRatio,
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
  });
}
