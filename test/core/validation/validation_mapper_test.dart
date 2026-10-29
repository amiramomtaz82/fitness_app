import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/validation/validation_errors.dart';
import 'package:fitness_app/core/validation/validation_mapper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<Map<ValidationError, String>> loadMessages(WidgetTester tester) async {
    await tester.runAsync(() async {
      await tester.pumpWidget(
        EasyLocalization(
          supportedLocales: const [Locale('en'), Locale('ar')],
          path: 'assets/translations',
          fallbackLocale: const Locale('en'),
          startLocale: const Locale('en'),
          saveLocale: false,
          child: Builder(
            builder: (context) => MaterialApp(
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: const Scaffold(body: SizedBox.shrink()),
            ),
          ),
        ),
      );
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }
    });
    return {
      for (final error in ValidationError.values) error: error.toMessage(),
    };
  }

  testWidgets('each validation error maps to its localized message', (
    tester,
  ) async {
    final messages = await loadMessages(tester);

    expect(messages[ValidationError.empty], 'This field is required.');
    expect(
      messages[ValidationError.invalidEmail],
      'Please enter a valid email address.',
    );
    expect(
      messages[ValidationError.passwordTooShort],
      'Password must be at least 8 characters.',
    );
    expect(
      messages[ValidationError.passwordMissingNumber],
      'Password must contain at least one digit.',
    );
    expect(
      messages[ValidationError.passwordsDoNotMatch],
      'Passwords do not match.',
    );
    expect(
      messages[ValidationError.incompleteOtp],
      'Please enter the complete verification code.',
    );
    expect(
      messages[ValidationError.notANumber],
      'Please enter a valid numeric value.',
    );
    expect(
      messages[ValidationError.valueBelowMinimum],
      'Entered value is too low.',
    );
    expect(
      messages[ValidationError.valueAboveMaximum],
      'Entered value exceeds maximum limit.',
    );
  });

  testWidgets('every error kind resolves to a real translated sentence', (
    tester,
  ) async {
    final messages = await loadMessages(tester);

    for (final entry in messages.entries) {
      expect(entry.value, isNotEmpty, reason: '${entry.key.name} is blank');
      expect(
        entry.value,
        isNot(startsWith('validation.')),
        reason: '${entry.key.name} fell back to the raw locale key',
      );
    }
  });
}
