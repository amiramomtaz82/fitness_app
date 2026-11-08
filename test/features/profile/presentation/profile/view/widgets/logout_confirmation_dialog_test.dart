import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/features/profile/presentation/profile/view/widgets/logout_confirmation_dialog.dart';

import '../../../../../../helpers/test_app.dart';

void main() {
  group('LogoutConfirmationDialog', () {
    testWidgets('renders all dialog elements properly', (tester) async {
      await pumpLocalizedWidget(
        tester,
        LogoutConfirmationDialog(onConfirm: () {}, onCancel: () {}),
      );
      await settleUi(tester);

      expect(find.byType(LogoutConfirmationDialog), findsOneWidget);
      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
      expect(find.byType(OutlinedButton), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('calls onCancel when cancel button is tapped', (tester) async {
      var cancelled = false;

      await pumpLocalizedWidget(
        tester,
        LogoutConfirmationDialog(
          onConfirm: () {},
          onCancel: () => cancelled = true,
        ),
      );
      await settleUi(tester);

      await tester.tap(find.byType(OutlinedButton));
      await settleUi(tester);

      expect(cancelled, isTrue);
    });

    testWidgets('calls onConfirm when confirm button is tapped', (
      tester,
    ) async {
      var confirmed = false;

      await pumpLocalizedWidget(
        tester,
        LogoutConfirmationDialog(
          onConfirm: () => confirmed = true,
          onCancel: () {},
        ),
      );
      await settleUi(tester);

      await tester.tap(find.byType(ElevatedButton));
      await settleUi(tester);

      expect(confirmed, isTrue);
    });

    testWidgets('action buttons meet minimum 48dp touch target requirement', (
      tester,
    ) async {
      await pumpLocalizedWidget(
        tester,
        LogoutConfirmationDialog(onConfirm: () {}, onCancel: () {}),
      );
      await settleUi(tester);

      final cancelSize = tester.getSize(find.byType(OutlinedButton));
      final confirmSize = tester.getSize(find.byType(ElevatedButton));

      expect(cancelSize.height, greaterThanOrEqualTo(48.0));
      expect(confirmSize.height, greaterThanOrEqualTo(48.0));
    });
  });
}
