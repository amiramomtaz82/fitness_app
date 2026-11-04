import 'dart:ui';

import '../../../../../../core/base/ui_events.dart';
import '../../../../../../core/contants/app_language.dart';

class ProfileUiEvent extends BaseUiEvent {
  final AppLanguage language;

  const ProfileUiEvent(this.language);

  Locale get locale => Locale(language.code);
}
