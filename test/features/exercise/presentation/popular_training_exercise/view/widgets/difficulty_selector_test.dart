import 'package:fitness_app/core/widgets/app_catgory_tab_bar.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/difficulty_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  Widget buildSubject({
    required List<String> levels,
    required String selected,
    required ValueChanged<String> onChanged,
  }) {
    return makeTestableComponent(
      DifficultySelector(
        levels: levels,
        selected: selected,
        onChanged: onChanged,
      ),
    );
  }

  group('DifficultySelector —', () {
    testWidgets('renders a tab for every level', (tester) async {
      await tester.pumpWidget(
        buildSubject(
          levels: const ['Easy', 'Hard'],
          selected: 'Easy',
          onChanged: (_) {},
        ),
      );

      expect(find.byType(AppCategoryTabBar), findsOneWidget);
      expect(find.text('Easy'), findsOneWidget);
      expect(find.text('Hard'), findsOneWidget);
    });

    testWidgets('emits the tapped level through onChanged', (tester) async {
      final selected = <String>[];
      await tester.pumpWidget(
        buildSubject(
          levels: const ['Easy', 'Hard'],
          selected: 'Easy',
          onChanged: selected.add,
        ),
      );

      await tester.tap(find.text('Hard'));
      await tester.pump();

      expect(selected, ['Hard']);
    });
  });
}
