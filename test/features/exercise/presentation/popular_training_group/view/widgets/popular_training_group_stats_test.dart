import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view/widgets/group_stat_chip.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view/widgets/popular_training_group_stats.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  setUpAll(loadTestTranslations);

  Future<void> pumpStats(WidgetTester tester) {
    return tester.pumpWidget(
      makeTestableComponent(
        const PopularTrainingGroupStats(
          exercisesCount: 3,
          levelName: 'Beginner',
          muscleName: 'Chest',
        ),
      ),
    );
  }

  group('PopularTrainingGroupStats', () {
    testWidgets('shows the section title', (tester) async {
      await pumpStats(tester);

      expect(find.text(LocaleKeys.exercises_group_info.tr()), findsOneWidget);
    });

    testWidgets('shows one chip per statistic', (tester) async {
      await pumpStats(tester);

      expect(find.byType(GroupStatChip), findsNWidgets(3));
    });

    testWidgets('writes the exercise count into the count chip', (
      tester,
    ) async {
      await pumpStats(tester);

      expect(
        find.text(LocaleKeys.exercises_exercises_count.tr(args: const ['3'])),
        findsOneWidget,
      );
    });

    testWidgets('labels the level and the muscle chips', (tester) async {
      await pumpStats(tester);

      expect(
        find.text(
          LocaleKeys.exercises_labeled_value.tr(
            args: [LocaleKeys.exercises_level.tr(), 'Beginner'],
          ),
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          LocaleKeys.exercises_labeled_value.tr(
            args: [LocaleKeys.exercises_muscle.tr(), 'Chest'],
          ),
        ),
        findsOneWidget,
      );
    });
  });
}
