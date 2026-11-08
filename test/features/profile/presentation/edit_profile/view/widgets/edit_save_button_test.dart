import 'package:fitness_app/features/profile/presentation/edit_profile/view/widgets/edit_save_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  const buttonKey = Key('editSaveButton');

  Future<void> pumpButton(
    WidgetTester tester, {
    required VoidCallback onPressed,
    bool isLoading = false,
    bool enabled = true,
  }) {
    return pumpLocalizedWidget(
      tester,
      EditSaveButton(
        onPressed: onPressed,
        isLoading: isLoading,
        enabled: enabled,
      ),
    );
  }

  FilledButton saveButton(WidgetTester tester) {
    return tester.widget<FilledButton>(find.byKey(buttonKey));
  }

  testWidgets('offers the user a way to save the form', (tester) async {
    await pumpButton(tester, onPressed: () {});

    expect(find.text('Save'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNotNull);
  });

  testWidgets('a tap saves the form', (tester) async {
    var taps = 0;
    await pumpButton(tester, onPressed: () => taps++);

    await tester.tap(find.byKey(buttonKey));
    await settleUi(tester);

    expect(taps, 1);
  });

  testWidgets('spins while the save is running', (tester) async {
    await pumpButton(tester, onPressed: () {}, isLoading: true);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Save'), findsNothing);
  });

  testWidgets('a running save cannot be tapped again', (tester) async {
    var taps = 0;
    await pumpButton(tester, onPressed: () => taps++, isLoading: true);

    await tester.tap(find.byKey(buttonKey));
    await settleUi(tester);

    expect(taps, 0);
    expect(saveButton(tester).onPressed, isNull);
  });

  testWidgets('a button waits while nothing has changed', (tester) async {
    var taps = 0;
    await pumpButton(tester, onPressed: () => taps++, enabled: false);

    expect(find.text('Save'), findsOneWidget);
    expect(saveButton(tester).onPressed, isNull);

    await tester.tap(find.byKey(buttonKey));
    await settleUi(tester);

    expect(taps, 0);
  });
}
