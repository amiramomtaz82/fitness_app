import 'package:fake_async/fake_async.dart';
import 'package:fitness_app/core/base/cubit_message.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/app/routes_names.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/auth_action_result.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/forget_password_request.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/reset_password_request.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/verify_otp_request.dart';
import 'package:fitness_app/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:fitness_app/features/auth/domain/use_cases/send_reset_code_use_case.dart';
import 'package:fitness_app/features/auth/domain/use_cases/verify_reset_code_use_case.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view_model/forget_password_config.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view_model/forget_password_cubit.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view_model/forget_password_event.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view_model/forget_password_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'forget_password_cubit_test.mocks.dart';

@GenerateMocks([
  SendResetCodeUseCase,
  VerifyResetCodeUseCase,
  ResetPasswordUseCase,
])
void main() {
  const success = AuthActionResult(success: true);
  const networkFailure = NetworkFailure(serverMessage: 'no internet');

  setUpAll(() {
    provideDummy<BaseResponse<AuthActionResult>>(
      const SuccessResponse<AuthActionResult>(success),
    );
  });

  late MockSendResetCodeUseCase sendUseCase;
  late MockVerifyResetCodeUseCase verifyUseCase;
  late MockResetPasswordUseCase resetUseCase;
  late ForgetPasswordCubit cubit;

  setUp(() {
    sendUseCase = MockSendResetCodeUseCase();
    verifyUseCase = MockVerifyResetCodeUseCase();
    resetUseCase = MockResetPasswordUseCase();
    cubit = ForgetPasswordCubit(sendUseCase, verifyUseCase, resetUseCase);
  });

  tearDown(() async {
    await cubit.close();
  });

  void stubSendSuccess() => when(
    sendUseCase(request: anyNamed('request')),
  ).thenAnswer((_) async => const SuccessResponse(success));

  void stubSendFailure() =>
      when(sendUseCase(request: anyNamed('request'))).thenAnswer(
        (_) async => ErrorResponse<AuthActionResult>(failure: networkFailure),
      );

  void stubVerifySuccess() => when(
    verifyUseCase(request: anyNamed('request')),
  ).thenAnswer((_) async => const SuccessResponse(success));

  void stubVerifyFailure() =>
      when(verifyUseCase(request: anyNamed('request'))).thenAnswer(
        (_) async => ErrorResponse<AuthActionResult>(failure: networkFailure),
      );

  void stubResetSuccess() => when(
    resetUseCase(request: anyNamed('request')),
  ).thenAnswer((_) async => const SuccessResponse(success));

  group('ForgetPasswordCubit - initial state', () {
    test('starts on the email step with every action resource initial', () {
      expect(cubit.state.step, ForgetPasswordStep.email);
      expect(cubit.state.email, isEmpty);
      expect(cubit.state.sendCode.isInitial, isTrue);
      expect(cubit.state.verifyCode.isInitial, isTrue);
      expect(cubit.state.resendCode.isInitial, isTrue);
      expect(cubit.state.resetPassword.isInitial, isTrue);
      expect(cubit.state.resendSecondsLeft, 0);
      expect(cubit.state.isFirstStep, isTrue);
    });
  });

  group('ForgetPasswordCubit - send reset code', () {
    test('moves to otp step and emits otpSent on success', () async {
      stubSendSuccess();

      cubit.onEvent(const SendResetCode(email: 'user@mail.com'));
      await Future(() {});

      expect(cubit.state.step, ForgetPasswordStep.otp);
      expect(cubit.state.email, 'user@mail.com');
      expect(cubit.state.sendCode.isSuccess, isTrue);
      verify(
        sendUseCase(
          request: const ForgetPasswordRequest(email: 'user@mail.com'),
        ),
      ).called(1);
    });

    test('emits an error and stays on email step on failure', () async {
      stubSendFailure();

      cubit.onEvent(const SendResetCode(email: 'user@mail.com'));
      await Future(() {});

      expect(cubit.state.step, ForgetPasswordStep.email);
      expect(cubit.state.sendCode.isError, isTrue);
      expect(cubit.state.sendCode.failure, networkFailure);
    });

    test('ignores a second request while a request is in flight', () async {
      when(sendUseCase(request: anyNamed('request'))).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 20));
        return const SuccessResponse(success);
      });

      cubit.onEvent(const SendResetCode(email: 'a@mail.com'));
      cubit.onEvent(const SendResetCode(email: 'b@mail.com'));
      await Future<void>.delayed(const Duration(milliseconds: 60));

      verify(sendUseCase(request: anyNamed('request'))).called(1);
      verifyNever(
        sendUseCase(request: const ForgetPasswordRequest(email: 'b@mail.com')),
      );
    });
  });

  group('ForgetPasswordCubit - verify reset code', () {
    test('moves to resetPassword step on success', () async {
      stubSendSuccess();
      stubVerifySuccess();
      cubit.onEvent(const SendResetCode(email: 'user@mail.com'));
      await Future(() {});

      cubit.onEvent(const VerifyResetCode(otp: '123456'));
      await Future(() {});

      expect(cubit.state.step, ForgetPasswordStep.resetPassword);
      expect(cubit.state.verifyCode.isSuccess, isTrue);
      verify(
        verifyUseCase(request: const VerifyOtpRequest(resetCode: '123456')),
      ).called(1);
    });

    test('stays on otp step and emits error on failure', () async {
      stubSendSuccess();
      stubVerifyFailure();
      cubit.onEvent(const SendResetCode(email: 'user@mail.com'));
      await Future(() {});

      cubit.onEvent(const VerifyResetCode(otp: '000000'));
      await Future(() {});

      expect(cubit.state.step, ForgetPasswordStep.otp);
      expect(cubit.state.verifyCode.isError, isTrue);
    });
  });

  group('ForgetPasswordCubit - reset password', () {
    Future<void> reachResetStep() async {
      stubSendSuccess();
      stubVerifySuccess();
      cubit.onEvent(const SendResetCode(email: 'user@mail.com'));
      await Future(() {});
      cubit.onEvent(const VerifyResetCode(otp: '123456'));
      await Future(() {});
    }

    test('emits passwordChanged and navigates to login on success', () async {
      await reachResetStep();
      stubResetSuccess();

      final emitted = <BaseUiEvent>[];
      final sub = cubit.eventStream.listen(emitted.add);

      cubit.onEvent(
        const SubmitNewPassword(
          password: 'NewPass1',
          confirmPassword: 'NewPass1',
        ),
      );
      await Future(() {});
      await sub.cancel();

      expect(cubit.state.resetPassword.isSuccess, isTrue);
      verify(
        resetUseCase(
          request: const ResetPasswordRequest(
            email: 'user@mail.com',
            newPassword: 'NewPass1',
          ),
        ),
      ).called(1);
      expect(
        emitted.whereType<ShowSuccessSnackBarEvent>().map((e) => e.type),
        contains(CubitMessageType.passwordChanged),
      );
      expect(
        emitted.whereType<NavigateReplacementEvent>().map((e) => e.route),
        contains(AppRoutes.login),
      );
    });

    test('does not call the reset use case when passwords mismatch', () async {
      await reachResetStep();

      cubit.onEvent(
        const SubmitNewPassword(
          password: 'NewPass1',
          confirmPassword: 'Different1',
        ),
      );
      await Future(() {});

      verifyNever(resetUseCase(request: anyNamed('request')));
      expect(cubit.state.resetPassword.isInitial, isTrue);
    });
  });

  group('ForgetPasswordCubit - resend cooldown', () {
    test('a successful send starts the countdown owned by the cubit', () {
      stubSendSuccess();

      fakeAsync((async) {
        cubit.onEvent(const SendResetCode(email: 'user@mail.com'));
        async.flushMicrotasks();

        expect(
          cubit.state.resendSecondsLeft,
          ForgetPasswordConfig.resendCooldown.inSeconds,
        );

        async.elapse(const Duration(seconds: 3));
        expect(
          cubit.state.resendSecondsLeft,
          ForgetPasswordConfig.resendCooldown.inSeconds - 3,
        );
      });
    });

    test(
      'resend shows its own loading and starts the countdown on success',
      () {
        stubSendSuccess();

        fakeAsync((async) {
          cubit.onEvent(const SendResetCode(email: 'user@mail.com'));
          async.flushMicrotasks();
          async.elapse(ForgetPasswordConfig.resendCooldown);
          expect(cubit.state.resendSecondsLeft, 0);
          cubit.onEvent(const ResendResetCode());
          expect(cubit.state.resendCode.isLoading, isTrue);
          expect(cubit.state.verifyCode.isInitial, isTrue);

          async.flushMicrotasks();
          expect(cubit.state.resendCode.isSuccess, isTrue);
          expect(
            cubit.state.resendSecondsLeft,
            ForgetPasswordConfig.resendCooldown.inSeconds,
          );
        });
      },
    );

    test('resend failure leaves no countdown and restores the button', () {
      var sendCalls = 0;
      when(sendUseCase(request: anyNamed('request'))).thenAnswer((_) async {
        sendCalls++;
        return sendCalls == 1
            ? const SuccessResponse(success)
            : ErrorResponse<AuthActionResult>(failure: networkFailure);
      });

      fakeAsync((async) {
        cubit.onEvent(const SendResetCode(email: 'user@mail.com'));
        async.flushMicrotasks();
        async.elapse(ForgetPasswordConfig.resendCooldown);

        cubit.onEvent(const ResendResetCode());
        async.flushMicrotasks();

        expect(cubit.state.resendCode.isError, isTrue);
        expect(cubit.state.resendSecondsLeft, 0);
      });
    });

    test('resend is ignored while the countdown is running', () {
      stubSendSuccess();

      fakeAsync((async) {
        cubit.onEvent(const SendResetCode(email: 'user@mail.com'));
        async.flushMicrotasks();

        cubit.onEvent(const ResendResetCode());
        async.flushMicrotasks();

        verify(sendUseCase(request: anyNamed('request'))).called(1);
      });
    });
  });

  group('ForgetPasswordCubit - step navigation', () {
    test('goToPreviousStep walks back through the flow', () async {
      stubSendSuccess();
      stubVerifySuccess();
      cubit.onEvent(const SendResetCode(email: 'user@mail.com'));
      await Future(() {});
      cubit.onEvent(const VerifyResetCode(otp: '123456'));
      await Future(() {});

      cubit.onEvent(const GoToPreviousStep());
      expect(cubit.state.step, ForgetPasswordStep.otp);

      cubit.onEvent(const GoToPreviousStep());
      expect(cubit.state.step, ForgetPasswordStep.email);
    });
  });
}
