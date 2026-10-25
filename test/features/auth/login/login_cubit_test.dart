import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/go_routes/routes_names.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/auth/domain/entities/email_provider_status.dart';
import 'package:fitness_app/features/auth/domain/entities/login_params.dart';
import 'package:fitness_app/features/auth/domain/entities/social_auth_user.dart';
import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';
import 'package:fitness_app/features/auth/domain/use_cases/get_provider_password_use_case.dart';
import 'package:fitness_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:fitness_app/features/auth/domain/use_cases/sign_in_with_facebook_use_case.dart';
import 'package:fitness_app/features/auth/domain/use_cases/sign_in_with_google_use_case.dart';
import 'package:fitness_app/features/auth/presentation/login/view_model/login_cubit.dart';
import 'package:fitness_app/features/auth/presentation/login/view_model/login_intent.dart';
import 'package:fitness_app/features/auth/presentation/login/view_model/login_state.dart';
import 'package:fitness_app/core/base/cubit_message.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockSignInWithGoogleUseCase extends Mock
    implements SignInWithGoogleUseCase {}

class MockSignInWithFacebookUseCase extends Mock
    implements SignInWithFacebookUseCase {}

class MockGetProviderPasswordUseCase extends Mock
    implements GetProviderPasswordUseCase {}

const _googleUser = SocialAuthUser(
  email: 'social@test.com',
  firstName: 'Social',
  lastName: 'User',
  provider: 'google',
);

const _facebookUser = SocialAuthUser(
  email: 'social@test.com',
  firstName: 'Social',
  lastName: 'User',
  provider: 'facebook',
);

const _socialParams = LoginParams(
  email: 'social@test.com',
  password: 'Provider123',
);

const _testUser = UserEntity(id: 'user-id', email: 'test@test.com');

const _submit = LoginSubmittedIntent(
  email: 'test@test.com',
  password: 'Pass1234',
);

const _expectedParams = LoginParams(
  email: 'test@test.com',
  password: 'Pass1234',
);

final _wrongCredentials = ErrorResponse<UserEntity>(
  failure: const UnauthorizedFailure(
    serverMessage: 'incorrect email or password',
  ),
);

