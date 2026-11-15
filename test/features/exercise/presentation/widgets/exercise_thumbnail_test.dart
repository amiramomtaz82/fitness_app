import 'package:fitness_app/core/widgets/app_image_placeholder.dart';
import 'package:fitness_app/core/youtube/youtube_video_thumbnail.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/exercise_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_app.dart';

void main() {
  group('ExerciseThumbnail', () {
    testWidgets('shows the youtube thumbnail when there is a video id', (
      tester,
    ) async {
      await tester.pumpWidget(
        makeTestableComponent(const ExerciseThumbnail(videoId: 'dQw4w9WgXcQ')),
      );

      final thumbnail = tester.widget<ThumbnailImage>(
        find.byType(ThumbnailImage),
      );

      expect(thumbnail.videoId, 'dQw4w9WgXcQ');
    });

    testWidgets('shows an image placeholder when there is no video id', (
      tester,
    ) async {
      await tester.pumpWidget(
        makeTestableComponent(const ExerciseThumbnail(videoId: null)),
      );

      expect(find.byType(ThumbnailImage), findsNothing);
      expect(
        find.descendant(
          of: find.byType(ExerciseThumbnail),
          matching: find.byType(AppImagePlaceholder),
        ),
        findsOneWidget,
      );
    });

    testWidgets('rounds the corners and keeps the square size', (tester) async {
      await tester.pumpWidget(
        makeTestableComponent(const ExerciseThumbnail(videoId: null)),
      );

      final clip = tester.widget<ClipRRect>(find.byType(ClipRRect));

      expect(clip.borderRadius, BorderRadius.circular(12.r));
      expect(tester.getSize(find.byType(ExerciseThumbnail)), Size(64.w, 64.h));
    });
  });
}
