import 'package:fitness_app/generated/locale_keys.g.dart';

enum AppLanguage {
  english('en', LocaleKeys.profile_select_language_english),
  arabic('ar', LocaleKeys.profile_select_language_arabic);

  const AppLanguage(this.code, this.titleKey);

  final String code;
  final String titleKey;

  static AppLanguage fromCode(String code) => values.firstWhere(
    (language) => language.code == code,
    orElse: () => AppLanguage.english,
  );
}
