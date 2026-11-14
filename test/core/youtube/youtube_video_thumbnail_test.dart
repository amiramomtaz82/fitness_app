import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/youtube/youtube_video_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';

import '../../helpers/test_app.dart';

const kVideoId = 'dQw4w9WgXcQ';

void main() {
  Future<void> pumpBounded(
    WidgetTester tester,
    Widget child, {
    double devicePixelRatio = 1.0,
  }) {
    tester.view.physicalSize = Size(
      375 * devicePixelRatio,
      812 * devicePixelRatio,
    );
    tester.view.devicePixelRatio = devicePixelRatio;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    return tester.pumpWidget(
      makeTestableComponent(
        Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: 320, height: 180, child: child),
        ),
      ),
    );
  }

  List<String> requestedUrls(WidgetTester tester) {
    return tester
        .widgetList<Image>(find.byType(Image))
        .map((image) => (image.image as ResizeImage).imageProvider)
        .cast<NetworkImage>()
        .map((provider) => provider.url)
        .toList();
  }

  group('ThumbnailSurface', () {
    testWidgets('shows only the picture when there is nothing to play', (
      tester,
    ) async {
      await pumpBounded(tester, const ThumbnailSurface(videoId: kVideoId));

      expect(find.byType(ThumbnailImage), findsOneWidget);
      expect(find.byType(PlayButton), findsNothing);
      expect(find.byType(GestureDetector), findsNothing);
    });

    testWidgets('offers a play control and reports the tap once', (
      tester,
    ) async {
      var plays = 0;

      await pumpBounded(
        tester,
        ThumbnailSurface(videoId: kVideoId, onPlay: () => plays++),
      );

      expect(find.byType(PlayButton), findsOneWidget);

      await tester.tap(find.byType(ThumbnailSurface));
      await tester.pump();

      expect(plays, 1);
    });
  });

  group('ThumbnailImage', () {
    testWidgets('asks for the sharpest picture that fits the box', (
      tester,
    ) async {
      await pumpBounded(tester, const ThumbnailImage(videoId: kVideoId));

      final image = tester.widget<Image>(find.byType(Image));
      final sized = image.image as ResizeImage;

      expect(
        (sized.imageProvider as NetworkImage).url,
        YoutubePlayerController.getThumbnail(
          videoId: kVideoId,
          quality: ThumbnailQuality.max,
        ),
      );
      expect(sized.width, 320);
      expect(sized.height, 180);
      expect(image.fit, BoxFit.cover);
      expect(image.gaplessPlayback, isTrue);
    });

    testWidgets('scales the cached picture with the device pixel ratio', (
      tester,
    ) async {
      await pumpBounded(
        tester,
        const ThumbnailImage(videoId: kVideoId),
        devicePixelRatio: 2.0,
      );

      final image = tester.widget<Image>(find.byType(Image));
      final sized = image.image as ResizeImage;

      expect(sized.width, 640);
      expect(sized.height, 360);
    });

    testWidgets('leaves the cache unsized when the box has no end', (
      tester,
    ) async {
      await tester.pumpWidget(
        makeTestableComponent(
          const SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              height: 180,
              child: ThumbnailImage(videoId: kVideoId),
            ),
          ),
        ),
      );

      final image = tester.widget<Image>(find.byType(Image));
      final sized = image.image as ResizeImage;

      expect(sized.width, isNull);
    });

    testWidgets(
      'ends on a plain surface in the theme color when nothing loads',
      (tester) async {
        await pumpBounded(tester, const ThumbnailImage(videoId: kVideoId));
        await tester.pumpAndSettle();
        await tester.pumpAndSettle();

        final context = tester.element(find.byType(ThumbnailImage));
        final surface = tester.widget<ColoredBox>(
          find.descendant(
            of: find.byType(ThumbnailImage),
            matching: find.byType(ColoredBox),
          ),
        );

        expect(surface.color, context.colors.surface);
      },
    );

    testWidgets(
      'degrades to the fallback quality when the sharpest picture fails',
      (tester) async {
        await pumpBounded(tester, const ThumbnailImage(videoId: kVideoId));
        await tester.pumpAndSettle();

        expect(requestedUrls(tester), [
          YoutubePlayerController.getThumbnail(
            videoId: kVideoId,
            quality: ThumbnailQuality.max,
          ),
          YoutubePlayerController.getThumbnail(
            videoId: kVideoId,
            quality: ThumbnailQuality.high,
          ),
        ]);
      },
    );
  });

  group('UnavailableSurface', () {
    testWidgets('paints a stable placeholder in the background color', (
      tester,
    ) async {
      await pumpBounded(tester, const UnavailableSurface());

      final context = tester.element(find.byType(UnavailableSurface));
      final surface = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(UnavailableSurface),
          matching: find.byType(ColoredBox),
        ),
      );

      expect(
        find.byKey(const Key('app_youtube_video_unavailable')),
        findsOneWidget,
      );
      expect(surface.color, context.colors.background);
    });
  });

  group('PlayButton', () {
    testWidgets('shows a round translucent play marker', (tester) async {
      await pumpBounded(tester, const PlayButton());

      final context = tester.element(find.byType(PlayButton));
      final button = tester.widget<DecoratedBox>(find.byType(DecoratedBox));
      final decoration = button.decoration as BoxDecoration;
      final icon = tester.widget<Icon>(find.byIcon(Icons.play_arrow_rounded));

      expect(find.byKey(const Key('app_youtube_video_play')), findsOneWidget);
      expect(decoration.shape, BoxShape.circle);
      expect(decoration.color!.a, closeTo(0.72, 0.004));
      expect(icon.color, context.colors.white);
      expect(icon.size, 36.r);
    });
  });
}
