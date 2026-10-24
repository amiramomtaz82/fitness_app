import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/go_routes/routes_names.dart';
import 'package:fitness_app/core/theme/app_theme.dart';
import 'package:fitness_app/features/on_bording/views/onboarding_view.dart';
import 'package:fitness_app/features/on_bording/views/widgets/onboarding_buttons.dart';
import 'package:fitness_app/features/on_bording/views/widgets/onboarding_indicator.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _LoginStub extends StatelessWidget {
  const _LoginStub();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox.shrink());
  }
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  late GoRouter goRouter;

  setUp(() {
    goRouter = GoRouter(
      initialLocation: AppRoutes.onboarding,
      routes: [
        GoRoute(
          path: AppRoutes.onboarding,
          name: AppRoutes.onboarding,
          builder: (context, state) => const OnboardingView(),
        ),
        GoRoute(
          path: AppRoutes.login,
          name: AppRoutes.login,
          builder: (context, state) => const _LoginStub(),
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
    // Allow the async localization asset load to settle before asserting on
    // translated content.
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets(
    'Verify OnboardingView renders the first onboarding page content',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1200));

      await pumpApp(tester);

      expect(find.byType(OnboardingView), findsOneWidget);

      // First page content.
      expect(find.text(LocaleKeys.onboarding_title_1.tr()), findsOneWidget);
      expect(find.text(LocaleKeys.onboarding_desc_1.tr()), findsOneWidget);

      // Skip is available while there are more pages ahead.
      expect(find.text(LocaleKeys.onboarding_skip.tr()), findsOneWidget);

      // The first page only offers the next action.
      expect(find.text(LocaleKeys.onboarding_next.tr()), findsOneWidget);
      expect(find.text(LocaleKeys.onboarding_back.tr()), findsNothing);

      final OnboardingIndicator indicator = tester.widget<OnboardingIndicator>(
        find.byType(OnboardingIndicator),
      );
      expect(indicator.count, 3);

      final OnboardingButtons buttons = tester.widget<OnboardingButtons>(
        find.byType(OnboardingButtons),
      );
      expect(buttons.isFirst, isTrue);
      expect(buttons.isLast, isFalse);

      await tester.binding.setSurfaceSize(null);
    },
  );

  testWidgets('Verify tapping Next advances to the next onboarding page', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 1200));

    await pumpApp(tester);

    expect(find.text(LocaleKeys.onboarding_title_1.tr()), findsOneWidget);

    await tester.tap(find.text(LocaleKeys.onboarding_next.tr()));
    await tester.pumpAndSettle();

    // The second page content is displayed now.
    expect(find.text(LocaleKeys.onboarding_title_2.tr()), findsOneWidget);
    expect(find.text(LocaleKeys.onboarding_desc_2.tr()), findsOneWidget);

    // From the second page the back action becomes available, skip is
    // still available because it is not the last page.
    expect(find.text(LocaleKeys.onboarding_back.tr()), findsOneWidget);
    expect(find.text(LocaleKeys.onboarding_skip.tr()), findsOneWidget);
    expect(find.text(LocaleKeys.onboarding_next.tr()), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('Verify tapping Back returns to the previous onboarding page', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 1200));

    await pumpApp(tester);

    // Move to the second page first.
    await tester.tap(find.text(LocaleKeys.onboarding_next.tr()));
    await tester.pumpAndSettle();
    expect(find.text(LocaleKeys.onboarding_title_2.tr()), findsOneWidget);

    await tester.tap(find.text(LocaleKeys.onboarding_back.tr()));
    await tester.pumpAndSettle();

    expect(find.text(LocaleKeys.onboarding_title_1.tr()), findsOneWidget);
    expect(find.text(LocaleKeys.onboarding_back.tr()), findsNothing);
    expect(find.text(LocaleKeys.onboarding_next.tr()), findsOneWidget);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets('Verify tapping Skip navigates to the login screen', (
    WidgetTester tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(500, 1200));

    await pumpApp(tester);

    expect(find.byType(OnboardingView), findsOneWidget);
    expect(find.byType(_LoginStub), findsNothing);

    await tester.tap(find.text(LocaleKeys.onboarding_skip.tr()));
    await tester.pumpAndSettle();

    expect(find.byType(_LoginStub), findsOneWidget);
    expect(find.byType(OnboardingView), findsNothing);

    await tester.binding.setSurfaceSize(null);
  });

  testWidgets(
    'Verify the last onboarding page shows the Do It action and navigates to the login screen',
    (WidgetTester tester) async {
      await tester.binding.setSurfaceSize(const Size(500, 1200));

      await pumpApp(tester);

      // Advance to the last onboarding page.
      await tester.tap(find.text(LocaleKeys.onboarding_next.tr()));
      await tester.pumpAndSettle();
      await tester.tap(find.text(LocaleKeys.onboarding_next.tr()));
      await tester.pumpAndSettle();

      // The final page offers the do it action instead of the next one.
      expect(find.text(LocaleKeys.onboarding_title_3.tr()), findsOneWidget);
      expect(find.text(LocaleKeys.onboarding_do_it.tr()), findsOneWidget);

      final OnboardingButtons buttons = tester.widget<OnboardingButtons>(
        find.byType(OnboardingButtons),
      );
      expect(buttons.isLast, isTrue);

      await tester.tap(find.text(LocaleKeys.onboarding_do_it.tr()));
      await tester.pumpAndSettle();

      expect(find.byType(_LoginStub), findsOneWidget);
      expect(find.byType(OnboardingView), findsNothing);

      await tester.binding.setSurfaceSize(null);
    },
  );
}
