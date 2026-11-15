import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/core/contants/app_language.dart';
import 'package:fitness_app/core/local/locale_state.dart';

void main() {
  const initial = LocaleState();

  group('LocaleState', () {
    test('starts on english with the switch reading on', () {
      expect(initial.language, AppLanguage.english);
      expect(initial.isLanguageSwitchOn, isTrue);
    });

    test('is built from the language it is handed', () {
      const arabic = LocaleState(language: AppLanguage.arabic);

      expect(arabic.language, AppLanguage.arabic);
      expect(arabic.isLanguageSwitchOn, isFalse);
    });

    test('withLanguage swaps only the language', () {
      final arabic = initial.withLanguage(AppLanguage.arabic);

      expect(arabic.language, AppLanguage.arabic);
      expect(arabic.isLanguageSwitchOn, isFalse);
    });

    test('the switch reads on only while english is active', () {
      expect(initial.isLanguageSwitchOn, isTrue);
      expect(
        initial.withLanguage(AppLanguage.arabic).isLanguageSwitchOn,
        isFalse,
      );
    });

    test('is value equal to an identical state', () {
      const a = LocaleState();
      const b = LocaleState();

      expect(a, b);
      expect(a, isNot(a.withLanguage(AppLanguage.arabic)));
      expect(a.props, [a.language]);
    });
  });
}
