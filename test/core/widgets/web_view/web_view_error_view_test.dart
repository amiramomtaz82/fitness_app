import 'package:fitness_app/core/widgets/web_view/web_view_error_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../helpers/test_app.dart';

void main() {
  Future<void> pumpError(WidgetTester tester, {required VoidCallback onRetry}) {
    return pumpLocalizedWidget(tester, WebViewErrorView(onRetry: onRetry));
  }

  testWidgets('shows a message and a retry action', (tester) async {
    await pumpError(tester, onRetry: () {});

    expect(find.byType(FilledButton), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(FilledButton),
        matching: find.byType(Text),
      ),
      findsOneWidget,
    );
    expect(find.byType(Text), findsNWidgets(2));
  });

  testWidgets('tapping retry runs the callback it was handed', (tester) async {
    var retries = 0;
    await pumpError(tester, onRetry: () => retries++);

    await tester.tap(find.byType(FilledButton));
    await settleUi(tester);

    expect(retries, 1);
  });
}
