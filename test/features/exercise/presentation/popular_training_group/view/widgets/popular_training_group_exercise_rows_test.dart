import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/model/group_exercise_item.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view/widgets/popular_training_group_exercise_rows.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/exercise_item_card.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/translucent_card_list.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';
import '../../../presentation_fixtures.dart';

void main() {
  setUpAll(loadTestTranslations);

  group('PopularTrainingGroupExerciseRows', () {
    testWidgets(
      'shows the empty message instead of a list when there is no exercise',
      (tester) async {
        await tester.pumpWidget(
          makeTestableComponent(
            PopularTrainingGroupExerciseRows(
              items: const [],
              onItemTap: (_) {},
            ),
          ),
        );

        expect(
          find.text(LocaleKeys.exercises_no_exercises_found.tr()),
          findsOneWidget,
        );
        expect(find.byType(TranslucentCardList), findsNothing);
        expect(find.byType(ExerciseItemCard), findsNothing);
      },
    );

    testWidgets('renders one card per exercise in the given order', (
      tester,
    ) async {
      await tester.pumpWidget(
        makeTestableComponent(
          PopularTrainingGroupExerciseRows(
            items: const [kExerciseItem, kExerciseItemWithoutVideo],
            onItemTap: (_) {},
          ),
        ),
      );

      expect(find.byType(ExerciseItemCard), findsNWidgets(2));
      expect(
        tester
            .widgetList<ExerciseItemCard>(find.byType(ExerciseItemCard))
            .map((card) => card.name),
        ['Bench Press', 'Squat'],
      );
    });

    testWidgets('writes each item values into its card', (tester) async {
      await tester.pumpWidget(
        makeTestableComponent(
          PopularTrainingGroupExerciseRows(
            items: const [kExerciseItem],
            onItemTap: (_) {},
          ),
        ),
      );

      final card = tester.widget<ExerciseItemCard>(
        find.byType(ExerciseItemCard),
      );

      expect(card.name, kExerciseItem.name);
      expect(card.subtitle, kExerciseItem.subtitle);
      expect(card.videoId, kExerciseItem.videoId);
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Barbell'), findsOneWidget);
    });

    testWidgets('reports the tapped item to the callback', (tester) async {
      final tapped = <GroupExerciseItem>[];

      await tester.pumpWidget(
        makeTestableComponent(
          PopularTrainingGroupExerciseRows(
            items: const [kExerciseItem, kExerciseItemWithoutVideo],
            onItemTap: tapped.add,
          ),
        ),
      );

      await tester.tap(find.text('Squat'));
      await tester.pump();

      expect(tapped, [kExerciseItemWithoutVideo]);
    });
  });
}
