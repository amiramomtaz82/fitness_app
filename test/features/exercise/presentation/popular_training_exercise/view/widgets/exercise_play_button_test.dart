import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/exercise_play_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  group('ExercisePlayButton', () {
    Future<void> pumpButton(WidgetTester tester, VoidCallback? onTap) {
      return tester.pumpWidget(
        makeTestableComponent(ExercisePlayButton(onTap: onTap)),
      );
    }

    testWidgets('shows a round accent button with a play marker', (
      tester,
    ) async {
      await pumpButton(tester, () {});

      final context = tester.element(find.byType(ExercisePlayButton));
      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration! as BoxDecoration;
      final icon = tester.widget<Icon>(find.byIcon(Icons.play_arrow_rounded));

      expect(decoration.shape, BoxShape.circle);
      expect(decoration.color, context.colors.primary);
      expect(tester.getSize(find.byType(Container)), Size(36.r, 36.r));
      expect(icon.color, context.colors.white);
      expect(icon.size, 22.sp);
    });

    testWidgets('stays fully visible while it can be tapped', (tester) async {
      await pumpButton(tester, () {});

      final opacity = tester.widget<Opacity>(find.byType(Opacity));

      expect(opacity.opacity, 1);
    });

    testWidgets('dims itself when there is nothing to play', (tester) async {
      await pumpButton(tester, null);

      final opacity = tester.widget<Opacity>(find.byType(Opacity));

      expect(opacity.opacity, 0.4);
    });

    testWidgets('reports the tap once per touch', (tester) async {
      var taps = 0;

      await pumpButton(tester, () => taps++);
      await tester.tap(find.byType(ExercisePlayButton));
      await tester.pump();

      expect(taps, 1);
    });

    testWidgets('swallows the tap when it is disabled', (tester) async {
      await pumpButton(tester, null);

      await tester.tap(find.byType(ExercisePlayButton));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
