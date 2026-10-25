import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/di/di.dart';
import 'package:fitness_app/core/go_routes/routes_names.dart';
import 'package:fitness_app/features/auth/domain/entities/email_provider_status.dart';
import 'package:fitness_app/features/auth/domain/entities/register_parameters.dart';
import 'package:fitness_app/features/auth/domain/entities/social_auth_user.dart';
import 'package:fitness_app/features/auth/domain/use_cases/get_provider_password_use_case.dart';
import 'package:fitness_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:fitness_app/features/auth/domain/use_cases/sign_in_with_facebook_use_case.dart';
import 'package:fitness_app/features/auth/domain/use_cases/sign_in_with_google_use_case.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_cubit.dart';
import 'package:fitness_app/features/auth/presentation/register/view/register_first_sceen/register_view.dart';
import 'package:fitness_app/features/auth/presentation/register/view/register_first_sceen/widgets/register_card.dart';
import 'package:fitness_app/features/auth/presentation/register/view/register_first_sceen/widgets/register_footer.dart';
import 'package:fitness_app/features/auth/presentation/register/view/register_first_sceen/widgets/register_header.dart';
import 'package:fitness_app/features/auth/presentation/register/view/register_first_sceen/widgets/register_input_field.dart';
import 'package:fitness_app/features/auth/presentation/register/view/register_first_sceen/widgets/register_next_button.dart';
import 'package:fitness_app/features/auth/presentation/register/view/register_first_sceen/widgets/register_social_buttons.dart';
import 'package:fitness_app/features/auth/presentation/register/view/register_first_sceen/widgets/social_button.dart';
import 'package:fitness_app/generated/locale_keys.g.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockSignInWithGoogleUseCase extends Mock
    implements SignInWithGoogleUseCase {}

class MockGetProviderPasswordUseCase extends Mock
    implements GetProviderPasswordUseCase {}

class MockSignInWithFacebookUseCase extends Mock
    implements SignInWithFacebookUseCase {}

class InMemoryAssetLoader extends AssetLoader {
  final Map<String, dynamic> data;
  const InMemoryAssetLoader(this.data);

  @override
  Future<Map<String, dynamic>> load(String path, Locale locale) async {
    return data;
  }
}

late Map<String, dynamic> enTranslations;

Widget createTestApp({required GoRouter router}) {
  return EasyLocalization(
    key: UniqueKey(),
    supportedLocales: const [Locale('en')],
    path: 'assets/translations',
    fallbackLocale: const Locale('en'),
    startLocale: const Locale('en'),
    saveLocale: false,
    useOnlyLangCode: true,
    assetLoader: InMemoryAssetLoader(enTranslations),
    child: Builder(
      builder: (context) {
        return ScreenUtilInit(
          designSize: const Size(375, 812),
          minTextAdapt: true,
          splitScreenMode: true,
          builder: (context, child) {
            return MaterialApp.router(
              routerConfig: router,
              localizationsDelegates: context.localizationDelegates,
              supportedLocales: context.supportedLocales,
              locale: context.locale,
            );
          },
        );
      },
    ),
  );
}

