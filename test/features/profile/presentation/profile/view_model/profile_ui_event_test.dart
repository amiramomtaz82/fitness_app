import 'dart:ui';

import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/contants/app_language.dart';
import 'package:fitness_app/features/profile/presentation/profile/view_model/profile_ui_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProfileUiEvent', () {
    test('is a custom event the screens decide how to handle', () {
      const event = ProfileUiEvent(AppLanguage.arabic);

      expect(event, isA<BaseUiEvent>());
      expect(event, isNot(isA<CommonUiEvent>()));
    });

    test('carries the language the user switched to', () {
      const event = ProfileUiEvent(AppLanguage.arabic);

      expect(event.language, AppLanguage.arabic);
    });

    test('translates the language into the locale the app should apply', () {
      expect(
        const ProfileUiEvent(AppLanguage.arabic).locale,
        const Locale('ar'),
      );
      expect(
        const ProfileUiEvent(AppLanguage.english).locale,
        const Locale('en'),
      );
    });
  });
}
