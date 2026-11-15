import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/contants/app_language.dart';
import 'package:fitness_app/core/local/locale_ui_event.dart';

void main() {
  group('LocaleChangedEvent', () {
    test('is a ui event the scope can react to', () {
      const event = LocaleChangedEvent(AppLanguage.english);

      expect(event, isA<BaseUiEvent>());
    });

    test('carries the language it was built from', () {
      const event = LocaleChangedEvent(AppLanguage.arabic);

      expect(event.language, AppLanguage.arabic);
    });

    test('reads the locale off the language code', () {
      expect(
        const LocaleChangedEvent(AppLanguage.english).locale,
        const Locale('en'),
      );
      expect(
        const LocaleChangedEvent(AppLanguage.arabic).locale,
        const Locale('ar'),
      );
    });
  });
}
