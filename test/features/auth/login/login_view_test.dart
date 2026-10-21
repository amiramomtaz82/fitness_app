import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/auth/presentation/login/view/login_view.dart';
import 'package:fitness_app/features/auth/presentation/login/view_model/login_cubit.dart';
import 'package:fitness_app/features/auth/presentation/login/view_model/login_intent.dart';
import 'package:fitness_app/features/auth/presentation/login/view_model/login_state.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginCubit extends Mock implements LoginCubit {}

Widget _makeTestable() {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    builder: (_, _) => const MaterialApp(home: LoginView()),
  );
}

void main() {
  late MockLoginCubit mockCubit;

  setUpAll(() {
    registerFallbackValue(const TogglePasswordVisibilityIntent());
  });

  void givenStates(
    LoginState initialState, [
    List<LoginState> states = const [],
  ]) {
    whenListen(
      mockCubit,
      Stream<LoginState>.fromIterable(states),
      initialState: initialState,
    );
  }

  setUp(() {
    mockCubit = MockLoginCubit();
    when(() => mockCubit.eventStream).thenAnswer((_) => const Stream.empty());
    when(() => mockCubit.close()).thenAnswer((_) async {});
    givenStates(const LoginState());

    GetIt.instance.registerSingleton<LoginCubit>(mockCubit);
  });

  tearDown(() => GetIt.instance.reset());

  Future<void> tapByKey(WidgetTester tester, String key) async {
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pump();
  }

  group('LoginView Widget Tests —', () {
    testWidgets('renders header, fields and buttons', (tester) async {
      await tester.pumpWidget(_makeTestable());
      await tester.pumpAndSettle();

      expect(find.text(LocaleKeys.auth_hey_there), findsOneWidget);
      expect(find.text(LocaleKeys.auth_welcome_back), findsOneWidget);
      expect(find.byKey(const Key('emailField')), findsOneWidget);
      expect(find.byKey(const Key('passwordField')), findsOneWidget);
      expect(find.byKey(const Key('forgotPasswordBtn')), findsOneWidget);
      expect(find.byKey(const Key('loginBtn')), findsOneWidget);
      expect(find.byKey(const Key('registerBtn')), findsOneWidget);
    });

    testWidgets('shows required errors and does not submit empty form', (
      tester,
    ) async {
      await tester.pumpWidget(_makeTestable());
      await tester.pumpAndSettle();

      await tapByKey(tester, 'loginBtn');

      expect(find.text(LocaleKeys.validation_field_required), findsNWidgets(2));
      verifyNever(() => mockCubit.doIntent(any()));
    });

    testWidgets('email field shows validation error on invalid input', (
      tester,
    ) async {
      await tester.pumpWidget(_makeTestable());
      await tester.pumpAndSettle();

      await tester.enterText(find.byKey(const Key('emailField')), 'bademail');
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'Pass1234',
      );
      await tapByKey(tester, 'loginBtn');

      expect(find.text(LocaleKeys.validation_invalid_email), findsOneWidget);
      verifyNever(() => mockCubit.doIntent(any()));
    });

    testWidgets('submits the entered email and password', (tester) async {
      await tester.pumpWidget(_makeTestable());
      await tester.pumpAndSettle();

      await tester.enterText(
        find.byKey(const Key('emailField')),
        'test@test.com',
      );
      await tester.enterText(
        find.byKey(const Key('passwordField')),
        'Pass1234',
      );
      await tapByKey(tester, 'loginBtn');

      expect(
        verify(() => mockCubit.doIntent(captureAny())).captured.single,
        isA<LoginSubmittedIntent>()
            .having((i) => i.email, 'email', 'test@test.com')
            .having((i) => i.password, 'password', 'Pass1234'),
      );
    });

    testWidgets('shows loading indicator when state is loading', (
      tester,
    ) async {
      givenStates(const LoginState(loginResource: Resource.loading()));

      await tester.pumpWidget(_makeTestable());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      final loginBtn = tester.widget<ElevatedButton>(
        find.byKey(const Key('loginBtn')),
      );
      expect(loginBtn.onPressed, isNull);
    });

    testWidgets('eye button sends TogglePasswordVisibilityIntent', (
      tester,
    ) async {
      await tester.pumpWidget(_makeTestable());
      await tester.pumpAndSettle();

      await tapByKey(tester, 'togglePasswordBtn');

      verify(
        () => mockCubit.doIntent(
          any(that: isA<TogglePasswordVisibilityIntent>()),
        ),
      ).called(1);
    });

    testWidgets('register and forgot password send navigation intents', (
      tester,
    ) async {
      await tester.pumpWidget(_makeTestable());
      await tester.pumpAndSettle();

      await tapByKey(tester, 'registerBtn');
      await tapByKey(tester, 'forgotPasswordBtn');

      verify(
        () => mockCubit.doIntent(any(that: isA<NavigateToRegisterIntent>())),
      ).called(1);
      verify(
        () => mockCubit.doIntent(
          any(that: isA<NavigateToForgetPasswordIntent>()),
        ),
      ).called(1);
    });
  });
}
