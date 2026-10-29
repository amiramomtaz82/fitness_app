import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/app/routes_names.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/di/di.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/core/theme/app_theme.dart';
import 'package:fitness_app/core/widgets/app_background_scaffold.dart';
import 'package:fitness_app/core/widgets/app_catgory_tab_bar.dart';
import 'package:fitness_app/core/widgets/app_content_grid_view.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_entity.dart';
import 'package:fitness_app/features/exercise/domain/entities/muscle_group_entity.dart';
import 'package:fitness_app/features/exercise/presentation/work_out/view/work_out_view.dart';
import 'package:fitness_app/features/exercise/presentation/work_out/view_model/workout_cubit.dart';
import 'package:fitness_app/features/exercise/presentation/work_out/view_model/workout_intent.dart';
import 'package:fitness_app/features/exercise/presentation/work_out/view_model/workout_state.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockWorkoutCubit extends Mock implements WorkoutCubit {}

const _kGroupChest = MuscleGroupEntity(id: 'g1', name: 'Chest');
const _kGroupBack = MuscleGroupEntity(id: 'g2', name: 'Back');
const _kMuscleBench = MuscleEntity(id: 'm1', name: 'Bench', imageUrl: 'img1');
const _kMusclePushUp = MuscleEntity(id: 'm2', name: 'PushUp', imageUrl: 'img2');

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

