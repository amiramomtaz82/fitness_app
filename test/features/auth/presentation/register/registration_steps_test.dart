import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/features/auth/domain/entities/register_parameters.dart';
import 'package:fitness_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_cubit.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_intent.dart';
import 'package:fitness_app/features/auth/presentation/register/view/muti_steps_regitration/multi_steps_registration_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class _CachedTranslationLoader extends AssetLoader {
  const _CachedTranslationLoader(this.translations);

  final Map<String, dynamic> translations;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future<Map<String, dynamic>?>.value(translations);
  }
}

late final Map<String, dynamic> _english;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(const RegisterParameters());
    final raw = File('assets/translations/en.json').readAsStringSync();
    _english = json.decode(raw) as Map<String, dynamic>;
  });

  testWidgets('gender selection advances with the age default', (tester) async {
    final cubit = RegisterCubit(MockRegisterUseCase());
    addTearDown(cubit.close);
    await _pump(tester, cubit);

    await _rejectNext(tester);
    expect(cubit.state.currentStep, 0);

    await tester.tap(find.text('Male'));
    await tester.pump();
    expect(cubit.state.params.gender, 'male');

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    expect(cubit.state.currentStep, 1);
    expect(cubit.state.params.age, 25);
    expect(find.text('Year'), findsOneWidget);
  });

  testWidgets('next without a gender shows the required message', (tester) async {
    final cubit = RegisterCubit(MockRegisterUseCase());
    addTearDown(cubit.close);
    await _pump(tester, cubit);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('This field is required.'), findsOneWidget);
    expect(cubit.state.currentStep, 0);
    await tester.pumpAndSettle();
  });

  testWidgets('page swiping stays disabled', (tester) async {
    final cubit = RegisterCubit(MockRegisterUseCase());
    addTearDown(cubit.close);
    await _pump(tester, cubit);

    expect(find.byType(PageView), findsOneWidget);
    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.physics, isA<NeverScrollableScrollPhysics>());
  });

  testWidgets('each option stores its displayed text', (tester) async {
    final useCase = MockRegisterUseCase();
    final cubit = RegisterCubit(useCase);
    addTearDown(cubit.close);
    await _pump(tester, cubit);
    await _reachGoal(tester, cubit);
    await _chooseEach(tester, _goalLabels, (label) {
      expect(cubit.state.params.goal, label);
    });

    cubit.doIntent(const NextStepIntent());
    await tester.pumpAndSettle();
    await _chooseEach(tester, _activityLabels, (label) {
      expect(cubit.state.params.activityLevel, label);
    });
    verifyNever(() => useCase.call(any()));
  });

  testWidgets('final next keeps the profile and does not submit', (
    tester,
  ) async {
    final useCase = MockRegisterUseCase();
    final cubit = RegisterCubit(useCase);
    addTearDown(cubit.close);
    await _pump(tester, cubit);
    await _reachGoal(tester, cubit);
    await tester.tap(find.text('Lose Weight'));
    await tester.pump();
    cubit.doIntent(const NextStepIntent());
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Beginner'));
    await tester.tap(find.text('Beginner'));
    await tester.pump();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(cubit.state.params.firstName, isEmpty);
    expect(cubit.state.params.email, isEmpty);
    expect(cubit.state.params.password, isEmpty);
    expect(cubit.state.params.gender, 'female');
    expect(cubit.state.params.goal, 'Lose Weight');
    expect(cubit.state.params.activityLevel, 'Beginner');
    expect(cubit.state.registerResource.isInitial, isTrue);
    verifyNever(() => useCase.call(any()));
  });
}

const _goalLabels = [
  'Gain Weight',
  'Lose Weight',
  'Get Fitter',
  'Gain More Flexible',
  'Learn The Basic',
];

const _activityLabels = [
  'Rookie',
  'Beginner',
  'Intermediate',
  'Advance',
  'True Beast',
];

Future<void> _rejectNext(WidgetTester tester) async {
  await tester.tap(find.text('Next'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  _hideSnackBar(tester);
  await tester.pumpAndSettle();
}

void _hideSnackBar(WidgetTester tester) {
  final context = tester.element(find.byType(ElevatedButton));
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
}

Future<void> _chooseEach(
  WidgetTester tester,
  List<String> labels,
  void Function(String label) check,
) async {
  for (final label in labels) {
    await tester.ensureVisible(find.text(label));
    await tester.tap(find.text(label));
    await tester.pump();
    check(label);
  }
}

Future<void> _reachGoal(WidgetTester tester, RegisterCubit cubit) async {
  cubit.doIntent(const SelectGenderIntent('female'));
  await tester.pump();
  for (var step = 0; step < 4; step++) {
    cubit.doIntent(const NextStepIntent());
    await tester.pumpAndSettle();
  }
}

Future<void> _pump(WidgetTester tester, RegisterCubit cubit) async {
  await tester.binding.setSurfaceSize(const Size(375, 812));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    EasyLocalization(
      supportedLocales: const [Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      startLocale: const Locale('en'),
      saveLocale: false,
      assetLoader: _CachedTranslationLoader(_english),
      child: _RegistrationHarness(cubit: cubit),
    ),
  );
  await tester.pumpAndSettle();
}

class _RegistrationHarness extends StatelessWidget {
  const _RegistrationHarness({required this.cubit});

  final RegisterCubit cubit;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => MultiStepsRegistrationView(cubit: cubit),
      ),
    );
  }
}
