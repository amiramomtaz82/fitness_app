import 'package:fitness_app/core/theme/custom_colors.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view/widgets/edit_tap_field.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  Future<void> pumpField(
    WidgetTester tester, {
    required String value,
    VoidCallback? onTap,
  }) {
    return pumpLocalizedWidget(
      tester,
      EditTapField(
        labelKey: LocaleKeys.profile_your_age_tap_to_edit,
        value: value,
        onTap: onTap ?? () {},
      ),
    );
  }

  Color valueColor(WidgetTester tester, String value) {
    return tester.widget<Text>(find.text(value)).style!.color!;
  }

  testWidgets('shows the translated label of the field it edits', (
    tester,
  ) async {
    await pumpField(tester, value: '25 years');

    expect(find.text('Your Age (Tap To Edit)'), findsOneWidget);
    expect(find.text('25 years'), findsOneWidget);
  });

  testWidgets('a tap asks the field to open its picker', (tester) async {
    var taps = 0;
    await pumpField(tester, value: '25 years', onTap: () => taps++);

    await tester.tap(find.byType(InkWell));
    await settleUi(tester);

    expect(taps, 1);
  });

  testWidgets('a value the user has not filled in looks empty', (tester) async {
    await pumpField(tester, value: '');

    expect(valueColor(tester, ''), CustomColors.dark.grey);
  });

  testWidgets('a filled value is readable', (tester) async {
    await pumpField(tester, value: '25 years');

    expect(valueColor(tester, '25 years'), CustomColors.dark.white);
  });
}
