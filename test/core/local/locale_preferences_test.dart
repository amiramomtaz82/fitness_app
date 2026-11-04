import 'package:fitness_app/core/contants/app_language.dart';
import 'package:fitness_app/core/local/locale_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<LocalePreferences> preferencesWith(Map<String, Object> values) async {
    SharedPreferences.setMockInitialValues(values);
    return LocalePreferences(await SharedPreferences.getInstance());
  }

  group('LocalePreferences', () {
    test('starts on english when nothing was stored', () async {
      final preferences = await preferencesWith({});

      expect(preferences.readLanguage(), AppLanguage.english);
    });

    test('reads back the language the user chose', () async {
      final preferences = await preferencesWith({
        'app_language_code': AppLanguage.arabic.code,
      });

      expect(preferences.readLanguage(), AppLanguage.arabic);
    });

    test('ignores a stored value the app does not support', () async {
      final preferences = await preferencesWith({'app_language_code': 'de'});

      expect(preferences.readLanguage(), AppLanguage.english);
    });

    test('survives a non string left by an older release', () async {
      final preferences = await preferencesWith({'app_language_code': 42});

      expect(preferences.readLanguage(), AppLanguage.english);
    });

    test('remembers the choice for the next start', () async {
      SharedPreferences.setMockInitialValues({});
      final store = await SharedPreferences.getInstance();
      final preferences = LocalePreferences(store);

      await preferences.saveLanguage(AppLanguage.arabic);

      expect(preferences.readLanguage(), AppLanguage.arabic);
      expect(store.getString('app_language_code'), AppLanguage.arabic.code);
    });

    test('overwrites the previous choice instead of stacking it', () async {
      SharedPreferences.setMockInitialValues({});
      final preferences = LocalePreferences(
        await SharedPreferences.getInstance(),
      );

      await preferences.saveLanguage(AppLanguage.arabic);
      await preferences.saveLanguage(AppLanguage.english);

      expect(preferences.readLanguage(), AppLanguage.english);
    });
  });
}
