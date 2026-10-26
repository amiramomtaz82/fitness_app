import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/app/go_routes/routes_names.dart';
import 'package:fitness_app/core/theme/app_theme.dart';
import 'package:fitness_app/core/widgets/app_background_scaffold.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/auth_action_result.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/forget_password_request.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/reset_password_request.dart';
import 'package:fitness_app/features/auth/domain/entities/forget_password/verify_otp_request.dart';
import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';
import 'package:fitness_app/features/auth/domain/repo/auth_repo.dart';
import 'package:fitness_app/features/auth/domain/use_cases/reset_password_use_case.dart';
import 'package:fitness_app/features/auth/domain/use_cases/send_reset_code_use_case.dart';
import 'package:fitness_app/features/auth/domain/use_cases/verify_reset_code_use_case.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view/forget_password_view.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view_model/forget_password_cubit.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view_model/forget_password_event.dart';
import 'package:fitness_app/features/auth/presentation/forget_password/view_model/forget_password_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

class _NoRepo implements AuthRepo {
  const _NoRepo();

  Never _called() {
    throw UnsupportedError('Widget tests must not reach the use cases.');
  }

  @override
  Future<String?> getToken() => _called();

  @override
  Future<bool> isLoggedIn() => _called();

  @override
  Future<UserEntity?> getSavedUser() => _called();

  @override
  Future<void> logout() => _called();

  @override
  Future<BaseResponse<AuthActionResult>> sendResetCode(
    ForgetPasswordRequest request,
  ) => _called();

  @override
  Future<BaseResponse<AuthActionResult>> verifyResetCode(
    VerifyOtpRequest request,
  ) => _called();

  @override
  Future<BaseResponse<AuthActionResult>> resetPassword(
    ResetPasswordRequest request,
  ) => _called();
}

class _StubSendResetCodeUseCase extends SendResetCodeUseCase {
  const _StubSendResetCodeUseCase() : super(const _NoRepo());

  @override
  Future<BaseResponse<AuthActionResult>> call({
    required ForgetPasswordRequest request,
  }) => throw UnsupportedError('Widget tests must not reach the use cases.');
}

class _StubVerifyResetCodeUseCase extends VerifyResetCodeUseCase {
  const _StubVerifyResetCodeUseCase() : super(const _NoRepo());

  @override
  Future<BaseResponse<AuthActionResult>> call({
    required VerifyOtpRequest request,
  }) => throw UnsupportedError('Widget tests must not reach the use cases.');
}

class _StubResetPasswordUseCase extends ResetPasswordUseCase {
  const _StubResetPasswordUseCase() : super(const _NoRepo());

  @override
  Future<BaseResponse<AuthActionResult>> call({
    required ResetPasswordRequest request,
  }) => throw UnsupportedError('Widget tests must not reach the use cases.');
}

class FakeForgetPasswordCubit extends ForgetPasswordCubit {
  final List<ForgetPasswordEvent> events = [];

  FakeForgetPasswordCubit()
    : super(
        const _StubSendResetCodeUseCase(),
        const _StubVerifyResetCodeUseCase(),
        const _StubResetPasswordUseCase(),
      );

  @override
  void onEvent(ForgetPasswordEvent event) => events.add(event);

  void setState(ForgetPasswordState state) => emit(state);
}

Future<void> pumpForgetPassword(
  WidgetTester tester, {
  required ForgetPasswordCubit cubit,
  void Function(BuildContext context)? onBuild,
}) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(_wrap(cubit: cubit, onBuild: onBuild));
    for (
      var i = 0;
      i < 20 && find.byType(AppBackgroundScaffold).evaluate().isEmpty;
      i++
    ) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 300));
  });

  expect(find.byType(AppBackgroundScaffold), findsOneWidget);
  expect(find.byType(Image), findsWidgets);
}

Future<void> pumpBareWidget(WidgetTester tester, Widget widget) async {
  await tester.runAsync(() async {
    await tester.pumpWidget(
      EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('ar')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        startLocale: const Locale('en'),
        saveLocale: false,
        child: ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          child: Builder(
            builder: (context) => MaterialApp(
              theme: AppTheme.darkTheme,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
              home: Scaffold(
                body: SingleChildScrollView(child: widget),
              ),
            ),
          ),
        ),
      ),
    );
    for (var i = 0; i < 6; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    await tester.pump(const Duration(milliseconds: 300));
  });
}

Future<void> settle(WidgetTester tester) async {
  for (var i = 0; i < 5; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

bool fieldObscured(WidgetTester tester, Key key) {
  return tester
      .widget<EditableText>(
        find.descendant(
          of: find.byKey(key),
          matching: find.byType(EditableText),
        ),
      )
      .obscureText;
}

Widget _wrap({
  required ForgetPasswordCubit cubit,
  void Function(BuildContext context)? onBuild,
}) {
  return EasyLocalization(
    supportedLocales: const [Locale('en'), Locale('ar')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    saveLocale: false,
    child: ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      child: Builder(
        builder: (context) => MaterialApp.router(
          theme: AppTheme.darkTheme,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          routerConfig: GoRouter(
            initialLocation: AppRoutes.forgotPassword,
            routes: [
              GoRoute(
                path: AppRoutes.forgotPassword,
                builder: (context, state) => Builder(
                  builder: (inner) {
                    onBuild?.call(inner);
                    return ForgetPasswordView(cubit: cubit);
                  },
                ),
              ),
              GoRoute(
                path: AppRoutes.login,
                builder: (context, state) => const Scaffold(
                  body: Center(child: Text('LOGIN_PAGE_MARKER')),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
