import 'dart:convert';
import 'dart:io';

// ignore: implementation_imports
import 'package:easy_localization/src/localization.dart';
// ignore: implementation_imports
import 'package:easy_localization/src/translations.dart';
import 'package:fitness_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

const kTestTranslationsPath = 'assets/translations';
const kTestTranslationsLocale = Locale('en');

/// Shared shell for widget tests.
///
/// MaterialApp is kept on purpose: screens need its Navigator,
/// ScaffoldMessenger, MaterialLocalizations and the app theme.
Widget makeTestableWidget(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, _) => MaterialApp(theme: AppTheme.darkTheme, home: child),
  );
}

/// Same as [makeTestableWidget] for small widgets that need a Material
/// ancestor (e.g. text fields) but no full screen.
Widget makeTestableComponent(Widget child) {
  return makeTestableWidget(Scaffold(body: child));
}

/// Runs [router] inside the same ScreenUtil and theme shell the app uses,
/// so screens can be pushed and popped in widget tests.
Widget makeTestableRouterWidget(GoRouter router) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, _) =>
        MaterialApp.router(theme: AppTheme.darkTheme, routerConfig: router),
  );
}

/// Fills the localization singleton behind `tr()` with the shipped texts,
/// so tests and screens read the same strings the app shows.
Future<void> loadTestTranslations() async {
  final data =
      jsonDecode(
            File(
              '$kTestTranslationsPath/${kTestTranslationsLocale.languageCode}.json',
            ).readAsStringSync(),
          )
          as Map<String, dynamic>;

  Localization.load(kTestTranslationsLocale, translations: Translations(data));
}

/// Pins the test surface to a phone size so ScreenUtil units and the
/// device pixel ratio stay predictable.
void usePhoneScreenSize(WidgetTester tester, {double devicePixelRatio = 1.0}) {
  final size = Size(375 * devicePixelRatio, 812 * devicePixelRatio);
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = devicePixelRatio;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}
