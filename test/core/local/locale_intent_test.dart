import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/core/contants/app_language.dart';
import 'package:fitness_app/core/local/locale_intent.dart';

void main() {
  group('LocaleIntent', () {
    test('loading the saved locale is its own intent', () {
      const intent = LoadSavedLocaleIntent();

      expect(intent, isA<LocaleIntent>());
    });

    test('toggling the language is its own intent', () {
      const intent = ToggleLanguageIntent();

      expect(intent, isA<LocaleIntent>());
    });

    test('a change carries the language to move to', () {
      const intent = ChangeLocaleIntent(AppLanguage.arabic);

      expect(intent, isA<LocaleIntent>());
      expect(intent.language, AppLanguage.arabic);
    });
  });
}
