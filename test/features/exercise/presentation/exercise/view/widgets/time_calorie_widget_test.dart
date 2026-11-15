import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/features/exercise/presentation/exercise/view/widgets/time_calorie_widget.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';
import '../../../../../../helpers/test_localization.dart';

void main() {
  setUpAll(loadTestLocalization);

  group('TimeCalorieWidget —', () {
    testWidgets('uses the default time and calories', (tester) async {
      await tester.pumpWidget(makeTestableComponent(const TimeCalorieWidget()));

      expect(find.text(LocaleKeys.exercises_min_30.tr()), findsOneWidget);
      expect(
        find.text('130 ${LocaleKeys.exercises_cal.tr()}', findRichText: true),
        findsOneWidget,
      );
    });

    testWidgets('renders custom time and calories', (tester) async {
      await tester.pumpWidget(
        makeTestableComponent(
          const TimeCalorieWidget(time: '45 MIN', calories: '320'),
        ),
      );

      expect(find.text('45 MIN'), findsOneWidget);
      expect(
        find.text('320 ${LocaleKeys.exercises_cal.tr()}', findRichText: true),
        findsOneWidget,
      );
    });
  });
}
