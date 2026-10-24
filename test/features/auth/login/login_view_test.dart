import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/auth/presentation/login/view/login_view.dart';
import 'package:fitness_app/features/auth/presentation/login/view_model/login_cubit.dart';
import 'package:fitness_app/features/auth/presentation/login/view_model/login_intent.dart';
import 'package:fitness_app/features/auth/presentation/login/view_model/login_state.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../helpers/test_app.dart';

class MockLoginCubit extends Mock implements LoginCubit {}

void main() {
  late MockLoginCubit mockCubit;
  late StreamController<BaseUiEvent> events;

  Widget makeTestable() {
    return makeTestableWidget(
      BlocProvider<LoginCubit>.value(
        value: mockCubit,
        child: const LoginView(),
      ),
    );
  }

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
    events = StreamController<BaseUiEvent>.broadcast();
    when(() => mockCubit.eventStream).thenAnswer((_) => events.stream);
    when(() => mockCubit.close()).thenAnswer((_) async {});
    givenStates(const LoginState());
  });

  tearDown(() => events.close());

  Future<void> tapByKey(WidgetTester tester, String key) async {
    final finder = find.byKey(Key(key));
    await tester.ensureVisible(finder);
    await tester.tap(finder);
    await tester.pump();
  }

  group('LoginView Widget Tests —', () {
    testWidgets('renders header, fields and buttons', (tester) async {
      await tester.pumpWidget(makeTestable());
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
      await tester.pumpWidget(makeTestable());
      await tester.pumpAndSettle();

      await tapByKey(tester, 'loginBtn');

      expect(find.text(LocaleKeys.validation_field_required), findsNWidgets(2));
      verifyNever(() => mockCubit.doIntent(any()));
    });

    testWidgets('email field shows validation error on invalid input', (
      tester,
    ) async {
      await tester.pumpWidget(makeTestable());
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
      await tester.pumpWidget(makeTestable());
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

      await tester.pumpWidget(makeTestable());
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
      await tester.pumpWidget(makeTestable());
      await tester.pumpAndSettle();

      await tapByKey(tester, 'togglePasswordBtn');

      verify(
        () => mockCubit.doIntent(
          any(that: isA<TogglePasswordVisibilityIntent>()),
        ),
      ).called(1);
    });

    testWidgets('eye icon reflects the password visibility state', (
      tester,
    ) async {
      givenStates(const LoginState(), [
        const LoginState(isPasswordObscured: false),
      ]);

      await tester.pumpWidget(makeTestable());
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets('shows the server message on wrong credentials', (
      tester,
    ) async {
      await tester.pumpWidget(makeTestable());
      await tester.pumpAndSettle();

      events.add(
        const ShowErrorSnackBarEvent(
          UnauthorizedFailure(serverMessage: 'incorrect email or password'),
        ),
      );
      await tester.pump(); // deliver the event
      await tester.pump(); // build the snackbar

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('incorrect email or password'), findsOneWidget);
    });

    testWidgets('register and forgot password send navigation intents', (
      tester,
    ) async {
      await tester.pumpWidget(makeTestable());
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
