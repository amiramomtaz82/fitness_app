import 'package:fitness_app/features/auth/presentation/forget_password/view_model/forget_password_event.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SendResetCode', () {
    test('equality is driven by the email', () {
      const a = SendResetCode(email: 'user@mail.com');
      const b = SendResetCode(email: 'user@mail.com');
      const c = SendResetCode(email: 'other@mail.com');
      expect(a, b);
      expect(a.hashCode, b.hashCode);
      expect(a, isNot(c));
    });
  });

  group('VerifyResetCode', () {
    test('equality is driven by the otp', () {
      const a = VerifyResetCode(otp: '7542');
      const b = VerifyResetCode(otp: '7542');
      const c = VerifyResetCode(otp: '0000');
      expect(a, b);
      expect(a, isNot(c));
    });
  });

  group('SubmitNewPassword', () {
    test('equality is driven by both passwords', () {
      const a = SubmitNewPassword(
        password: 'NewPass1',
        confirmPassword: 'NewPass1',
      );
      const b = SubmitNewPassword(
        password: 'NewPass1',
        confirmPassword: 'NewPass1',
      );
      const c = SubmitNewPassword(
        password: 'NewPass1',
        confirmPassword: 'OtherPass1',
      );
      expect(a, b);
      expect(a, isNot(c));
    });
  });

  group('Parameterless events', () {
    test('resend events are equal to each other', () {
      expect(const ResendResetCode(), const ResendResetCode());
    });

    test('back events are equal to each other', () {
      expect(const GoToPreviousStep(), const GoToPreviousStep());
    });

    test('different event types are never equal', () {
      expect(
        const ResendResetCode() as ForgetPasswordEvent,
        isNot(const GoToPreviousStep()),
      );
    });
  });
}
