import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/features/auth/domain/entities/register_parameters.dart';
import 'package:fitness_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_cubit.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_intent.dart';
import 'package:fitness_app/features/auth/presentation/register/view/muti_steps_regitration/multi_steps_registration_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fitness_app/features/auth/presentation/register/registration_options.dart';
import 'register_test_helper.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class CachedTranslationLoader extends AssetLoader {
  const CachedTranslationLoader(this.translations);

  final Map<String, dynamic> translations;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future<Map<String, dynamic>?>.value(translations);
  }
}

late final Map<String, dynamic> _english;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(loadEnglishTranslations);
  registrationStepTests();
}

Future<void> loadEnglishTranslations() async {
  registerFallbackValue(const RegisterParameters());
  final raw = await rootBundle.loadString('assets/translations/en.json');
  _english = json.decode(raw) as Map<String, dynamic>;
}

void registrationStepTests() {
  genderAdvancesWithAgeDefault();
  nextWithoutGenderShowsRequired();
  goalErrorStaysBelowTheChoices();
  nextStaysDisabledWhilePaging();
  backKeepsTheSelection();
  pageSwipingStaysDisabled();
  eachOptionStoresDisplayedText();
  finalNextKeepsProfile();
}

void genderAdvancesWithAgeDefault() {
  testWidgets('gender selection advances with the age default', (tester) async {
    final cubit = createTestRegisterCubit();
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
}

void nextWithoutGenderShowsRequired() {
  testWidgets('next without a gender shows the required message', (
    tester,
  ) async {
    final cubit = createTestRegisterCubit();
    addTearDown(cubit.close);
    await _pump(tester, cubit);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('This field is required.'), findsOneWidget);
    expect(cubit.state.currentStep, 0);
    await tester.pumpAndSettle();
  });
}

void goalErrorStaysBelowTheChoices() {
  testWidgets('a goal error stays below the choices', (tester) async {
    final cubit = createTestRegisterCubit();
    addTearDown(cubit.close);
    await _pump(tester, cubit);
    await _reachGoal(tester, cubit);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('This field is required.'), findsOneWidget);
    expect(find.byType(SnackBar), findsNothing);
    expect(cubit.state.currentStep, 4);

    final message = tester.getRect(find.text('This field is required.'));
    final button = tester.getRect(
      find.widgetWithText(ElevatedButton, 'Next'),
    );
    final lastVisible = tester.getRect(find.text('Gain More Flexible'));
    expect(message.bottom, lessThanOrEqualTo(button.top));
    expect(message.top, greaterThanOrEqualTo(lastVisible.center.dy));

    await tester.fling(find.text('Gain Weight'), const Offset(0, -500), 1200);
    await tester.pumpAndSettle();
    expect(
      tester.getRect(find.text('Learn The Basic')).center.dy,
      lessThanOrEqualTo(tester.getRect(find.text('This field is required.')).top),
    );

    await tester.tap(find.text('Learn The Basic'));
    await tester.pump();
    expect(cubit.state.selectedGoal, RegistrationGoal.learnTheBasic);
    expect(find.text('This field is required.'), findsNothing);
  });
}

void nextStaysDisabledWhilePaging() {
  testWidgets('next stays disabled until the page finishes moving', (
    tester,
  ) async {
    final cubit = createTestRegisterCubit();
    addTearDown(cubit.close);
    await _pump(tester, cubit);
    await _startPaging(tester);
    _expectPagingLocked(tester, cubit);
    await _finishPaging(tester, cubit);
  });
}

Future<void> _startPaging(WidgetTester tester) async {
  await tester.tap(find.text('Male'));
  await tester.pump();
  await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
  await tester.pump();
}

void _expectPagingLocked(WidgetTester tester, RegisterCubit cubit) {
  expect(cubit.state.isPaging, isTrue);
  expect(_nextButton(tester).onPressed, isNull);
}

Future<void> _finishPaging(WidgetTester tester, RegisterCubit cubit) async {
  await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
  await tester.pumpAndSettle();
  expect(cubit.state.currentStep, 1);
  expect(cubit.state.isPaging, isFalse);
  expect(_nextButton(tester).onPressed, isNotNull);
  expect(_page(tester), 1);
}