void main() {
  late MockRegisterUseCase mockRegisterUseCase;
  late MockSignInWithGoogleUseCase mockSignInWithGoogleUseCase;
  late MockGetProviderPasswordUseCase mockGetProviderPasswordUseCase;
  late MockSignInWithFacebookUseCase mockSignInWithFacebookUseCase;
  late RegisterCubit registerCubit;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});
    enTranslations =
        jsonDecode(File('assets/translations/en.json').readAsStringSync())
            as Map<String, dynamic>;
    await EasyLocalization.ensureInitialized();
    registerFallbackValue(const RegisterParameters());
    registerFallbackValue(EmailProviderStatus.registeredWithGoogle);
  });

  setUp(() {
    mockRegisterUseCase = MockRegisterUseCase();
    mockSignInWithGoogleUseCase = MockSignInWithGoogleUseCase();
    mockGetProviderPasswordUseCase = MockGetProviderPasswordUseCase();
    mockSignInWithFacebookUseCase = MockSignInWithFacebookUseCase();
    registerCubit = RegisterCubit(
      mockRegisterUseCase,
      mockSignInWithGoogleUseCase,
      mockGetProviderPasswordUseCase,
      mockSignInWithFacebookUseCase,
    );

    if (getIt.isRegistered<RegisterCubit>()) {
      getIt.unregister<RegisterCubit>();
    }
    getIt.registerFactory<RegisterCubit>(() => registerCubit);
  });

  tearDown(() {
    if (getIt.isRegistered<RegisterCubit>()) {
      getIt.unregister<RegisterCubit>();
    }
    registerCubit.close();
  });

  GoRouter createRouter() {
    return GoRouter(
      initialLocation: AppRoutes.register,
      routes: [
        GoRoute(
          path: AppRoutes.register,
          builder: (context, state) => const RegisterView(),
        ),
        GoRoute(
          path: AppRoutes.multiStepRegistration,
          builder: (context, state) =>
              const Scaffold(body: Text('Multi-Step Screen Destination')),
        ),
        GoRoute(
          path: AppRoutes.login,
          builder: (context, state) =>
              const Scaffold(body: Text('Login Screen Destination')),
        ),
      ],
    );
  }

  Future<void> pumpRegisterView(WidgetTester tester, GoRouter router) async {
    tester.view.physicalSize = const Size(375 * 3, 812 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(createTestApp(router: router));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpAndSettle();
  }

  group('RegisterView Widget Tests', () {
    testWidgets('renders all core UI widgets and fields properly', (
      tester,
    ) async {
      final router = createRouter();
      await pumpRegisterView(tester, router);

      // Core widgets
      expect(find.byType(RegisterView), findsOneWidget);
      expect(find.byType(RegisterHeader), findsOneWidget);
      expect(find.byType(RegisterCard), findsOneWidget);
      expect(find.byType(RegisterSocialButtons), findsOneWidget);
      expect(find.byType(SocialButton), findsNWidgets(3));
      expect(find.byType(RegisterNextButton), findsOneWidget);
      expect(find.byType(RegisterFooter), findsOneWidget);

      // 4 input fields
      expect(find.byType(RegisterInputField), findsNWidgets(4));
      expect(find.byType(TextFormField), findsNWidgets(4));

      // Header texts
      expect(find.text(LocaleKeys.auth_hey_there.tr()), findsOneWidget);
      expect(find.text(LocaleKeys.auth_create_an_account.tr()), findsOneWidget);

      // Card title & Next button
      expect(find.text(LocaleKeys.auth_register.tr()), findsOneWidget);
      expect(find.text(LocaleKeys.common_next.tr()), findsOneWidget);
    });

    testWidgets(
      'shows validation errors when Next button is pressed with empty fields',
      (tester) async {
        final router = createRouter();
        await pumpRegisterView(tester, router);

        // Scroll to Next button and tap it
        final nextButtonFinder = find.byType(RegisterNextButton);
        await tester.ensureVisible(nextButtonFinder);
        await tester.tap(nextButtonFinder);
        await tester.pumpAndSettle();

        // Field is required error message should appear for empty fields
        final requiredError = LocaleKeys.validation_field_required.tr();
        expect(find.text(requiredError), findsNWidgets(4));

        // Ensure navigation to next screen did NOT happen
        expect(find.text('Multi-Step Screen Destination'), findsNothing);
      },
    );

    testWidgets('shows validation error when an invalid email is entered', (
      tester,
    ) async {
      final router = createRouter();
      await pumpRegisterView(tester, router);

      final textFields = find.byType(TextFormField);
      await tester.enterText(textFields.at(0), 'Ahmed');
      await tester.enterText(textFields.at(1), 'Ali');
      await tester.enterText(textFields.at(2), 'invalid-email');
      await tester.enterText(textFields.at(3), 'Password@123');

      final nextButtonFinder = find.byType(RegisterNextButton);
      await tester.ensureVisible(nextButtonFinder);
      await tester.tap(nextButtonFinder);
      await tester.pumpAndSettle();

      expect(
        find.text(LocaleKeys.validation_invalid_email.tr()),
        findsOneWidget,
      );
      expect(find.text('Multi-Step Screen Destination'), findsNothing);
    });

    testWidgets(
      'shows validation error when password is too short or missing uppercase/number',
      (tester) async {
        final router = createRouter();
        await pumpRegisterView(tester, router);

        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), 'Ahmed');
        await tester.enterText(textFields.at(1), 'Ali');
        await tester.enterText(textFields.at(2), 'ahmed@example.com');
        await tester.enterText(textFields.at(3), '123'); // too short

        final nextButtonFinder = find.byType(RegisterNextButton);
        await tester.ensureVisible(nextButtonFinder);
        await tester.tap(nextButtonFinder);
        await tester.pumpAndSettle();

        expect(
          find.text(LocaleKeys.validation_password_too_short.tr()),
          findsOneWidget,
        );
        expect(find.text('Multi-Step Screen Destination'), findsNothing);
      },
    );

    testWidgets('toggles password visibility when visibility icon is pressed', (
      tester,
    ) async {
      final router = createRouter();
      await pumpRegisterView(tester, router);

      // Initially password is obscured
      expect(registerCubit.state.isPasswordObscured, isTrue);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_outlined), findsNothing);

      // Tap password obscure toggle icon
      final toggleIconFinder = find.byIcon(Icons.visibility_off_outlined);
      await tester.tap(toggleIconFinder);
      await tester.pumpAndSettle();

      // Password should now be revealed
      expect(registerCubit.state.isPasswordObscured, isFalse);
      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);
      expect(find.byIcon(Icons.visibility_off_outlined), findsNothing);

      // Tap again to obscure
      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pumpAndSettle();

      expect(registerCubit.state.isPasswordObscured, isTrue);
      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets(
      'submits account credentials to cubit and navigates to multiStepRegistration on valid input',
      (tester) async {
        final router = createRouter();
        await pumpRegisterView(tester, router);

        final textFields = find.byType(TextFormField);
        await tester.enterText(textFields.at(0), 'Ahmed');
        await tester.enterText(textFields.at(1), 'Ali');
        await tester.enterText(textFields.at(2), 'ahmed@example.com');
        await tester.enterText(textFields.at(3), 'Password@123');

        final nextButtonFinder = find.byType(RegisterNextButton);
        await tester.ensureVisible(nextButtonFinder);
        await tester.tap(nextButtonFinder);
        await tester.pumpAndSettle();

        // Check that cubit state was updated with credentials
        expect(registerCubit.state.params.firstName, equals('Ahmed'));
        expect(registerCubit.state.params.lastName, equals('Ali'));
        expect(registerCubit.state.params.email, equals('ahmed@example.com'));
        expect(registerCubit.state.params.password, equals('Password@123'));

        // Check navigation occurred
        expect(find.text('Multi-Step Screen Destination'), findsOneWidget);
        expect(find.byType(RegisterView), findsNothing);
      },
    );

    testWidgets('navigates to login screen when footer login link is tapped', (
      tester,
    ) async {
      final router = createRouter();
      await pumpRegisterView(tester, router);

      final loginLinkFinder = find.text(LocaleKeys.auth_login.tr());
      await tester.ensureVisible(loginLinkFinder);
      await tester.tap(loginLinkFinder);
      await tester.pumpAndSettle();

      expect(find.text('Login Screen Destination'), findsOneWidget);
      expect(find.byType(RegisterView), findsNothing);
    });

    testWidgets(
      'triggers Google sign-in and navigates when Google button is tapped',
      (tester) async {
        when(() => mockSignInWithGoogleUseCase()).thenAnswer(
          (_) async => const SuccessResponse(
            SocialAuthUser(
              email: 'googleuser@gmail.com',
              firstName: 'Google',
              lastName: 'User',
              provider: 'google',
            ),
          ),
        );
        when(
          () => mockGetProviderPasswordUseCase(
            EmailProviderStatus.registeredWithGoogle,
          ),
        ).thenAnswer(
          (_) async => const SuccessResponse('GoogleAuth@ElevateFitness2026#'),
        );

        final router = createRouter();
        await pumpRegisterView(tester, router);

        final socialButtons = find.byType(SocialButton);
        expect(socialButtons, findsNWidgets(3));

        await tester.ensureVisible(socialButtons.at(1));
        await tester.tap(socialButtons.at(1));
        await tester.pumpAndSettle();

        verify(() => mockSignInWithGoogleUseCase()).called(1);
        expect(
          registerCubit.state.params.email,
          equals('googleuser@gmail.com'),
        );
        expect(registerCubit.state.params.firstName, equals('Google'));

        expect(find.text('Multi-Step Screen Destination'), findsOneWidget);
      },
    );
  });
}
