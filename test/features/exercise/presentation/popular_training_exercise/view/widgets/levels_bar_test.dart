import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/difficulty_selector.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/levels_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  Widget buildSubject({
    required List<String> levels,
    required String selectedLevel,
    required ValueChanged<String> onLevelSelected,
  }) {
    return makeTestableComponent(
      LevelsBar(
        levels: levels,
        selectedLevel: selectedLevel,
        onLevelSelected: onLevelSelected,
      ),
    );
  }

  group('LevelsBar —', () {
    testWidgets('wraps a DifficultySelector with the given levels', (
      tester,
    ) async {
      await tester.pumpWidget(
        buildSubject(
          levels: const ['Easy', 'Hard'],
          selectedLevel: 'Easy',
          onLevelSelected: (_) {},
        ),
      );

      expect(find.byType(LevelsBar), findsOneWidget);
      expect(find.byType(DifficultySelector), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
    });

    testWidgets('forwards the selected level to onLevelSelected', (
      tester,
    ) async {
      final selected = <String>[];
      await tester.pumpWidget(
        buildSubject(
          levels: const ['Easy', 'Hard'],
          selectedLevel: 'Easy',
          onLevelSelected: selected.add,
        ),
      );

      await tester.tap(find.text('Hard'));
      await tester.pump();

      expect(selected, ['Hard']);
    });
  });
}
