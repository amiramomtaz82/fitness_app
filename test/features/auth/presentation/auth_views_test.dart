import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view/forget_pasword_view.dart';
import 'package:fitness_app/features/auth/presentation/login/view/login_view.dart';
import 'package:fitness_app/features/auth/presentation/register/view/register_first_sceen/register_view.dart';

void main() {
  group('Auth Views Smoke Tests', () {
    testWidgets('LoginView renders properly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: LoginView()));
      expect(find.byType(LoginView), findsOneWidget);
    });

    testWidgets('RegisterView renders properly', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: RegisterView()));
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
