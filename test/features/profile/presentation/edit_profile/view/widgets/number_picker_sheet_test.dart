import 'package:fitness_app/features/profile/presentation/edit_profile/view/widgets/number_picker_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  final submitted = <num>[];

  Future<void> pumpSheet(WidgetTester tester, {required String initialValue}) {
    return pumpLocalizedWidget(
      tester,
      NumberPickerSheet(
        initialValue: initialValue,
        unit: 'years',
        onSubmit: submitted.add,
      ),
    );
  }

  TextField numberField(WidgetTester tester) {
    return tester.widget<TextField>(find.byType(TextField));
  }

  FilledButton doneButton(WidgetTester tester) {
    return tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Done'),
    );
  }

  Future<void> typeValue(WidgetTester tester, String text) async {
    await tester.showKeyboard(find.byType(TextField));
    await tester.enterText(find.byType(TextField), text);
    await settleUi(tester);
  }

  setUp(() => submitted.clear());

  testWidgets('opens on the value the user is editing', (tester) async {
    await pumpSheet(tester, initialValue: '25');

    expect(numberField(tester).controller!.text, '25');
    expect(find.text('years'), findsOneWidget);
  });

  testWidgets('an empty value cannot be submitted', (tester) async {
    await pumpSheet(tester, initialValue: '');

    expect(doneButton(tester).onPressed, isNull);

    await tester.tap(find.text('Done'));
    await settleUi(tester);

    expect(submitted, isEmpty);
  });

  testWidgets('text that is not a number cannot be submitted', (tester) async {
    await pumpSheet(tester, initialValue: '25');
    await typeValue(tester, 'not a number');

    expect(doneButton(tester).onPressed, isNull);
    expect(submitted, isEmpty);
  });

  testWidgets('Done submits the number the user typed', (tester) async {
    await pumpSheet(tester, initialValue: '25');
    await typeValue(tester, '30');

    await tester.tap(find.text('Done'));
    await settleUi(tester);

    expect(submitted, [30]);
  });

  testWidgets('a decimal value reaches the form as it was written', (
    tester,
  ) async {
    await pumpSheet(tester, initialValue: '70');
    await typeValue(tester, '75.5');

    await tester.tap(find.text('Done'));
    await settleUi(tester);

    expect(submitted, [75.5]);
  });

  testWidgets('a comma is accepted as the decimal mark', (tester) async {
    await pumpSheet(tester, initialValue: '70');
    await typeValue(tester, '75,5');

    await tester.tap(find.text('Done'));
    await settleUi(tester);

    expect(submitted, [75.5]);
  });

  testWidgets('the keyboard return submits the same as the button', (
    tester,
  ) async {
    await pumpSheet(tester, initialValue: '25');
    await typeValue(tester, '80');

    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settleUi(tester);

    expect(submitted, [80]);
  });
}
