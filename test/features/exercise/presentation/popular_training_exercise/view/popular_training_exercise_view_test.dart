import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/app/routes_names.dart';
import 'package:fitness_app/core/theme/app_theme.dart';
import 'package:fitness_app/core/widgets/app_background_scaffold.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/popular_training_exercise_view.dart';
import 'package:fitness_app/features/exercise/presentation/popular_training_exercise/view/widgets/popular_training_exercise_card.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _createTestApp({required GoRouter router}) {
  return EasyLocalization(
    path: 'assets/translations',
    supportedLocales: const [Locale('en'), Locale('ar')],
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    saveLocale: false,
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      builder: (context, _) => MaterialApp.router(
        theme: AppTheme.darkTheme,
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        routerConfig: router,
      ),
    ),
  );
}

GoRouter _router() {
  return GoRouter(
    initialLocation: AppRoutes.popularTrainingExercise,
    routes: [
      GoRoute(
        path: AppRoutes.popularTrainingExercise,
        builder: (context, state) =>
            const PopularTrainingExerciseView(exerciseId: 'chest'),
      ),
      GoRoute(
        path: AppRoutes.exerciseVideo,
        builder: (context, state) => Scaffold(body: Text('Video: ${state.extra}')),
      ),
    ],
  );
}

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
  });

  Future<void> pumpView(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.runAsync(() async {
      await tester.pumpWidget(_createTestApp(router: _router()));
      for (var i = 0; i < 10; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    });
    await tester.pump();
  }

  group('PopularTrainingExerciseView —', () {
    testWidgets('renders the scaffold, hero title and level tabs', (
      tester,
    ) async {
      await pumpView(tester);

      expect(find.byType(AppBackgroundScaffold), findsOneWidget);
      expect(
        find.text('Chest ${LocaleKeys.exercises_exercise.tr()}'),
        findsOneWidget,
      );
      expect(find.text('Beginner'), findsOneWidget);
      expect(find.text('Intermediate'), findsOneWidget);
      expect(find.text('Advanced'), findsOneWidget);
    });

    testWidgets('shows the exercises of the default selected level', (
      tester,
    ) async {
      await pumpView(tester);

      expect(find.byType(PopularTrainingExerciseCard), findsNWidgets(3));
      expect(find.text('Bench Press'), findsOneWidget);
      expect(find.text('Incline Press'), findsOneWidget);
      expect(find.text('Chest Fly'), findsOneWidget);
    });

    testWidgets('switches the list when another level is selected', (
      tester,
    ) async {
      await pumpView(tester);

      await tester.runAsync(() async {
        await tester.tap(find.text('Advanced'));
        await tester.pump();
      });
      await tester.pump();

      expect(find.text('Planche Push Up'), findsOneWidget);
      expect(find.text('Bench Press'), findsNothing);
    });

    testWidgets('navigates to the video screen when a play button is tapped', (
      tester,
    ) async {
      await pumpView(tester);

      await tester.runAsync(() async {
        await tester.tap(find.byIcon(Icons.play_arrow_rounded).first);
        await tester.pumpAndSettle();
      });

      expect(find.text('Video: https://youtu.be/rT7DgCr-3pg'), findsOneWidget);
    });
  });
}
