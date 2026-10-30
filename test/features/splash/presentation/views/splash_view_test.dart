import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/app/routes_names.dart';
import 'package:fitness_app/core/contants/app_assets.dart';
import 'package:fitness_app/core/theme/app_colors.dart';
import 'package:fitness_app/core/theme/app_theme.dart';
import 'package:fitness_app/features/on_bording/views/onboarding_view.dart';
import 'package:fitness_app/features/splash/presentation/views/splash_view.dart';
import 'package:flutter/material.dart';
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

  Future<void> pumpApp(WidgetTester tester) async {
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
  }

  testWidgets('Verify SplashView displays the logo on the dark background', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 1200));

    await pumpApp(tester);

    expect(find.byType(SplashView), findsOneWidget);
    expect(find.byType(OnboardingView), findsNothing);

    final Scaffold scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, AppColors.background);

    final Image logoImage = tester.widget<Image>(find.byType(Image));
    expect(logoImage.image, isA<AssetImage>());
    expect((logoImage.image as AssetImage).assetName, AppAssets.logo);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets(
    'Verify SplashView navigates to the onboarding screen after the animation',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1200));

      await pumpApp(tester);
      await tester.pump();

      expect(find.byType(SplashView), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 700));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingView), findsOneWidget);
      expect(find.byType(SplashView), findsNothing);

      await tester.binding.setSurfaceSize(null);
    },
  );
}
