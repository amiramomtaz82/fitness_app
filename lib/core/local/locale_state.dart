import 'package:equatable/equatable.dart';

import '../contants/app_language.dart';

class LocaleState extends Equatable {
  final AppLanguage language;

  const LocaleState({this.language = AppLanguage.english});

  bool get isLanguageSwitchOn => language == AppLanguage.english;

  LocaleState withLanguage(AppLanguage language) {
    return LocaleState(language: language);
  }

  @override
  List<Object?> get props => [language];
}
