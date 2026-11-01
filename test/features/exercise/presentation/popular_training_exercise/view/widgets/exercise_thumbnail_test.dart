import 'package:fitness_app/core/youtube/youtube_video_thumbnail.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/exercise_thumbnail.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  Widget buildSubject({String? videoId}) {
    return makeTestableComponent(ExerciseThumbnail(videoId: videoId));
  }

  group('ExerciseThumbnail —', () {
    testWidgets('shows a transparent placeholder when videoId is null', (
      tester,
    ) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(ExerciseThumbnail), findsOneWidget);
      expect(find.byType(ThumbnailImage), findsNothing);
      expect(find.byType(ColoredBox), findsWidgets);
    });

    testWidgets('renders a network thumbnail for a video id', (tester) async {
      await tester.pumpWidget(buildSubject(videoId: 'dQw4w9WgXcQ'));

      expect(find.byType(ThumbnailImage), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });
  });
}
