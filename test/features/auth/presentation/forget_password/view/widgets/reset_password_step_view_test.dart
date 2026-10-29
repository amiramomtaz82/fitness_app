import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/auth_action_result.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view_model/forget_password_event.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view_model/forget_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../forget_password_widget_test_helpers.dart';

void main() {
  const passwordKey = Key('passwordField');
  const confirmKey = Key('confirmPasswordField');
  const resetKey = Key('resetButton');

  const resetState = ForgetPasswordState(
    step: ForgetPasswordStep.resetPassword,
    email: 'user@mail.com',
  );

  late FakeForgetPasswordCubit cubit;

  setUp(() {
    cubit = FakeForgetPasswordCubit();
  });

  Future<void> pumpResetStep(
    WidgetTester tester, {
    ForgetPasswordState state = resetState,
  }) async {
    cubit.setState(state);
    await pumpForgetPassword(tester, cubit: cubit);
  }

  Future<void> fillAndSubmit(
    WidgetTester tester,
    String password,
    String confirm,
  ) async {
    await tester.enterText(find.byKey(passwordKey), password);
    await tester.enterText(find.byKey(confirmKey), confirm);
    await tester.tap(find.byKey(resetKey));
    await settle(tester);
  }

  testWidgets('renders the reset step header, both fields and done button', (
    tester,
  ) async {
    await pumpResetStep(tester);

    expect(find.text('Create New Password'), findsOneWidget);
    expect(find.text('Make Sure Its 8 Characters Or More'), findsOneWidget);
    expect(find.byKey(passwordKey), findsOneWidget);
    expect(find.byKey(confirmKey), findsOneWidget);
    expect(find.byKey(resetKey), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });

  testWidgets('a short password is rejected with the length message', (
    tester,
  ) async {
    await pumpResetStep(tester);

    await fillAndSubmit(tester, 'short1', 'short1');

    expect(
      find.text('Password must be at least 8 characters.'),
      findsOneWidget,
    );
    expect(cubit.events, isEmpty);
  });

  testWidgets('a password without a digit is rejected', (tester) async {
    await pumpResetStep(tester);

    await fillAndSubmit(tester, 'Abcdefg@', 'Abcdefg@');

    expect(
      find.text('Password must contain at least one digit.'),
      findsOneWidget,
    );
    expect(cubit.events, isEmpty);
  });

  testWidgets('a blank confirmation is rejected as required', (tester) async {
    await pumpResetStep(tester);

    await fillAndSubmit(tester, 'NewPass@1', '');

    expect(find.text('This field is required.'), findsOneWidget);
    expect(cubit.events, isEmpty);
  });

  testWidgets('mismatched passwords are rejected with the match message', (
    tester,
  ) async {
    await pumpResetStep(tester);

    await fillAndSubmit(tester, 'NewPass@1', 'OtherPass@1');

    expect(find.text('Passwords do not match.'), findsOneWidget);
    expect(cubit.events, isEmpty);
  });

  testWidgets('valid matching passwords emit SubmitNewPassword', (
    tester,
  ) async {
    await pumpResetStep(tester);

    await fillAndSubmit(tester, 'NewPass@1', 'NewPass@1');

    expect(
      cubit.events,
      contains(
        const SubmitNewPassword(
          password: 'NewPass@1',
          confirmPassword: 'NewPass@1',
        ),
      ),
    );
  });

  testWidgets('the done keyboard action on confirm submits the form', (
    tester,
  ) async {
    await pumpResetStep(tester);

    await tester.enterText(find.byKey(passwordKey), 'NewPass@1');
    await tester.enterText(find.byKey(confirmKey), 'NewPass@1');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);

    expect(
      cubit.events,
      contains(
        const SubmitNewPassword(
          password: 'NewPass@1',
          confirmPassword: 'NewPass@1',
        ),
      ),
    );
  });

  testWidgets('both password fields start obscured', (tester) async {
    await pumpResetStep(tester);

    expect(fieldObscured(tester, passwordKey), isTrue);
    expect(fieldObscured(tester, confirmKey), isTrue);
  });

  testWidgets('the password toggle reveals only the password field', (
    tester,
  ) async {
    await pumpResetStep(tester);

    await tester.tap(
      find.descendant(
        of: find.byKey(passwordKey),
        matching: find.byIcon(Icons.visibility_off),
      ),
    );
    await settle(tester);

    expect(fieldObscured(tester, passwordKey), isFalse);
    expect(fieldObscured(tester, confirmKey), isTrue);
    expect(
      find.descendant(
        of: find.byKey(passwordKey),
        matching: find.byIcon(Icons.visibility),
      ),
      findsOneWidget,
    );
  });

  testWidgets('the confirm toggle reveals only the confirm field', (
    tester,
  ) async {
    await pumpResetStep(tester);

    await tester.tap(
      find.descendant(
        of: find.byKey(confirmKey),
        matching: find.byIcon(Icons.visibility_off),
      ),
    );
    await settle(tester);

    expect(fieldObscured(tester, confirmKey), isFalse);
    expect(fieldObscured(tester, passwordKey), isTrue);
  });

  testWidgets('tapping the toggle twice hides the password again', (
    tester,
  ) async {
    await pumpResetStep(tester);

    final toggle = find.descendant(
      of: find.byKey(passwordKey),
      matching: find.byIcon(Icons.visibility_off),
    );
    await tester.tap(toggle);
    await settle(tester);
    await tester.tap(
      find.descendant(
        of: find.byKey(passwordKey),
        matching: find.byIcon(Icons.visibility),
      ),
    );
    await settle(tester);

    expect(fieldObscured(tester, passwordKey), isTrue);
  });

  testWidgets(
    'while submitting the step locks: fields off, button off, spinner on',
    (tester) async {
      await pumpResetStep(
        tester,
        state: const ForgetPasswordState(
          step: ForgetPasswordStep.resetPassword,
          email: 'user@mail.com',
          resetPassword: Resource<AuthActionResult>.loading(),
        ),
      );

      expect(
        tester.widget<TextFormField>(find.byKey(passwordKey)).enabled,
        isFalse,
      );
      expect(
        tester.widget<TextFormField>(find.byKey(confirmKey)).enabled,
        isFalse,
      );
      expect(
        tester.widget<ElevatedButton>(find.byKey(resetKey)).onPressed,
        isNull,
      );
      expect(
        find.descendant(
          of: find.byKey(resetKey),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      expect(find.text('Done'), findsNothing);
    },
  );
}
