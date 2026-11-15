import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/exercise_video_tile.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/exercise_chevron.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  setUpAll(loadTestTranslations);

  Future<void> pumpTile(WidgetTester tester, VoidCallback onTap) {
    return tester.pumpWidget(
      makeTestableComponent(
        ExerciseVideoTile(
          labelKey: LocaleKeys.exercises_video_explanation,
          onTap: onTap,
        ),
      ),
    );
  }

  group('ExerciseVideoTile', () {
    testWidgets('shows the localized label with a play marker', (tester) async {
      await pumpTile(tester, () {});

      expect(
        find.text(LocaleKeys.exercises_video_explanation.tr()),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.play_circle_outline_rounded), findsOneWidget);
      expect(find.byType(ExerciseChevron), findsOneWidget);
    });

    testWidgets('paints the play marker in the accent color at the tile size', (
      tester,
    ) async {
      await pumpTile(tester, () {});

      final context = tester.element(find.byType(ExerciseVideoTile));
      final icon = tester.widget<Icon>(
        find.byIcon(Icons.play_circle_outline_rounded),
      );
      final label = tester.widget<Text>(
        find.text(LocaleKeys.exercises_video_explanation.tr()),
      );

      expect(icon.size, 24.r);
      expect(icon.color, context.colors.secondary);
      expect(label.style, AppTextStyles.white14regular);
    });

    testWidgets('reports the tap once per touch', (tester) async {
      var taps = 0;

      await pumpTile(tester, () => taps++);
      await tester.tap(find.byType(ExerciseVideoTile));
      await tester.pump();

      expect(taps, 1);
    });
  });
}
