import 'package:fitness_app/core/theme/context.extension.dart';
import 'package:fitness_app/features/exercise/presentation/widgets/exercise_chevron.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_app.dart';

void main() {
  group('ExerciseChevron', () {
    testWidgets('renders the grey chevron icon', (tester) async {
      await tester.pumpWidget(makeTestableComponent(const ExerciseChevron()));

      final context = tester.element(find.byType(ExerciseChevron));
      final icon = tester.widget<Icon>(
        find.byIcon(Icons.chevron_right_rounded),
      );

      expect(icon.color, context.colors.grey);
      expect(icon.size, 24.r);
    });
  });
}
