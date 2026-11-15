import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/exercise_play_button.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/exercise_summary_card.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/exercise_item_card.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/translucent_card_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';
import '../../../presentation_fixtures.dart';

void main() {
  Future<void> pumpCard(
    WidgetTester tester, {
    String? equipment = 'Barbell',
    String? videoId = kYoutubeId,
    VoidCallback? onPlay,
  }) {
    return tester.pumpWidget(
      makeTestableComponent(
        ExerciseSummaryCard(
          name: 'Bench Press',
          equipment: equipment,
          videoId: videoId,
          onPlay: onPlay,
        ),
      ),
    );
  }

  group('ExerciseSummaryCard', () {
    testWidgets('wraps a single card in the shared translucent list', (
      tester,
    ) async {
      await pumpCard(tester);

      expect(find.byType(TranslucentCardList), findsOneWidget);
      expect(find.byType(ExerciseItemCard), findsOneWidget);
    });

    testWidgets('writes the exercise data into the card', (tester) async {
      await pumpCard(tester);

      final card = tester.widget<ExerciseItemCard>(
        find.byType(ExerciseItemCard),
      );

      expect(card.name, 'Bench Press');
      expect(card.subtitle, 'Barbell');
      expect(card.videoId, kYoutubeId);
      expect(find.byType(ExercisePlayButton), findsOneWidget);
    });

    testWidgets('leaves the card without a subtitle when equipment is absent', (
      tester,
    ) async {
      await pumpCard(tester, equipment: null);

      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Barbell'), findsNothing);
    });

    testWidgets('forwards the play tap', (tester) async {
      var plays = 0;

      await pumpCard(tester, onPlay: () => plays++);
      await tester.tap(find.byType(ExercisePlayButton));
      await tester.pump();

      expect(plays, 1);
    });

    testWidgets(
      'leaves the button idle and the thumbnail empty when nothing is playable',
      (tester) async {
        await pumpCard(tester, videoId: null);

        final button = tester.widget<ExercisePlayButton>(
          find.byType(ExercisePlayButton),
        );

        expect(button.onTap, isNull);
        expect(
          tester
              .widget<ExerciseItemCard>(find.byType(ExerciseItemCard))
              .videoId,
          isNull,
        );
      },
    );
  });
}