void main() {
  late MockWorkoutCubit mockWorkoutCubit;
  late StreamController<BaseUiEvent> uiEvents;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    await EasyLocalization.ensureInitialized();
    registerFallbackValue(const InitWorkoutsIntent());
    registerFallbackValue(const RetryFetchMusclesIntent());
    registerFallbackValue(const SelectMuscleGroupIntent(_kGroupChest));
    registerFallbackValue(const MuscleSelectedIntent('m1'));
  });

  setUp(() {
    mockWorkoutCubit = MockWorkoutCubit();
    uiEvents = StreamController<BaseUiEvent>.broadcast();
    when(() => mockWorkoutCubit.eventStream).thenAnswer((_) => uiEvents.stream);
    when(() => mockWorkoutCubit.doIntent(any())).thenAnswer((_) async {});
    when(() => mockWorkoutCubit.close()).thenAnswer((_) async {});

    if (getIt.isRegistered<WorkoutCubit>()) {
      getIt.unregister<WorkoutCubit>();
    }
    getIt.registerFactory<WorkoutCubit>(() => mockWorkoutCubit);
  });

  tearDown(() async {
    await uiEvents.close();
    if (getIt.isRegistered<WorkoutCubit>()) {
      getIt.unregister<WorkoutCubit>();
    }
  });

  Future<void> pumpWorkOutView(
    WidgetTester tester, {
    WorkoutState state = const WorkoutState(),
  }) async {
    tester.view.physicalSize = const Size(500, 1000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    whenListen(
      mockWorkoutCubit,
      const Stream<WorkoutState>.empty(),
      initialState: state,
    );

    final router = GoRouter(
      initialLocation: AppRoutes.workouts,
      routes: [
        GoRoute(
          path: AppRoutes.workouts,
          builder: (context, state) => const WorkOutView(),
        ),
        GoRoute(
          path: AppRoutes.exercise,
          builder: (context, state) =>
              Scaffold(body: Text('Exercise: ${state.extra}')),
        ),
      ],
    );

    await tester.runAsync(() async {
      await tester.pumpWidget(_createTestApp(router: router));
      for (
        var i = 0;
        i < 20 && find.byType(AppBackgroundScaffold).evaluate().isEmpty;
        i++
      ) {
        await tester.pump(const Duration(milliseconds: 50));
      }
    });
    await tester.pump();
  }

  group('WorkOutView Widget Tests', () {
    testWidgets('dispatches InitWorkoutsIntent and renders title on mount', (
      tester,
    ) async {
      await pumpWorkOutView(tester);

      verify(
        () => mockWorkoutCubit.doIntent(const InitWorkoutsIntent()),
      ).called(1);
      expect(find.text(LocaleKeys.workouts_workouts.tr()), findsOneWidget);
    });

    testWidgets('shows loading indicator when muscles are loading', (
      tester,
    ) async {
      await pumpWorkOutView(
        tester,
        state: const WorkoutState(musclesResource: Resource.loading()),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets(
      'shows error state and dispatches RetryFetchMusclesIntent on retry tap',
      (tester) async {
        await pumpWorkOutView(
          tester,
          state: const WorkoutState(
            musclesResource: Resource.error(ServerFailure()),
          ),
        );

        expect(
          find.text(LocaleKeys.errors_something_went_wrong.tr()),
          findsOneWidget,
        );
        expect(find.text(LocaleKeys.common_retry.tr()), findsOneWidget);

        await tester.tap(find.text(LocaleKeys.common_retry.tr()));
        await tester.pump();

        verify(
          () => mockWorkoutCubit.doIntent(const RetryFetchMusclesIntent()),
        ).called(1);
      },
    );

    testWidgets('shows empty state when muscles list is empty', (tester) async {
      await pumpWorkOutView(
        tester,
        state: const WorkoutState(musclesResource: Resource.success([])),
      );

      expect(
        find.text(LocaleKeys.workouts_no_muscles_found.tr()),
        findsOneWidget,
      );
    });

    testWidgets('hides tabs bar when groups list is empty', (tester) async {
      await pumpWorkOutView(
        tester,
        state: const WorkoutState(groupsResource: Resource.success([])),
      );

      expect(find.byType(AppCategoryTabBar), findsNothing);
    });

    testWidgets('renders category tabs and muscle cards on success', (
      tester,
    ) async {
      await pumpWorkOutView(
        tester,
        state: const WorkoutState(
          groupsResource: Resource.success([_kGroupChest, _kGroupBack]),
          selectedGroup: _kGroupChest,
          musclesResource: Resource.success([_kMuscleBench, _kMusclePushUp]),
        ),
      );

      expect(find.byType(AppCategoryTabBar), findsOneWidget);
      expect(find.text('Chest'), findsOneWidget);
      expect(find.text('Back'), findsOneWidget);
      expect(find.byType(AppContentGridView), findsOneWidget);
      expect(find.text('Bench'), findsOneWidget);
      expect(find.text('PushUp'), findsOneWidget);
    });

    testWidgets('dispatches SelectMuscleGroupIntent when category tab tapped', (
      tester,
    ) async {
      await pumpWorkOutView(
        tester,
        state: const WorkoutState(
          groupsResource: Resource.success([_kGroupChest, _kGroupBack]),
          selectedGroup: _kGroupChest,
          musclesResource: Resource.success([_kMuscleBench]),
        ),
      );

      await tester.tap(find.text('Back'));
      await tester.pump();

      verify(
        () => mockWorkoutCubit.doIntent(
          any(
            that: isA<SelectMuscleGroupIntent>().having(
              (i) => i.group,
              'group',
              _kGroupBack,
            ),
          ),
        ),
      ).called(1);
    });

    testWidgets('dispatches MuscleSelectedIntent when muscle card tapped', (
      tester,
    ) async {
      await pumpWorkOutView(
        tester,
        state: const WorkoutState(
          groupsResource: Resource.success([_kGroupChest]),
          selectedGroup: _kGroupChest,
          musclesResource: Resource.success([_kMuscleBench, _kMusclePushUp]),
        ),
      );

      await tester.tap(find.text('Bench'));
      await tester.pump();

      verify(
        () => mockWorkoutCubit.doIntent(
          any(
            that: isA<MuscleSelectedIntent>().having(
              (i) => i.muscleId,
              'muscleId',
              'm1',
            ),
          ),
        ),
      ).called(1);
    });

    testWidgets('navigates to exercise screen on NavigateEvent', (
      tester,
    ) async {
      await pumpWorkOutView(tester);

      uiEvents.add(const NavigateEvent(AppRoutes.exercise, arguments: 'm1'));
      await tester.pumpAndSettle();

      expect(find.text('Exercise: m1'), findsOneWidget);
    });
  });
}
