import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../contants/app_language.dart';

@lazySingleton
class LocalePreferences {
  static const _languageKey = 'app_language_code';

  final SharedPreferences _preferences;

  const LocalePreferences(this._preferences);

  AppLanguage readLanguage() {
    final saved = _preferences.get(_languageKey);
    return saved is String ? AppLanguage.fromCode(saved) : AppLanguage.english;
  }

  Future<void> saveLanguage(AppLanguage language) {
    return _preferences.setString(_languageKey, language.code);
  }
}
