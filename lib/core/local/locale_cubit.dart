import 'package:injectable/injectable.dart';

import '../base/base_cubit.dart';
import '../base/ui_events.dart';
import '../contants/app_language.dart';
import 'locale_intent.dart';
import 'locale_preferences.dart';
import 'locale_state.dart';
import 'locale_ui_event.dart';
import 'local_service.dart';

@lazySingleton
class LocaleCubit extends BaseCubit<LocaleState, BaseUiEvent> {
  final LocalePreferences _localePreferences;
  final LocaleService _localeService;

  LocaleCubit(this._localePreferences, this._localeService)
    : super(LocaleState(language: _localePreferences.readLanguage()));

  void doIntent(LocaleIntent intent) {
    switch (intent) {
      case LoadSavedLocaleIntent():
        _load();
      case ToggleLanguageIntent():
        _toggle();
      case ChangeLocaleIntent(:final language):
        _change(language);
    }
  }

  void _load() {
    final language = _localePreferences.readLanguage();
    _localeService.setLanguageCode(language.code);
    _emit(state.withLanguage(language));
    emitEvent(LocaleChangedEvent(language));
  }

  void _toggle() {
    _change(
      state.language == AppLanguage.english
          ? AppLanguage.arabic
          : AppLanguage.english,
    );
  }

  Future<void> _change(AppLanguage language) async {
    await _localePreferences.saveLanguage(language);
    _localeService.setLanguageCode(language.code);
    _emit(state.withLanguage(language));
    emitEvent(LocaleChangedEvent(language));
  }

  void _emit(LocaleState newState) {
    if (isClosed) return;
    emit(newState);
  }
}
