import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_group/view/widgets/group_stat_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  group('GroupStatChip', () {
    testWidgets('shows the icon and the label', (tester) async {
      await tester.pumpWidget(
        makeTestableComponent(
          const GroupStatChip(icon: Icons.star, label: 'Level: Beginner'),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
      expect(find.text('Level: Beginner'), findsOneWidget);
    });

    testWidgets('paints the icon in the accent color at the chip size', (
      tester,
    ) async {
      await tester.pumpWidget(
        makeTestableComponent(
          const GroupStatChip(icon: Icons.star, label: 'Level: Beginner'),
        ),
      );

      final context = tester.element(find.byType(GroupStatChip));
      final icon = tester.widget<Icon>(find.byIcon(Icons.star));

      expect(icon.size, 14.r);
      expect(icon.color, context.colors.secondary);
    });

    testWidgets('draws a rounded bordered surface', (tester) async {
      await tester.pumpWidget(
        makeTestableComponent(
          const GroupStatChip(icon: Icons.star, label: 'Level: Beginner'),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(GroupStatChip),
          matching: find.byType(Container),
        ),
      );
      final decoration = container.decoration! as BoxDecoration;

      expect(decoration.borderRadius, BorderRadius.circular(20.r));
      expect(decoration.border!.bottom.color.a, closeTo(0.08, 0.004));
    });
  });
}