void backKeepsTheSelection() {
  testWidgets('back returns to the previous step and keeps the selection', (
    tester,
  ) async {
    final cubit = createTestRegisterCubit();
    addTearDown(cubit.close);
    await _pump(tester, cubit);
    await tester.tap(find.text('Male'));
    await tester.pump();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(cubit.state.currentStep, 0);
    expect(cubit.state.params.gender, 'male');
    expect(cubit.state.params.age, 25);
    expect(cubit.state.isPaging, isFalse);
    expect(find.text('Male'), findsOneWidget);
  });
}

void pageSwipingStaysDisabled() {
  testWidgets('page swiping stays disabled', (tester) async {
    final cubit = createTestRegisterCubit();
    addTearDown(cubit.close);
    await _pump(tester, cubit);

    expect(find.byType(PageView), findsOneWidget);
    final pageView = tester.widget<PageView>(find.byType(PageView));
    expect(pageView.physics, isA<NeverScrollableScrollPhysics>());
  });
}

void eachOptionStoresDisplayedText() {
  testWidgets('each option stores its displayed text', (tester) async {
    final useCase = MockRegisterUseCase();
    final cubit = createTestRegisterCubit(registerUseCase: useCase);
    addTearDown(cubit.close);
    await _pump(tester, cubit);
    await _reachGoal(tester, cubit);
    await _chooseEach(tester, _goalLabels, (label) {
      final goal = RegistrationGoal.values[_goalLabels.indexOf(label)];
      expect(cubit.state.params.goal, goal.apiKey);
    });

    cubit.doIntent(const NextStepIntent());
    await tester.pumpAndSettle();
    await _chooseEach(tester, _activityLabels, (label) {
      final activity =
          RegistrationActivity.values[_activityLabels.indexOf(label)];
      expect(cubit.state.params.activityLevel, activity.apiKey);
    });
    verifyNever(() => useCase.call(any()));
  });
}

void finalNextKeepsProfile() {
  testWidgets('final next keeps the profile and does not submit', (
    tester,
  ) async {
    final useCase = MockRegisterUseCase();
    final cubit = createTestRegisterCubit(registerUseCase: useCase);
    addTearDown(cubit.close);
    await _pump(tester, cubit);
    await _selectBeginner(tester, cubit);
    _expectKeptProfile(cubit, useCase);
  });
}

Future<void> _selectBeginner(WidgetTester tester, RegisterCubit cubit) async {
  await _reachGoal(tester, cubit);
  await tester.tap(find.text('Lose Weight'));
  await tester.pump();
  cubit.doIntent(const NextStepIntent());
  await tester.pumpAndSettle();
  await tester.ensureVisible(find.text('Beginner'));
  await tester.tap(find.text('Beginner'));
  await tester.pump();
  expect(_nextButton(tester).onPressed, isNotNull);
}

void _expectKeptProfile(RegisterCubit cubit, MockRegisterUseCase useCase) {
  expect(cubit.state.params.firstName, isEmpty);
  expect(cubit.state.params.email, isEmpty);
  expect(cubit.state.params.password, isEmpty);
  expect(cubit.state.params.gender, 'female');
  expect(cubit.state.params.goal, 'Lose weight');
  expect(cubit.state.params.activityLevel, 'level2');
  expect(cubit.state.registerResource.isInitial, isTrue);
  verifyNever(() => useCase.call(any()));
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

ElevatedButton _nextButton(WidgetTester tester) {
  return tester.widget<ElevatedButton>(find.byType(ElevatedButton));
}

double _page(WidgetTester tester) {
  final page = tester.widget<PageView>(find.byType(PageView)).controller?.page;
  return page ?? 0;
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
      assetLoader: CachedTranslationLoader(_english),
      child: RegistrationHarness(cubit: cubit),
    ),
  );
  await tester.pumpAndSettle();
}

class RegistrationHarness extends StatelessWidget {
  const RegistrationHarness({super.key, required this.cubit});

  final RegisterCubit cubit;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: context.locale,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      home: ScreenUtilInit(
        designSize: const Size(375, 812),
        builder: (_, _) => BlocProvider.value(
          value: cubit,
          child: const MultiStepsRegistrationView(),
        ),
      ),
    );
  }
}
