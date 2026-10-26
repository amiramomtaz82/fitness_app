import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/auth_action_result.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view_model/forget_password_state.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const sent = Resource<AuthActionResult>.success(AuthActionResult(success: true));
  const failed = Resource<AuthActionResult>.error(NetworkFailure());

  group('ForgetPasswordState defaults', () {
    test('starts on the email step with empty data', () {
      const state = ForgetPasswordState();
      expect(state.step, ForgetPasswordStep.email);
      expect(state.email, isEmpty);
      expect(state.sendCode.isInitial, isTrue);
      expect(state.verifyCode.isInitial, isTrue);
      expect(state.resendCode.isInitial, isTrue);
      expect(state.resetPassword.isInitial, isTrue);
      expect(state.resendSecondsLeft, 0);
    });
  });

  group('ForgetPasswordState getters', () {
    test('isFirstStep is only true on the email step', () {
      const state = ForgetPasswordState();
      expect(state.isFirstStep, isTrue);
      expect(
        state.copyWith(step: ForgetPasswordStep.otp).isFirstStep,
        isFalse,
      );
      expect(
        state
            .copyWith(step: ForgetPasswordStep.resetPassword)
            .isFirstStep,
        isFalse,
      );
    });

    test('isResendCoolingDown follows the countdown value', () {
      const state = ForgetPasswordState();
      expect(state.isResendCoolingDown, isFalse);
      expect(state.copyWith(resendSecondsLeft: 1).isResendCoolingDown, isTrue);
      expect(
        state.copyWith(resendSecondsLeft: 30).isResendCoolingDown,
        isTrue,
      );
    });
  });

  group('ForgetPasswordState.copyWith', () {
    test('replaces only the provided fields', () {
      const base = ForgetPasswordState(
        step: ForgetPasswordStep.otp,
        email: 'user@mail.com',
        sendCode: sent,
        resendSecondsLeft: 12,
      );

      final next = base.copyWith(verifyCode: failed);

      expect(next.step, base.step);
      expect(next.email, base.email);
      expect(next.sendCode, base.sendCode);
      expect(next.resendSecondsLeft, base.resendSecondsLeft);
      expect(next.verifyCode, failed);
      expect(next.resendCode.isInitial, isTrue);
    });

    test('the countdown can be reset back to zero', () {
      const base = ForgetPasswordState(resendSecondsLeft: 12);
      expect(base.copyWith(resendSecondsLeft: 0).resendSecondsLeft, 0);
    });
  });

  group('ForgetPasswordState equality', () {
    test('states with identical props are equal', () {
      const a = ForgetPasswordState(email: 'user@mail.com');
      const b = ForgetPasswordState(email: 'user@mail.com');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
    });

    test('a changed prop breaks equality', () {
      const a = ForgetPasswordState();
      const b = ForgetPasswordState(step: ForgetPasswordStep.otp);
      expect(a, isNot(b));
    });
  });
}
