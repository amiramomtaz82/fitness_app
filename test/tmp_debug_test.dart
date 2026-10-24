import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:easy_localization/src/translations.dart';
import 'package:fitness_app/core/go_routes/routes_names.dart';
import 'package:fitness_app/core/theme/app_theme.dart';
import 'package:fitness_app/features/on_bording/views/onboarding_view.dart';
import 'package:fitness_app/features/splash/presentation/views/splash_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  late GoRouter goRouter;

  setUp(() {
    goRouter = GoRouter(
      initialLocation: AppRoutes.splash,
      routes: [
        GoRoute(
          path: AppRoutes.splash,
          name: AppRoutes.splash,
          builder: (context, state) => const SplashView(),
        ),
        GoRoute(
          path: AppRoutes.onboarding,
          name: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingView(),
        ),
      ],
    );
  });

  tearDown(() => goRouter.dispose());

  testWidgets('debug translations', (WidgetTester tester) async {
    final String content = await rootBundle.loadString('assets/translations/en.json');
    debugPrint('LOADED: ${content.substring(0, 40)}');
    final Map<String, dynamic> jsonMap = jsonDecode(content) as Map<String, dynamic>;
    final Object translations = Translations(jsonMap);
    debugPrint('RESOLVED: ${'onboarding.skip'.tr()}');

    await tester.binding.setSurfaceSize(const Size(500, 1200));
    await tester.pumpWidget(
      EasyLocalization(
        path: 'assets/translations',
        supportedLocales: const [Locale('en'), Locale('ar')],
        fallbackLocale: const Locale('en'),
        saveLocale: false,
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) => MaterialApp.router(
            theme: AppTheme.darkTheme,
            routerConfig: goRouter,
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    debugPrint('AFTER LOAD onboarding present: ${find.byType(OnboardingView).evaluate().length}');
    debugPrint('AFTER LOAD text: ${find.text('onboarding.skip').evaluate().length}');

    await tester.binding.setSurfaceSize(null);
  });
}
