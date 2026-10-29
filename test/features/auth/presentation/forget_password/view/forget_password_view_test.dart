import 'package:fitness_app/core/base/cubit_message.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/app/routes_names.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view_model/forget_password_event.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view_model/forget_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../forget_password_widget_test_helpers.dart';

void main() {
  late FakeForgetPasswordCubit cubit;

  setUp(() => cubit = FakeForgetPasswordCubit());
  tearDown(() => cubit.close());

  group('ForgetPasswordView', () {
    testWidgets('starts on the email step with the logo chrome', (
      tester,
    ) async {
      await pumpForgetPassword(tester, cubit: cubit);

      expect(find.byKey(const Key('emailField')), findsOneWidget);
      expect(find.byKey(const Key('backButton')), findsOneWidget);
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('switching state to otp swaps the rendered step', (
      tester,
    ) async {
      await pumpForgetPassword(tester, cubit: cubit);

      cubit.setState(const ForgetPasswordState(step: ForgetPasswordStep.otp));
      await settle(tester);

      expect(find.byKey(const Key('emailField')), findsNothing);
      expect(find.byKey(const Key('otpField')), findsOneWidget);
    });

    testWidgets('switching state to resetPassword swaps the rendered step', (
      tester,
    ) async {
      await pumpForgetPassword(tester, cubit: cubit);

      cubit.setState(
        const ForgetPasswordState(step: ForgetPasswordStep.resetPassword),
      );
      await settle(tester);

      expect(find.byKey(const Key('emailField')), findsNothing);
      expect(find.byKey(const Key('passwordField')), findsOneWidget);
      expect(find.byKey(const Key('confirmPasswordField')), findsOneWidget);
    });

    testWidgets('back button on a later step emits GoToPreviousStep', (
      tester,
    ) async {
      cubit.setState(const ForgetPasswordState(step: ForgetPasswordStep.otp));
      await pumpForgetPassword(tester, cubit: cubit);

      await tester.tap(find.byKey(const Key('backButton')));
      await tester.pump();

      expect(cubit.events, contains(const GoToPreviousStep()));
    });

    testWidgets('the back button is anchored left of the logo, not centered', (
      tester,
    ) async {
      await pumpForgetPassword(tester, cubit: cubit);

      final backButton = find.byKey(const Key('backButton'));
      final logo = find.byType(Image).first;

      final backCenter = tester.getCenter(backButton);
      final logoCenter = tester.getCenter(logo);

      expect(backCenter.dx, lessThan(logoCenter.dx));
      expect(backCenter.dx, lessThan(60));

      await tester.tap(backButton);
      expect(tester.takeException(), isNull);
    });

    testWidgets('back on the email step with nothing to pop goes to login', (
      tester,
    ) async {
      await pumpForgetPassword(tester, cubit: cubit);

      await tester.tap(find.byKey(const Key('backButton')));
      await settle(tester);
      await settle(tester);

      expect(find.text('LOGIN_PAGE_MARKER'), findsOneWidget);
      expect(cubit.events, isEmpty);
    });

    testWidgets('a failure from the cubit surfaces as an error snackbar', (
      tester,
    ) async {
      await pumpForgetPassword(tester, cubit: cubit);

      cubit.emitFailure(const NetworkFailure(serverMessage: 'no internet'));
      await settle(tester);

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('no internet'), findsOneWidget);
    });

    testWidgets('a success message from the cubit surfaces as a snackbar', (
      tester,
    ) async {
      await pumpForgetPassword(tester, cubit: cubit);

      cubit.emitSuccess(CubitMessageType.otpSent);
      await settle(tester);

      expect(find.byType(SnackBar), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SnackBar),
          matching: find.text('Sent OTP'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('navigates to login when the cubit emits the nav event', (
      tester,
    ) async {
      await pumpForgetPassword(tester, cubit: cubit);

      cubit.emitEvent(const NavigateReplacementEvent(AppRoutes.login));
      await settle(tester);
      await settle(tester);

      expect(find.text('LOGIN_PAGE_MARKER'), findsOneWidget);
      expect(find.byKey(const Key('emailField')), findsNothing);
    });
  });
}
