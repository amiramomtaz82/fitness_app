import 'package:fitness_app/app/routes_names.dart';
import 'package:fitness_app/core/widgets/app_youtube_video.dart';
import 'package:fitness_app/core/youtube/youtube_player_overlay.dart';
import 'package:fitness_app/core/youtube/youtube_video_thumbnail.dart';
import 'package:fitness_app/features/exercise/presentation/exercise_video/view/exercise_video_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import '../../../../../helpers/test_app.dart';
import '../../presentation_fixtures.dart';

void main() {
  Future<void> pumpVideo(WidgetTester tester, String videoUrl) async {
    usePhoneScreenSize(tester);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, settings) =>
              const Scaffold(body: Text('previous screen')),
        ),
        GoRoute(
          path: AppRoutes.exerciseVideo,
          builder: (context, settings) =>
              ExerciseVideoView(videoUrl: settings.extra! as String),
        ),
      ],
    );

    await tester.pumpWidget(makeTestableRouterWidget(router));
    router.push(AppRoutes.exerciseVideo, extra: videoUrl);
    await tester.pumpAndSettle();
  }

  group('ExerciseVideoView', () {
    testWidgets('hands the given url to the in-app player', (tester) async {
      await pumpVideo(tester, kYoutubeUrl);

      final video = tester.widget<AppYoutubeVideo>(
        find.byType(AppYoutubeVideo),
      );

      expect(video.videoUrl, kYoutubeUrl);
      expect(video.showBackButton, isTrue);
    });

    testWidgets('opens on the video picture with a way back', (tester) async {
      await pumpVideo(tester, kYoutubeUrl);

      expect(find.byType(ThumbnailSurface), findsOneWidget);
      expect(find.byType(BackOverlay), findsOneWidget);
      expect(find.byType(UnavailableSurface), findsNothing);
    });

    testWidgets('shows the unavailable surface for a link it cannot play', (
      tester,
    ) async {
      await pumpVideo(tester, 'https://example.com/video');

      expect(find.byType(UnavailableSurface), findsOneWidget);
      expect(find.byType(ThumbnailSurface), findsNothing);
    });

    testWidgets('returns to the previous screen from the back control', (
      tester,
    ) async {
      await pumpVideo(tester, kYoutubeUrl);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new));
      await tester.pumpAndSettle();

      expect(find.text('previous screen'), findsOneWidget);
      expect(find.byType(AppYoutubeVideo), findsNothing);
    });
  });
}
