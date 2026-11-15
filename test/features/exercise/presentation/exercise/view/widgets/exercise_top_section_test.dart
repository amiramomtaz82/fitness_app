import 'package:fitness_app/features/exercise/domain/entities/difficulty_entity.dart';
import 'package:fitness_app/features/exercise/presentation/exercise/view/widgets/exercise_top_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';
import '../../../../../../helpers/test_localization.dart';

const _levels = [
  DifficultyLevelEntity(id: 'level-1', name: 'Beginner'),
  DifficultyLevelEntity(id: 'level-2', name: 'Intermediate'),
];

void main() {
  setUpAll(loadTestLocalization);

  Widget build({
    String? videoId = 'dQw4w9WgXcQ',
    String muscleName = 'Chest',
    String? title,
    String? description,
    String? timeText = '30 MIN',
    String? caloriesText = '130',
    List<DifficultyLevelEntity> difficultyLevels = _levels,
    String? selectedDifficultyId = 'level-1',
    ValueChanged<int>? onCategorySelected,
    VoidCallback? onBack,
    VoidCallback? onPlayVideo,
  }) {
    return makeTestableWidget(
      Scaffold(
        body: ExerciseTopSection(
          videoId: videoId,
          muscleName: muscleName,
          title: title,
          description: description,
          timeText: timeText,
          caloriesText: caloriesText,
          difficultyLevels: difficultyLevels,
          selectedDifficultyId: selectedDifficultyId,
          onCategorySelected: onCategorySelected ?? (_) {},
          onBack: onBack ?? () {},
          onPlayVideo: onPlayVideo,
        ),
      ),
    );
  }

  group('ExerciseTopSection —', () {
    testWidgets('renders the hero title, description and stats', (
      tester,
    ) async {
      await tester.pumpWidget(
        build(description: 'Barbell • Pectoralis Major • Beginner'),
      );

      expect(find.text('Chest Exercise'), findsOneWidget);
      expect(
        find.text('Barbell • Pectoralis Major • Beginner'),
        findsOneWidget,
      );
      expect(find.text('30 MIN'), findsOneWidget);
      expect(find.text('130 Cal', findRichText: true), findsOneWidget);
      expect(find.text('Beginner'), findsOneWidget);
      expect(find.text('Intermediate'), findsOneWidget);
    });

    testWidgets('uses the provided title and description', (tester) async {
      await tester.pumpWidget(
        build(title: 'Custom Title', description: 'Custom Description'),
      );

      expect(find.text('Custom Title'), findsOneWidget);
      expect(find.text('Custom Description'), findsOneWidget);
      expect(find.text('Chest Exercise'), findsNothing);
    });

    testWidgets('falls back to the default title and description', (
      tester,
    ) async {
      await tester.pumpWidget(
        build(muscleName: '', title: null, description: null),
      );

      expect(find.text('Chest Exercise'), findsOneWidget);
      expect(
        find.text(
          'Lorem Ipsum Dolor Sit Amet Consectetur. Tempus Volutpat Ut Nisi Morbi.',
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows the default categories when no levels are provided', (
      tester,
    ) async {
      await tester.pumpWidget(build(difficultyLevels: const []));

      expect(find.text('Beginner'), findsOneWidget);
      expect(find.text('Intermediate'), findsOneWidget);
      expect(find.text('Advanced'), findsOneWidget);
    });

    testWidgets('reports the selected category index', (tester) async {
      int? selected;
      await tester.pumpWidget(
        build(onCategorySelected: (index) => selected = index),
      );

      await tester.tap(find.text('Intermediate'));
      await tester.pump();

      expect(selected, 1);
    });

    testWidgets('invokes onBack when the back button is tapped', (
      tester,
    ) async {
      var backs = 0;
      await tester.pumpWidget(build(onBack: () => backs++));

      await tester.tap(find.byKey(const Key('app_youtube_video_back')));
      await tester.pump();

      expect(backs, 1);
    });

    testWidgets('plays the video when the thumbnail is tapped', (tester) async {
      var plays = 0;
      await tester.pumpWidget(build(onPlayVideo: () => plays++));

      expect(find.byKey(const Key('app_youtube_video_play')), findsOneWidget);

      await tester.tap(find.byKey(const Key('app_youtube_video_play')));
      await tester.pump();

      expect(plays, 1);
    });

    testWidgets('shows the unavailable surface without a video', (
      tester,
    ) async {
      await tester.pumpWidget(build(videoId: null));

      expect(
        find.byKey(const Key('app_youtube_video_unavailable')),
        findsOneWidget,
      );
      expect(find.byKey(const Key('app_youtube_video_play')), findsNothing);
    });
  });
}
