import 'package:fitness_app/features/auth/presentation/forget_password/view/widgets/resend_code_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../forget_password_widget_test_helpers.dart';

void main() {
  testWidgets('idle button shows the resend label and fires on tap', (
    tester,
  ) async {
    var taps = 0;
    await pumpBareWidget(
      tester,
      ResendCodeButton(
        isResending: false,
        secondsLeft: 0,
        onResend: () => taps++,
      ),
    );

    expect(find.text('Resend Code?'), findsOneWidget);

    await tester.tap(find.byType(TextButton));
    await tester.pump();

    expect(taps, 1);
  });

  testWidgets('a running countdown shows the remaining seconds', (
    tester,
  ) async {
    await pumpBareWidget(
      tester,
      ResendCodeButton(isResending: false, secondsLeft: 17, onResend: () {}),
    );

    expect(find.text('Resend in 17s'), findsOneWidget);
    expect(find.text('Resend Code?'), findsNothing);
  });

  testWidgets('tapping during the countdown does nothing', (tester) async {
    var taps = 0;
    await pumpBareWidget(
      tester,
      ResendCodeButton(
        isResending: false,
        secondsLeft: 17,
        onResend: () => taps++,
      ),
    );

    await tester.tap(find.byType(TextButton));
    await tester.pump();

    expect(taps, 0);
    expect(
      tester.widget<TextButton>(find.byType(TextButton)).onPressed,
      isNull,
    );
  });

  testWidgets('while resending the button turns into a spinner', (
    tester,
  ) async {
    await pumpBareWidget(
      tester,
      ResendCodeButton(isResending: true, secondsLeft: 0, onResend: () {}),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(TextButton), findsNothing);
  });

  testWidgets('the last second of the countdown is still blocked', (
    tester,
  ) async {
    var taps = 0;
    await pumpBareWidget(
      tester,
      ResendCodeButton(
        isResending: false,
        secondsLeft: 1,
        onResend: () => taps++,
      ),
    );

    await tester.tap(find.byType(TextButton));
    expect(taps, 0);

    await pumpBareWidget(
      tester,
      ResendCodeButton(
        isResending: false,
        secondsLeft: 0,
        onResend: () => taps++,
      ),
    );

    await tester.tap(find.byType(TextButton));
    await tester.pump();

    expect(taps, 1);
  });
}
