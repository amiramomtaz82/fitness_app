import '../contants/app_language.dart';

sealed class LocaleIntent {
  const LocaleIntent();
}

final class LoadSavedLocaleIntent extends LocaleIntent {
  const LoadSavedLocaleIntent();
}

final class ToggleLanguageIntent extends LocaleIntent {
  const ToggleLanguageIntent();
}

final class ChangeLocaleIntent extends LocaleIntent {
  final AppLanguage language;

  const ChangeLocaleIntent(this.language);
}
