import 'dart:async';

import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/features/profile/domain/entities/change_password_entity.dart';
import 'package:fitness_app/features/profile/presentation/change_password/view/view_model/change_password_cubit.dart';
import 'package:fitness_app/features/profile/presentation/change_password/view/view_model/change_password_field.dart';
import 'package:fitness_app/features/profile/presentation/change_password/view/view_model/change_password_intent.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../profile_test_helper.dart';

void main() {
  late MockChangePasswordUseCase mockChangePasswordUseCase;
  late ChangePasswordCubit cubit;

  const currentPassword = 'OldPassword123!';
  const newPassword = 'NewPassword123!';

  setUpAll(registerProfileFallbacks);

  setUp(() {
    mockChangePasswordUseCase = MockChangePasswordUseCase();
    cubit = ChangePasswordCubit(mockChangePasswordUseCase);
  });

  tearDown(() async {
    await cubit.close();
  });

  void updateField(ChangePasswordField field, String value) {
    cubit.doIntent(UpdatePasswordFieldIntent(field, value));
  }

  void enterValidPasswords() {
    updateField(ChangePasswordField.currentPassword, currentPassword);
    updateField(ChangePasswordField.newPassword, newPassword);
    updateField(ChangePasswordField.confirmPassword, newPassword);
  }

  group('Initial state', () {
    test('should have empty password fields and initial resource', () {
      expect(cubit.state.currentPassword, isEmpty);
      expect(cubit.state.newPassword, isEmpty);
      expect(cubit.state.confirmPassword, isEmpty);
      expect(cubit.state.fieldErrors, isEmpty);
      expect(cubit.state.isChanging, isFalse);
    });
  });

  group('UpdatePasswordFieldIntent', () {
    test('should update current password only', () {
      updateField(ChangePasswordField.currentPassword, currentPassword);

      expect(cubit.state.currentPassword, currentPassword);
      expect(cubit.state.newPassword, isEmpty);
      expect(cubit.state.confirmPassword, isEmpty);
    });

    test('should update new password only', () {
      updateField(ChangePasswordField.newPassword, newPassword);

      expect(cubit.state.currentPassword, isEmpty);
      expect(cubit.state.newPassword, newPassword);
      expect(cubit.state.confirmPassword, isEmpty);
    });

    test('should update confirm password only', () {
      updateField(ChangePasswordField.confirmPassword, newPassword);

      expect(cubit.state.currentPassword, isEmpty);
      expect(cubit.state.newPassword, isEmpty);
      expect(cubit.state.confirmPassword, newPassword);
    });

    test('should clear only the updated field validation error', () {
      cubit.doIntent(const SubmitChangePasswordIntent());

      final previousErrors = Map<ChangePasswordField, dynamic>.from(
        cubit.state.fieldErrors,
      );

      expect(
        previousErrors.containsKey(ChangePasswordField.currentPassword),
        isTrue,
      );

      updateField(ChangePasswordField.currentPassword, currentPassword);

      expect(cubit.state.errorOf(ChangePasswordField.currentPassword), isNull);

      for (final field in ChangePasswordField.values) {
        if (field == ChangePasswordField.currentPassword) continue;

        expect(cubit.state.errorOf(field), previousErrors[field]);
      }

      verifyNever(
        () => mockChangePasswordUseCase(
          password: any(named: 'password'),
          newPassword: any(named: 'newPassword'),
        ),
      );
    });
  });

  group('SubmitChangePasswordIntent', () {
    test('should not call use case when validation fails', () {
      cubit.doIntent(const SubmitChangePasswordIntent());

      expect(cubit.state.fieldErrors, isNotEmpty);
      expect(cubit.state.isChanging, isFalse);

      verifyNever(
        () => mockChangePasswordUseCase(
          password: any(named: 'password'),
          newPassword: any(named: 'newPassword'),
        ),
      );
    });

    test('should call use case with correct passwords on success', () async {
      when(
        () => mockChangePasswordUseCase(
          password: currentPassword,
          newPassword: newPassword,
        ),
      ).thenAnswer(
        (_) async =>
            SuccessResponse<ChangePasswordEntity>(testChangePasswordEntity),
      );

      enterValidPasswords();

      cubit.doIntent(const SubmitChangePasswordIntent());

      expect(cubit.state.isChanging, isTrue);

      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.isChanging, isFalse);

      verify(
        () => mockChangePasswordUseCase(
          password: currentPassword,
          newPassword: newPassword,
        ),
      ).called(1);
    });

   
    test('should not call use case again while request is loading', () async {
      final completer = Completer<BaseResponse<ChangePasswordEntity>>();

      when(
        () => mockChangePasswordUseCase(
          password: currentPassword,
          newPassword: newPassword,
        ),
      ).thenAnswer((_) => completer.future);

      enterValidPasswords();

      cubit.doIntent(const SubmitChangePasswordIntent());

      expect(cubit.state.isChanging, isTrue);

      // Try submitting again while the first request is still pending.
      cubit.doIntent(const SubmitChangePasswordIntent());

      verify(
        () => mockChangePasswordUseCase(
          password: currentPassword,
          newPassword: newPassword,
        ),
      ).called(1);

      completer.complete(
        SuccessResponse<ChangePasswordEntity>(testChangePasswordEntity),
      );

      await Future<void>.delayed(Duration.zero);

      expect(cubit.state.isChanging, isFalse);
    });
  });
}
