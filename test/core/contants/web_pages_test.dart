import 'package:fitness_app/core/contants/web_pages.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WebPage', () {
    test('covers the three static pages the profile menu links to', () {
      expect(WebPage.values, [
        WebPage.security,
        WebPage.privacyPolicy,
        WebPage.help,
      ]);
    });

    test('titles the page from its own translation key', () {
      expect(WebPage.security.titleKey, LocaleKeys.profile_security);
      expect(WebPage.privacyPolicy.titleKey, LocaleKeys.profile_privacy_policy);
      expect(WebPage.help.titleKey, LocaleKeys.profile_help);
    });

    test('no two pages share a title', () {
      final titles = WebPage.values.map((page) => page.titleKey).toSet();
      expect(titles, hasLength(WebPage.values.length));
    });

    test('points at the published web view documents', () {
      expect(
        WebPage.security.url,
        'https://elevate-flutter-team.github.io/fitness-app-webviews/security.html',
      );
      expect(
        WebPage.privacyPolicy.url,
        'https://elevate-flutter-team.github.io/fitness-app-webviews/privacy-policy.html',
      );
      expect(
        WebPage.help.url,
        'https://elevate-flutter-team.github.io/fitness-app-webviews/help.html',
      );
    });

    test('every url is a reachable https uri', () {
      for (final page in WebPage.values) {
        final uri = Uri.parse(page.url);
        expect(uri.scheme, 'https');
        expect(uri.hasAuthority, isTrue);
        expect(uri.path, isNot('/'));
      }
    });
  });
}
