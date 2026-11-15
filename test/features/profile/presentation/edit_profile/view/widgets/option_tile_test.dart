import 'package:fitness_app/core/theme/custom_colors.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view/widgets/option_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  Future<void> pumpTile(
    WidgetTester tester, {
    required bool selected,
    VoidCallback? onTap,
  }) {
    return pumpLocalizedWidget(
      tester,
      OptionTile(label: 'Beginner', selected: selected, onTap: onTap ?? () {}),
    );
  }

  Color labelColor(WidgetTester tester) {
    return tester.widget<Text>(find.text('Beginner')).style!.color!;
  }

  testWidgets('shows the label of the choice', (tester) async {
    await pumpTile(tester, selected: false);

    expect(find.text('Beginner'), findsOneWidget);
  });

  testWidgets('highlights the choice the user is on', (tester) async {
    await pumpTile(tester, selected: true);

    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(labelColor(tester), CustomColors.dark.primary);
  });

  testWidgets('leaves a choice the user is not on plain', (tester) async {
    await pumpTile(tester, selected: false);

    expect(find.byIcon(Icons.check), findsNothing);
    expect(labelColor(tester), CustomColors.dark.white);
  });

  testWidgets('a tap reports the choice back', (tester) async {
    var taps = 0;
    await pumpTile(tester, selected: false, onTap: () => taps++);

    await tester.tap(find.byType(InkWell));
    await settleUi(tester);

    expect(taps, 1);
  });
}
