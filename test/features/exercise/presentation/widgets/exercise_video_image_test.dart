import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/youtube/youtube_video_thumbnail.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/exercise_video_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_app.dart';

void main() {
  group('ExerciseVideoImage', () {
    testWidgets(
      'fills the space with the video thumbnail when there is an id',
      (tester) async {
        await tester.pumpWidget(
          makeTestableComponent(
            const ExerciseVideoImage(videoId: 'dQw4w9WgXcQ'),
          ),
        );

        final thumbnail = tester.widget<ThumbnailImage>(
          find.byType(ThumbnailImage),
        );

        expect(thumbnail.videoId, 'dQw4w9WgXcQ');
      },
    );

    testWidgets('fills the space with the card color when there is no id', (
      tester,
    ) async {
      await tester.pumpWidget(
        makeTestableComponent(const ExerciseVideoImage(videoId: null)),
      );

      final context = tester.element(find.byType(ExerciseVideoImage));
      final box = tester.widget<ColoredBox>(
        find.descendant(
          of: find.byType(ExerciseVideoImage),
          matching: find.byType(ColoredBox),
        ),
      );

      expect(find.byType(ThumbnailImage), findsNothing);
      expect(box.color, context.colors.card);
    });
  });
}
