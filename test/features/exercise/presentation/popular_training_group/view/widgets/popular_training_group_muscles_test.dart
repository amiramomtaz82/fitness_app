import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view/widgets/group_stat_chip.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view/widgets/popular_training_group_muscles.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  setUpAll(loadTestTranslations);

  Future<void> pumpMuscles(WidgetTester tester, List<String> muscleNames) {
    return tester.pumpWidget(
      makeTestableComponent(
        PopularTrainingGroupMuscles(muscleNames: muscleNames),
      ),
    );
  }

  group('PopularTrainingGroupMuscles', () {
    testWidgets('renders nothing when no muscle is related', (tester) async {
      await pumpMuscles(tester, const []);

      expect(
        find.text(LocaleKeys.exercises_related_muscles.tr()),
        findsNothing,
      );
      expect(find.byType(GroupStatChip), findsNothing);
    });

    testWidgets('shows the section title when there are muscles', (
      tester,
    ) async {
      await pumpMuscles(tester, const ['Chest']);

      expect(
        find.text(LocaleKeys.exercises_related_muscles.tr()),
        findsOneWidget,
      );
    });

    testWidgets('shows one chip per muscle in the given order', (tester) async {
      await pumpMuscles(tester, const ['Chest', 'Triceps Brachii']);

      expect(find.byType(GroupStatChip), findsNWidgets(2));
      expect(find.text('Chest'), findsOneWidget);
      expect(find.text('Triceps Brachii'), findsOneWidget);
    });
  });
}