void main() {
  late MockLoginUseCase mockUseCase;
  late MockSignInWithGoogleUseCase mockGoogleUseCase;
  late MockSignInWithFacebookUseCase mockFacebookUseCase;
  late MockGetProviderPasswordUseCase mockProviderPasswordUseCase;
  late LoginCubit cubit;

  setUpAll(() {
    registerFallbackValue(const LoginParams(email: '', password: ''));
    registerFallbackValue(EmailProviderStatus.notFound);
  });

  setUp(() {
    mockUseCase = MockLoginUseCase();
    mockGoogleUseCase = MockSignInWithGoogleUseCase();
    mockFacebookUseCase = MockSignInWithFacebookUseCase();
    mockProviderPasswordUseCase = MockGetProviderPasswordUseCase();
    cubit = LoginCubit(
      mockUseCase,
      mockGoogleUseCase,
      mockFacebookUseCase,
      mockProviderPasswordUseCase,
    );
  });

  void givenProviderPassword() {
    when(
      () => mockProviderPasswordUseCase(any()),
    ).thenAnswer((_) async => const SuccessResponse('Provider123'));
  }

  void givenLoginSucceeds() {
    when(
      () => mockUseCase(any()),
    ).thenAnswer((_) async => const SuccessResponse(_testUser));
  }

  tearDown(() => cubit.close());

  group('LoginCubit —', () {
    test('initial state is correct', () {
      expect(cubit.state, const LoginState());
    });

    blocTest<LoginCubit, LoginState>(
      'toggles password visibility on TogglePasswordVisibilityIntent',
      build: () => cubit,
      act: (c) => c
        ..doIntent(const TogglePasswordVisibilityIntent())
        ..doIntent(const TogglePasswordVisibilityIntent()),
      expect: () => [
        const LoginState(isPasswordObscured: false),
        const LoginState(),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'emits loading then success on LoginSubmittedIntent success',
      build: () {
        when(
          () => mockUseCase(any()),
        ).thenAnswer((_) async => const SuccessResponse(_testUser));
        return cubit;
      },
      act: (c) => c.doIntent(_submit),
      expect: () => [
        const LoginState(loginResource: Resource.loading()),
        const LoginState(loginResource: Resource.success(_testUser)),
      ],
      verify: (_) => verify(() => mockUseCase(_expectedParams)).called(1),
    );

    blocTest<LoginCubit, LoginState>(
      'trims leading and trailing whitespace from the email',
      build: () {
        when(
          () => mockUseCase(any()),
        ).thenAnswer((_) async => const SuccessResponse(_testUser));
        return cubit;
      },
      act: (c) => c.doIntent(
        const LoginSubmittedIntent(
          email: '  test@test.com  ',
          password: 'Pass1234',
        ),
      ),
      verify: (_) => verify(() => mockUseCase(_expectedParams)).called(1),
    );

    blocTest<LoginCubit, LoginState>(
      'emits loading then error on LoginSubmittedIntent failure',
      build: () {
        when(
          () => mockUseCase(any()),
        ).thenAnswer((_) async => _wrongCredentials);
        return cubit;
      },
      act: (c) => c.doIntent(_submit),
      expect: () => [
        const LoginState(loginResource: Resource.loading()),
        LoginState(loginResource: Resource.error(_wrongCredentials.failure)),
      ],
    );

    blocTest<LoginCubit, LoginState>(
      'ignores LoginSubmittedIntent while a request is loading',
      build: () => cubit,
      seed: () => const LoginState(loginResource: Resource.loading()),
      act: (c) => c.doIntent(_submit),
      expect: () => <LoginState>[],
      verify: (_) => verifyNever(() => mockUseCase(any())),
    );

    group('social login', () {
      blocTest<LoginCubit, LoginState>(
        'logs in with the google email and provider password',
        build: () {
          when(
            () => mockGoogleUseCase(),
          ).thenAnswer((_) async => const SuccessResponse(_googleUser));
          givenProviderPassword();
          givenLoginSucceeds();
          return cubit;
        },
        act: (c) => c.doIntent(const SignInWithGoogleIntent()),
        expect: () => [
          const LoginState(loginResource: Resource.loading()),
          const LoginState(loginResource: Resource.success(_testUser)),
        ],
        verify: (_) {
          verify(
            () => mockProviderPasswordUseCase(
              EmailProviderStatus.registeredWithGoogle,
            ),
          ).called(1);
          verify(() => mockUseCase(_socialParams)).called(1);
        },
      );

      blocTest<LoginCubit, LoginState>(
        'logs in with the facebook email and provider password',
        build: () {
          when(
            () => mockFacebookUseCase(),
          ).thenAnswer((_) async => const SuccessResponse(_facebookUser));
          givenProviderPassword();
          givenLoginSucceeds();
          return cubit;
        },
        act: (c) => c.doIntent(const SignInWithFacebookIntent()),
        expect: () => [
          const LoginState(loginResource: Resource.loading()),
          const LoginState(loginResource: Resource.success(_testUser)),
        ],
        verify: (_) {
          verify(
            () => mockProviderPasswordUseCase(
              EmailProviderStatus.registeredWithFacebook,
            ),
          ).called(1);
          verify(() => mockUseCase(_socialParams)).called(1);
        },
      );

      blocTest<LoginCubit, LoginState>(
        'returns to initial and does not log in when the user cancels',
        build: () {
          when(
            () => mockGoogleUseCase(),
          ).thenAnswer((_) async => const SuccessResponse(null));
          return cubit;
        },
        act: (c) => c.doIntent(const SignInWithGoogleIntent()),
        expect: () => [
          const LoginState(loginResource: Resource.loading()),
          const LoginState(),
        ],
        verify: (_) {
          verifyNever(() => mockProviderPasswordUseCase(any()));
          verifyNever(() => mockUseCase(any()));
        },
      );

      blocTest<LoginCubit, LoginState>(
        'emits error when the social sign in fails',
        build: () {
          when(() => mockGoogleUseCase()).thenAnswer(
            (_) async =>
                ErrorResponse<SocialAuthUser?>(failure: const NetworkFailure()),
          );
          return cubit;
        },
        act: (c) => c.doIntent(const SignInWithGoogleIntent()),
        expect: () => [
          const LoginState(loginResource: Resource.loading()),
          const LoginState(loginResource: Resource.error(NetworkFailure())),
        ],
        verify: (_) => verifyNever(() => mockUseCase(any())),
      );

      blocTest<LoginCubit, LoginState>(
        'emits error when the provider password cannot be loaded',
        build: () {
          when(
            () => mockGoogleUseCase(),
          ).thenAnswer((_) async => const SuccessResponse(_googleUser));
          when(() => mockProviderPasswordUseCase(any())).thenAnswer(
            (_) async => ErrorResponse<String>(failure: const ServerFailure()),
          );
          return cubit;
        },
        act: (c) => c.doIntent(const SignInWithGoogleIntent()),
        expect: () => [
          const LoginState(loginResource: Resource.loading()),
          const LoginState(loginResource: Resource.error(ServerFailure())),
        ],
        verify: (_) => verifyNever(() => mockUseCase(any())),
      );

      blocTest<LoginCubit, LoginState>(
        'ignores social intents while a request is loading',
        build: () => cubit,
        seed: () => const LoginState(loginResource: Resource.loading()),
        act: (c) => c
          ..doIntent(const SignInWithGoogleIntent())
          ..doIntent(const SignInWithFacebookIntent()),
        expect: () => <LoginState>[],
        verify: (_) {
          verifyNever(() => mockGoogleUseCase());
          verifyNever(() => mockFacebookUseCase());
        },
      );
    });

    group('ui events', () {
      test('shows a snackbar then navigates home on success', () async {
        when(
          () => mockUseCase(any()),
        ).thenAnswer((_) async => const SuccessResponse(_testUser));
        final events = <BaseUiEvent>[];
        cubit.eventStream.listen(events.add);

        cubit.doIntent(_submit);
        await pumpEventQueue();

        expect(events, [
          isA<ShowSuccessSnackBarEvent>().having(
            (e) => e.type,
            'type',
            CubitMessageType.loginSuccess,
          ),
          isA<NavigateReplacementEvent>().having(
            (e) => e.route,
            'route',
            AppRoutes.home,
          ),
        ]);
      });

      test('emits an error snackbar with the raw failure on error', () async {
        when(
          () => mockUseCase(any()),
        ).thenAnswer((_) async => _wrongCredentials);
        final events = <BaseUiEvent>[];
        cubit.eventStream.listen(events.add);

        cubit.doIntent(_submit);
        await pumpEventQueue();

        expect(events, [
          isA<ShowErrorSnackBarEvent>().having(
            (e) => e.failure,
            'failure',
            _wrongCredentials.failure,
          ),
        ]);
      });

      test('navigates on register and forget password intents', () async {
        final events = <BaseUiEvent>[];
        cubit.eventStream.listen(events.add);

        cubit
          ..doIntent(const NavigateToRegisterIntent())
          ..doIntent(const NavigateToForgetPasswordIntent());
        await pumpEventQueue();

        expect(events.cast<NavigateEvent>().map((e) => e.route), [
          AppRoutes.register,
          AppRoutes.forgetPassword,
        ]);
      });
    });
  });
}
