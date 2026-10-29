import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/auth_action_result.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view_model/forget_password_event.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view_model/forget_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pinput/pinput.dart';

import '../../forget_password_widget_test_helpers.dart';

void main() {
  const otpKey = Key('otpField');
  const confirmKey = Key('confirmButton');
  const resendKey = Key('resendButton');

  late FakeForgetPasswordCubit cubit;

  setUp(() {
    cubit = FakeForgetPasswordCubit();
  });

  Future<void> pumpOtpStep(
    WidgetTester tester, {
    ForgetPasswordState? state,
  }) async {
    cubit.setState(
      state ??
          const ForgetPasswordState(
            step: ForgetPasswordStep.otp,
            email: 'user@mail.com',
          ),
    );
    await pumpForgetPassword(tester, cubit: cubit);
  }

  Future<void> typeCode(WidgetTester tester, String code) async {
    await tester.enterText(find.byType(EditableText).first, code);
    await tester.pump();
  }

  testWidgets('renders the otp step header, field, confirm and resend', (
    tester,
  ) async {
    await pumpOtpStep(tester);

    expect(find.text('OTP CODE'), findsOneWidget);
    expect(find.text('Enter Your OTP Check Your Email'), findsOneWidget);
    expect(find.byKey(otpKey), findsOneWidget);
    expect(find.byKey(confirmKey), findsOneWidget);
    expect(find.text('Didnt Recieve Verification Code?'), findsOneWidget);
    expect(find.text('Resend Code?'), findsOneWidget);
  });

  testWidgets('typing the full code auto-submits without a tap', (
    tester,
  ) async {
    await pumpOtpStep(tester);

    await typeCode(tester, '7542');
    await settle(tester);

    expect(
      cubit.events,
      contains(const VerifyResetCode(otp: '7542')),
    );
    expect(cubit.events.whereType<VerifyResetCode>().length, 1);
  });

  testWidgets('an incomplete code shows the inline error and emits nothing', (
    tester,
  ) async {
    await pumpOtpStep(tester);

    await typeCode(tester, '12');
    await tester.tap(find.byKey(confirmKey));
    await settle(tester);

    expect(
      find.text('Please enter the complete verification code.'),
      findsOneWidget,
    );
    expect(cubit.events, isEmpty);
  });

  testWidgets('a valid code clears the previous inline error', (
    tester,
  ) async {
    await pumpOtpStep(tester);

    await typeCode(tester, '12');
    await tester.tap(find.byKey(confirmKey));
    await settle(tester);
    expect(
      find.text('Please enter the complete verification code.'),
      findsOneWidget,
    );

    await typeCode(tester, '7542');
    await settle(tester);

    expect(
      find.text('Please enter the complete verification code.'),
      findsNothing,
    );
    expect(
      cubit.events,
      contains(const VerifyResetCode(otp: '7542')),
    );
  });

  testWidgets('tapping resend emits ResendResetCode once', (tester) async {
    await pumpOtpStep(tester);

    await tester.tap(find.byKey(resendKey));
    await settle(tester);

    expect(cubit.events, contains(const ResendResetCode()));
    expect(cubit.events.whereType<ResendResetCode>().length, 1);
  });

  testWidgets('during the countdown the resend label counts down and blocks', (
    tester,
  ) async {
    await pumpOtpStep(
      tester,
      state: const ForgetPasswordState(
        step: ForgetPasswordStep.otp,
        email: 'user@mail.com',
        resendSecondsLeft: 17,
      ),
    );

    expect(find.text('Resend in 17s'), findsOneWidget);
    expect(find.text('Resend Code?'), findsNothing);

    await tester.tap(find.text('Resend in 17s'));
    await settle(tester);

    expect(cubit.events.whereType<ResendResetCode>(), isEmpty);
  });

  testWidgets('while resending a spinner shows and confirm stays usable', (
    tester,
  ) async {
    await pumpOtpStep(
      tester,
      state: const ForgetPasswordState(
        step: ForgetPasswordStep.otp,
        email: 'user@mail.com',
        resendCode: Resource<AuthActionResult>.loading(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(
      tester.widget<ElevatedButton>(find.byKey(confirmKey)).onPressed,
      isNotNull,
    );
  });

  testWidgets('while verifying the field locks and confirm spins', (
    tester,
  ) async {
    await pumpOtpStep(
      tester,
      state: const ForgetPasswordState(
        step: ForgetPasswordStep.otp,
        email: 'user@mail.com',
        verifyCode: Resource<AuthActionResult>.loading(),
      ),
    );

    expect(tester.widget<Pinput>(find.byType(Pinput)).enabled, isFalse);
    expect(
      tester.widget<ElevatedButton>(find.byKey(confirmKey)).onPressed,
      isNull,
    );
    expect(
      find.descendant(
        of: find.byKey(confirmKey),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    expect(find.text('Confirm'), findsNothing);
  });

  testWidgets('tapping confirm with a full code submits the code', (
    tester,
  ) async {
    await pumpOtpStep(tester);

    await typeCode(tester, '7542');
    await tester.tap(find.byKey(confirmKey));
    await settle(tester);

    expect(
      cubit.events.whereType<VerifyResetCode>().first.otp,
      '7542',
    );
  });
}
