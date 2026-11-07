import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

Widget makeTestableWidget(Widget child) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, _) => MaterialApp(theme: AppTheme.darkTheme, home: child),
  );
}

Widget makeTestableComponent(Widget child) {
  return makeTestableWidget(Scaffold(body: child));
}

Widget makeLocalizedApp({
  required List<GoRoute> routes,
  String initialLocation = '/',
}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('ar')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    saveLocale: false,
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      child: Builder(
        builder: (context) => MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          routerConfig: GoRouter(
            initialLocation: initialLocation,
            routes: routes,
          ),
        ),
      ),
    ),
  );
}

Widget makeLocalizedWidget(Widget child) {
  return makeLocalizedApp(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => Scaffold(body: SingleChildScrollView(child: child)),
      ),
    ],
  );
}

Widget makeLocalizedScreen(Widget screen) {
  return makeLocalizedApp(
    routes: [GoRoute(path: '/', builder: (_, _) => screen)],
  );
}

Future<void> pumpLocalizedApp(WidgetTester tester, Widget app) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(app);
    for (var i = 0; i < 8; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  });
}

Future<void> pumpLocalizedWidget(WidgetTester tester, Widget child) async {
  await pumpLocalizedApp(tester, makeLocalizedWidget(child));
}

Future<void> pumpLocalizedScreen(WidgetTester tester, Widget screen) async {
  await pumpLocalizedApp(tester, makeLocalizedScreen(screen));
}

Future<void> settleUi(WidgetTester tester, {int steps = 6}) async {
  for (var i = 0; i < steps; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}
