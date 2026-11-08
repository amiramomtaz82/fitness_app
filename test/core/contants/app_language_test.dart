import 'package:fitness_app/core/contants/app_language.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppLanguage', () {
    test('offers exactly english then arabic', () {
      expect(AppLanguage.values, [AppLanguage.english, AppLanguage.arabic]);
    });

    test('carries the locale code used to switch the app language', () {
      expect(AppLanguage.english.code, 'en');
      expect(AppLanguage.arabic.code, 'ar');
    });

    test('names every language row with its own translation key', () {
      expect(AppLanguage.english.titleKey, isNot(AppLanguage.arabic.titleKey));
      expect(AppLanguage.english.titleKey, isNotEmpty);
      expect(AppLanguage.arabic.titleKey, isNotEmpty);
    });

    test('title keys point at the language row of the profile menu', () {
      expect(
        AppLanguage.english.titleKey,
        LocaleKeys.profile_select_language_english,
      );
      expect(
        AppLanguage.arabic.titleKey,
        LocaleKeys.profile_select_language_arabic,
      );
    });

    group('fromCode', () {
      test('resolves a stored code back to its language', () {
        expect(AppLanguage.fromCode('en'), AppLanguage.english);
        expect(AppLanguage.fromCode('ar'), AppLanguage.arabic);
      });

      test('falls back to english for anything unsupported', () {
        expect(AppLanguage.fromCode('fr'), AppLanguage.english);
        expect(AppLanguage.fromCode(''), AppLanguage.english);
      });

      test('reads every supported code back to its own language', () {
        for (final language in AppLanguage.values) {
          expect(AppLanguage.fromCode(language.code), language);
        }
      });
    });
  });
}
