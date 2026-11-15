import 'package:fitness_app/core/contants/app_language.dart';
import 'package:fitness_app/core/di/di.dart';
import 'package:fitness_app/core/local/locale_cubit.dart';
import 'package:fitness_app/core/local/locale_preferences.dart';
import 'package:fitness_app/core/local/locale_scope.dart';
import 'package:fitness_app/core/local/local_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_app.dart';

class _MockLocaleService extends Mock implements LocaleService {}

void main() {
  late LocaleCubit cubit;
  late _MockLocaleService localeService;

  setUp(() async {
    SharedPreferences.setMockInitialValues({
      'app_language_code': AppLanguage.arabic.code,
    });
    final preferences = LocalePreferences(
      await SharedPreferences.getInstance(),
    );
    localeService = _MockLocaleService();
    cubit = LocaleCubit(preferences, localeService);
    getIt.registerSingleton<LocaleCubit>(cubit);
  });

  tearDown(() => getIt.unregister<LocaleCubit>());

  Future<void> pumpScope(WidgetTester tester, Widget child) async {
    await pumpLocalizedApp(
      tester,
      makeLocalizedApp(
        routes: [
          GoRoute(
            path: '/',
            builder: (_, _) => LocaleScope(child: child),
          ),
        ],
      ),
    );
  }

  testWidgets('shares the registered cubit with everything inside it', (
    tester,
  ) async {
    await pumpScope(
      tester,
      Builder(
        builder: (context) =>
            Text(context.read<LocaleCubit>() == cubit ? 'SHARED' : 'OTHER'),
      ),
    );

    expect(find.text('SHARED'), findsOneWidget);
  });

  testWidgets('loads the saved locale as soon as it is on screen', (
    tester,
  ) async {
    await pumpScope(tester, const SizedBox());

    verify(
      () => localeService.setLanguageCode(AppLanguage.arabic.code),
    ).called(greaterThanOrEqualTo(1));
  });
}
