import 'dart:convert';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/features/auth/domain/entities/register_parameters.dart';
import 'package:fitness_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_cubit.dart';
import 'package:fitness_app/features/auth/presentation/register/view/muti_steps_regitration/multi_steps_registration_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class _CachedTranslationLoader extends AssetLoader {
  const _CachedTranslationLoader(this.translations);

  final Map<String, Map<String, dynamic>> translations;

  @override
  Future<Map<String, dynamic>?> load(String path, Locale locale) {
    return Future<Map<String, dynamic>?>.value(
      translations[locale.languageCode],
    );
  }
}

late final Map<String, Map<String, dynamic>> _translations;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(const RegisterParameters());
    _translations = {'en': _loadLocale('en'), 'ar': _loadLocale('ar')};
  });

  testWidgets('arabic uses rtl and an arabic validation message', (
    tester,
  ) async {
    final cubit = RegisterCubit(MockRegisterUseCase());
    addTearDown(cubit.close);
    await _pump(tester, cubit, const Locale('ar'));
    _expectRtl(tester);
    await _tapNext(tester, 'التالي');
    expect(find.text('هذا الحقل مطلوب.'), findsOneWidget);
    expect(cubit.state.currentStep, 0);
    await tester.pumpAndSettle();
  });

  testWidgets('scrolling the age wheel stores a new age', (tester) async {
    final cubit = RegisterCubit(MockRegisterUseCase());
    addTearDown(cubit.close);
    await _pump(tester, cubit, const Locale('en'));
    await _openAgeStep(tester, cubit);
    await _dragVisibleWheel(tester);
    expect(cubit.state.params.age, isNot(25));
    expect(cubit.state.params.age, inInclusiveRange(16, 100));
    expect(cubit.state.params.gender, 'male');
  });
}

Map<String, dynamic> _loadLocale(String code) {
  final raw = File('assets/translations/$code.json').readAsStringSync();
  return json.decode(raw) as Map<String, dynamic>;
}

void _expectRtl(WidgetTester tester) {
  expect(find.text('ذكر'), findsOneWidget);
  final direction = Directionality.of(tester.element(find.text('ذكر')));
  expect(direction, ui.TextDirection.rtl);
}

Future<void> _tapNext(WidgetTester tester, String label) async {
  await tester.tap(find.widgetWithText(ElevatedButton, label));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

Future<void> _openAgeStep(WidgetTester tester, RegisterCubit cubit) async {
  await tester.tap(find.text('Male'));
  await tester.pump();
  await tester.tap(find.widgetWithText(ElevatedButton, 'Next'));
  await tester.pumpAndSettle();
  expect(cubit.state.currentStep, 1);
  expect(cubit.state.params.age, 25);
}

Future<void> _dragVisibleWheel(WidgetTester tester) async {
  final wheel = find.byType(ListWheelScrollView).hitTestable();
  await tester.drag(wheel, const Offset(0, -160));
  await tester.pumpAndSettle();
}

Future<void> _pump(
  WidgetTester tester,
  RegisterCubit cubit,
  Locale locale,
) async {
  await tester.binding.setSurfaceSize(const Size(375, 812));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(_localizedApp(cubit, locale));
  await tester.pumpAndSettle();
}

Widget _localizedApp(RegisterCubit cubit, Locale locale) {
  return EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('ar')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: locale,
    saveLocale: false,
    assetLoader: _CachedTranslationLoader(_translations),
    child: _RegistrationHarness(cubit: cubit),
  );
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
