import 'package:fitness_app/features/profile/presentation/edit_profile/view/widgets/number_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  final submitted = <num>[];

  Future<void> pumpSheet(
    WidgetTester tester, {
    required num initialValue,
    int min = 10,
    int max = 100,
    String unit = 'years',
  }) {
    return pumpLocalizedWidget(
      tester,
      NumberPickerSheet(
        initialValue: initialValue,
        unit: unit,
        min: min,
        max: max,
        onSubmit: submitted.add,
      ),
    );
  }

  PageController wheelController(WidgetTester tester) {
    return tester.widget<PageView>(find.byType(PageView)).controller!;
  }

  Future<void> scrollTo(WidgetTester tester, int value, {int min = 10}) async {
    wheelController(tester).jumpToPage(value - min);
    await settleUi(tester);
  }

  Future<void> tapDone(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(FilledButton, 'Done'));
    await settleUi(tester);
  }

  setUp(() => submitted.clear());

  testWidgets('opens on the value the user is editing and shows its unit', (
    tester,
  ) async {
    await pumpSheet(tester, initialValue: 25);

    expect(find.text('years'), findsOneWidget);
    expect(find.text('25'), findsOneWidget);
    expect(wheelController(tester).page!.round(), 15);
  });

  testWidgets('Done submits the number sitting in the wheel', (tester) async {
    await pumpSheet(tester, initialValue: 25);

    await tapDone(tester);

    expect(submitted, [25]);
  });

  testWidgets('a scroll moves the selection before it is submitted', (
    tester,
  ) async {
    await pumpSheet(tester, initialValue: 25);

    await scrollTo(tester, 30);
    await tapDone(tester);

    expect(submitted, [30]);
  });

  testWidgets('a value below the range lands on the minimum', (tester) async {
    await pumpSheet(tester, initialValue: 5);

    await tapDone(tester);

    expect(submitted, [10]);
  });

  testWidgets('a value above the range lands on the maximum', (tester) async {
    await pumpSheet(tester, initialValue: 500);

    await tapDone(tester);

    expect(submitted, [100]);
  });

  testWidgets('the wheel is bounded to the range the field declares', (
    tester,
  ) async {
    await pumpSheet(tester, initialValue: 70, min: 30, max: 40);

    await scrollTo(tester, 30, min: 30);
    expect(find.text('30'), findsOneWidget);
    await scrollTo(tester, 40, min: 30);
    await tapDone(tester);

    expect(submitted, [40]);
  });
}
