import 'package:fitness_app/generated/locale_keys.g.dart';

enum WebPage {
  security(
    LocaleKeys.profile_security,
    'https://elevate-flutter-team.github.io/fitness-app-webviews/security.html',
  ),
  privacyPolicy(
    LocaleKeys.profile_privacy_policy,
    'https://elevate-flutter-team.github.io/fitness-app-webviews/privacy-policy.html',
  ),
  help(
    LocaleKeys.profile_help,
    'https://elevate-flutter-team.github.io/fitness-app-webviews/help.html',
  );

  const WebPage(this.titleKey, this.url);

  final String titleKey;
  final String url;
}
