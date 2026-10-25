import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/di/di.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view/forget_pasword_view.dart';
import 'package:fitness_app/features/auth/presentation/login/view/login_view.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_cubit.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_state.dart';
import 'package:fitness_app/features/auth/presentation/register/view/register_first_sceen/register_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterCubit extends MockCubit<RegisterState>
    implements RegisterCubit {}

void main() {
  group('Auth Views Smoke Tests', () {
    late MockRegisterCubit mockRegisterCubit;

    setUp(() {
      mockRegisterCubit = MockRegisterCubit();
      when(() => mockRegisterCubit.state).thenReturn(const RegisterState());
      when(
        () => mockRegisterCubit.eventStream,
      ).thenAnswer((_) => const Stream.empty());

      if (getIt.isRegistered<RegisterCubit>()) {
        getIt.unregister<RegisterCubit>();
      }
      getIt.registerFactory<RegisterCubit>(() => mockRegisterCubit);
    });

    tearDown(() {
      if (getIt.isRegistered<RegisterCubit>()) {
        getIt.unregister<RegisterCubit>();
      }
    });

    testWidgets('LoginView renders properly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginView()));
      expect(find.byType(LoginView), findsOneWidget);
    });

    testWidgets('RegisterView renders properly', (WidgetTester tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(375, 812),
          builder: (context, child) => const MaterialApp(home: RegisterView()),
        ),
      );
      expect(find.byType(RegisterView), findsOneWidget);
    });

    testWidgets('ForgetPaswordView renders properly', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: ForgetPaswordView()));
      expect(find.byType(ForgetPaswordView), findsOneWidget);
    });
  });
}
