import 'package:fitness_app/core/theme/custom_colors.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view/models/picker_option.dart';
import 'package:fitness_app/features/profile/presentation/edit_profile/view/widgets/option_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  const options = [
    PickerOption(label: 'Rookie', value: 'level1'),
    PickerOption(label: 'Beginner', value: 'level2'),
    PickerOption(label: 'Intermediate', value: 'level3'),
  ];
  final selected = <PickerOption>[];

  Future<void> pumpSheet(WidgetTester tester, {required String selectedValue}) {
    return pumpLocalizedWidget(
      tester,
      OptionPickerSheet(
        options: options,
        selectedValue: selectedValue,
        onSelected: selected.add,
      ),
    );
  }

  Color labelColor(WidgetTester tester, String label) {
    return tester.widget<Text>(find.text(label)).style!.color!;
  }

  setUp(() => selected.clear());

  testWidgets('lists every choice the field accepts', (tester) async {
    await pumpSheet(tester, selectedValue: 'level1');

    for (final option in options) {
      expect(find.text(option.label), findsOneWidget);
    }
    expect(find.byType(InkWell), findsNWidgets(options.length));
  });

  testWidgets('marks the choice the user is on', (tester) async {
    await pumpSheet(tester, selectedValue: 'level2');

    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(labelColor(tester, 'Beginner'), CustomColors.dark.primary);
  });

  testWidgets('leaves the other choices unmarked', (tester) async {
    await pumpSheet(tester, selectedValue: 'level2');

    expect(labelColor(tester, 'Rookie'), CustomColors.dark.white);
    expect(labelColor(tester, 'Intermediate'), CustomColors.dark.white);
  });

  testWidgets('marks nothing when the saved value is not a choice', (
    tester,
  ) async {
    await pumpSheet(tester, selectedValue: 'level9');

    expect(find.byIcon(Icons.check), findsNothing);
  });

  testWidgets('a tap reports the choice the user picked', (tester) async {
    await pumpSheet(tester, selectedValue: 'level1');

    await tester.tap(find.text('Intermediate'));
    await settleUi(tester);

    expect(selected, [options.last]);
  });

  testWidgets('picking the current choice is still reported', (tester) async {
    await pumpSheet(tester, selectedValue: 'level1');

    await tester.tap(find.text('Rookie'));
    await settleUi(tester);

    expect(selected, [options.first]);
  });
}
