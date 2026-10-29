import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/auth_action_result.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view_model/forget_password_event.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view_model/forget_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../forget_password_widget_test_helpers.dart';

void main() {
  const emailKey = Key('emailField');
  const continueKey = Key('continueButton');

  late FakeForgetPasswordCubit cubit;

  setUp(() {
    cubit = FakeForgetPasswordCubit();
  });

  Future<void> pumpEmailStep(WidgetTester tester) async {
    await pumpForgetPassword(tester, cubit: cubit);
  }

  Future<void> submit(WidgetTester tester) async {
    await tester.tap(find.byKey(continueKey));
    await settle(tester);
  }

  testWidgets('renders the email step header, field and action', (
    tester,
  ) async {
    await pumpEmailStep(tester);

    expect(find.text('Forget Password'), findsOneWidget);
    expect(find.text('Enter Your Email'), findsOneWidget);
    expect(find.byKey(emailKey), findsOneWidget);
    expect(find.byKey(continueKey), findsOneWidget);
  });

  testWidgets('empty submission shows the required error and sends nothing', (
    tester,
  ) async {
    await pumpEmailStep(tester);

    await submit(tester);

    expect(find.text('This field is required.'), findsOneWidget);
    expect(cubit.events, isEmpty);
  });

  testWidgets('a malformed email shows the invalid email error', (
    tester,
  ) async {
    await pumpEmailStep(tester);

    await tester.enterText(find.byKey(emailKey), 'not-an-email');
    await submit(tester);

    expect(find.text('Please enter a valid email address.'), findsOneWidget);
    expect(cubit.events, isEmpty);
  });

  testWidgets('a valid email emits SendResetCode with the trimmed address', (
    tester,
  ) async {
    await pumpEmailStep(tester);

    await tester.enterText(find.byKey(emailKey), '  user@mail.com  ');
    await submit(tester);

    expect(cubit.events, contains(const SendResetCode(email: 'user@mail.com')));
  });

  testWidgets('the done keyboard action submits the form', (tester) async {
    await pumpEmailStep(tester);

    await tester.enterText(find.byKey(emailKey), 'user@mail.com');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);

    expect(cubit.events, contains(const SendResetCode(email: 'user@mail.com')));
  });

  testWidgets('the done keyboard action does nothing for an invalid email', (
    tester,
  ) async {
    await pumpEmailStep(tester);

    await tester.enterText(find.byKey(emailKey), 'nope');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await settle(tester);

    expect(cubit.events, isEmpty);
    expect(find.text('Please enter a valid email address.'), findsOneWidget);
  });

  testWidgets(
    'while sending the step locks: field off, button off, spinner on',
    (tester) async {
      cubit.setState(
        const ForgetPasswordState(
          sendCode: Resource<AuthActionResult>.loading(),
        ),
      );
      await pumpEmailStep(tester);

      expect(
        tester.widget<TextFormField>(find.byKey(emailKey)).enabled,
        isFalse,
      );
      expect(
        tester.widget<ElevatedButton>(find.byKey(continueKey)).onPressed,
        isNull,
      );
      expect(
        find.descendant(
          of: find.byKey(continueKey),
          matching: find.byType(CircularProgressIndicator),
        ),
        findsOneWidget,
      );
      expect(find.text('Sent OTP'), findsNothing);
    },
  );

  testWidgets('the field prefills with the email kept in state', (
    tester,
  ) async {
    cubit.setState(const ForgetPasswordState(email: 'user@mail.com'));
    await pumpEmailStep(tester);

    expect(
      tester.widget<TextFormField>(find.byKey(emailKey)).controller!.text,
      'user@mail.com',
    );
  });

  testWidgets('typing an email keeps the error message visible live', (
    tester,
  ) async {
    await pumpEmailStep(tester);

    await tester.enterText(find.byKey(emailKey), 'bad@@mail');
    await tester.tap(find.byKey(emailKey));
    await settle(tester);

    expect(find.text('Please enter a valid email address.'), findsOneWidget);

    await tester.enterText(find.byKey(emailKey), 'good@mail.com');
    await settle(tester);

    expect(find.text('Please enter a valid email address.'), findsNothing);
  });
}
