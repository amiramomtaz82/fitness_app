import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/theme/text_styles.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/exercise_details_row.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  setUpAll(loadTestTranslations);

  Future<void> pumpRow(WidgetTester tester, {String? value}) {
    return tester.pumpWidget(
      makeTestableComponent(
        ExerciseDetailsRow(labelKey: LocaleKeys.exercises_level, value: value),
      ),
    );
  }

  group('ExerciseDetailsRow', () {
    testWidgets('shows the localized label next to the given value', (
      tester,
    ) async {
      await pumpRow(tester, value: 'Beginner');

      expect(find.text(LocaleKeys.exercises_level.tr()), findsOneWidget);
      expect(find.text('Beginner'), findsOneWidget);
    });

    testWidgets('shows the fallback text when the value is absent', (
      tester,
    ) async {
      await pumpRow(tester);

      expect(
        find.text(LocaleKeys.exercises_not_available.tr()),
        findsOneWidget,
      );
    });

    testWidgets('keeps the value at the end in the shared styles', (
      tester,
    ) async {
      await pumpRow(tester, value: 'Beginner');

      final label = tester.widget<Text>(
        find.text(LocaleKeys.exercises_level.tr()),
      );
      final value = tester.widget<Text>(find.text('Beginner'));

      expect(label.style, AppTextStyles.grey12regular);
      expect(value.style, AppTextStyles.white14regular);
      expect(value.textAlign, TextAlign.end);
    });
  });
}
