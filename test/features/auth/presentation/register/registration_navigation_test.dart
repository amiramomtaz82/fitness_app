import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/app/routes_names.dart';
import 'package:fitness_app/core/di/di.dart';
import 'package:fitness_app/features/auth/domain/entities/register_parameters.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_cubit.dart';
import 'package:fitness_app/features/auth/presentation/register/view/muti_steps_regitration/multi_steps_registration_view.dart';
import 'package:fitness_app/features/auth/presentation/register/view/register_first_sceen/register_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'register_test_helper.dart';

class InMemoryAssetLoader extends AssetLoader {
  const InMemoryAssetLoader(this.data);

  final Map<String, dynamic> data;

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return data;
  }
}

void main() {
  late Map<String, dynamic> english;
  late RegisterCubit cubit;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    english =
        jsonDecode(File('assets/translations/en.json').readAsStringSync())
            as Map<String, dynamic>;
    await EasyLocalization.ensureInitialized();
    registerFallbackValue(const RegisterParameters());
  });

  setUp(() {
    cubit = createTestRegisterCubit();
    if (getIt.isRegistered<RegisterCubit>()) {
      getIt.unregister<RegisterCubit>();
    }
    getIt.registerFactory<RegisterCubit>(() => cubit);
  });

  tearDown(() {
    if (getIt.isRegistered<RegisterCubit>()) {
      getIt.unregister<RegisterCubit>();
    }
    cubit.close();
  });

  testWidgets(
    'wizard steps move while the account screen stays underneath',
    (tester) async {
      final router = _router();
      await _pump(tester, router, english);

      await _fillAccount(tester);
      await tester.tap(_accountNext());
      await tester.pumpAndSettle();

      expect(find.byType(MultiStepsRegistrationView), findsOneWidget);
      expect(cubit.state.params.firstName, 'Ada');
      expect(find.byType(RegisterView, skipOffstage: false), findsOneWidget);

      await tester.tap(_wizardNext());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('This field is required.'), findsOneWidget);
      expect(cubit.state.currentStep, 0);

      await tester.tap(find.text('Male'));
      await tester.pump();
      await tester.tap(_wizardNext());
      await tester.pumpAndSettle();

      expect(cubit.state.currentStep, 1);
      expect(cubit.state.isPaging, isFalse);
      expect(cubit.state.params.age, 25);
      expect(find.text('Year'), findsOneWidget);
      expect(find.text('HOW OLD ARE YOU ?'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(cubit.state.currentStep, 0);
      expect(cubit.state.params.gender, 'male');
      expect(find.text('Male'), findsOneWidget);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(MultiStepsRegistrationView), findsNothing);
      expect(find.text('Ada'), findsOneWidget);
      expect(router.state.uri.path, AppRoutes.register);
    },
  );

  testWidgets('the covered account screen does not pop the wizard twice', (
    tester,
  ) async {
    final router = _router();
    await _pump(tester, router, english);
    await _fillAccount(tester);
    await tester.tap(_accountNext());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();

    expect(router.state.uri.path, AppRoutes.register);
    expect(find.byType(RegisterView), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

GoRouter _router() {
  return GoRouter(
    initialLocation: AppRoutes.register,
    routes: [
      GoRoute(
        path: AppRoutes.register,
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: AppRoutes.multiStepRegistration,
        builder: (context, state) {
          final cubit = state.extra! as RegisterCubit;
          return BlocProvider.value(
            value: cubit,
            child: const MultiStepsRegistrationView(),
          );
        },
      ),
    ],
  );
}

Finder _accountNext() {
  return find.descendant(
    of: find.byType(RegisterView),
    matching: find.widgetWithText(ElevatedButton, 'Next'),
  );
}

Finder _wizardNext() {
  return find.descendant(
    of: find.byType(MultiStepsRegistrationView),
    matching: find.widgetWithText(ElevatedButton, 'Next'),
  );
}

Future<void> _fillAccount(WidgetTester tester) async {
  final fields = find.descendant(
    of: find.byType(RegisterView),
    matching: find.byType(TextFormField),
  );
  await tester.enterText(fields.at(0), 'Ada');
  await tester.enterText(fields.at(1), 'Lovelace');
  await tester.enterText(fields.at(2), 'ada@example.com');
  await tester.enterText(fields.at(3), 'Secret1@#');
  await tester.ensureVisible(_accountNext());
}

Future<void> _pump(
  WidgetTester tester,
  GoRouter router,
  Map<String, dynamic> english,
) async {
  tester.view.physicalSize = const Size(375 * 3, 812 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      saveLocale: false,
      useOnlyLangCode: true,
      assetLoader: InMemoryAssetLoader(english),
      child: Builder(
        builder: (context) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp.router(
                routerConfig: router,
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
              );
            },
          );
        },
      ),
    ),
  );
  await tester.pumpAndSettle();
}
