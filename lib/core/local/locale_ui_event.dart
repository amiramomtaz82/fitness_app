import 'dart:ui';

import '../base/ui_events.dart';
import '../contants/app_language.dart';

class LocaleChangedEvent extends BaseUiEvent {
  final AppLanguage language;

  const LocaleChangedEvent(this.language);

  Locale get locale => Locale(language.code);
}
