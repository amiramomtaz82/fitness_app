import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/app/routes_names.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/auth/domain/entities/email_provider_status.dart';
import 'package:fitness_app/features/auth/domain/entities/register_parameters.dart';
import 'package:fitness_app/features/auth/domain/entities/social_auth_user.dart';
import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';
import 'package:fitness_app/features/auth/domain/use_cases/get_provider_password_use_case.dart';
import 'package:fitness_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:fitness_app/features/auth/domain/use_cases/sign_in_with_facebook_use_case.dart';
import 'package:fitness_app/features/auth/domain/use_cases/sign_in_with_google_use_case.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_cubit.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_intent.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockSignInWithGoogleUseCase extends Mock
    implements SignInWithGoogleUseCase {}

class MockGetProviderPasswordUseCase extends Mock
    implements GetProviderPasswordUseCase {}

class MockSignInWithFacebookUseCase extends Mock
    implements SignInWithFacebookUseCase {}

void main() {
  late MockRegisterUseCase mockRegisterUseCase;
  late MockSignInWithGoogleUseCase mockSignInWithGoogleUseCase;
  late MockGetProviderPasswordUseCase mockGetProviderPasswordUseCase;
  late MockSignInWithFacebookUseCase mockSignInWithFacebookUseCase;
  late RegisterCubit registerCubit;

  setUpAll(() {
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
  });

  tearDown(() {
    registerCubit.close();
  });

  group('RegisterCubit (Screen 1: Credentials & Social Auth)', () {
    test('initial state should have correct default values', () {
      expect(registerCubit.state, equals(const RegisterState()));
      expect(registerCubit.state.isPasswordObscured, isTrue);
      expect(
        registerCubit.state.registerResource,
        equals(const Resource<UserEntity>.initial()),
      );
      expect(registerCubit.state.params, equals(const RegisterParameters()));
    });

    group('TogglePasswordVisibilityIntent', () {
      blocTest<RegisterCubit, RegisterState>(
        'toggles isPasswordObscured from true to false',
        build: () => registerCubit,
        act: (cubit) => cubit.doIntent(const TogglePasswordVisibilityIntent()),
        expect: () => [const RegisterState(isPasswordObscured: false)],
      );

      blocTest<RegisterCubit, RegisterState>(
        'toggles isPasswordObscured back from false to true on second call',
        build: () => registerCubit,
        act: (cubit) {
          cubit.doIntent(const TogglePasswordVisibilityIntent());
          cubit.doIntent(const TogglePasswordVisibilityIntent());
        },
        expect: () => [
          const RegisterState(isPasswordObscured: false),
          const RegisterState(isPasswordObscured: true),
        ],
      );
    });

    group('SubmitAccountCredentialsIntent', () {
      blocTest<RegisterCubit, RegisterState>(
        'updates params with form input and emits NavigateEvent to multiStepRegistration',
        build: () => registerCubit,
        act: (cubit) => cubit.doIntent(
          const SubmitAccountCredentialsIntent(
            firstName: 'Ahmed',
            lastName: 'Ali',
            email: 'ahmed@gmail.com',
            password: 'Password123!',
          ),
        ),
        expect: () => [
          const RegisterState(
            params: RegisterParameters(
              firstName: 'Ahmed',
              lastName: 'Ali',
              email: 'ahmed@gmail.com',
              password: 'Password123!',
            ),
          ),
        ],
      );
    });

    group('SignInWithGoogleIntent', () {
      const tSocialUser = SocialAuthUser(
        email: 'ahmed@gmail.com',
        firstName: 'Ahmed',
        lastName: 'Ali',
        provider: 'google',
      );
      const tGooglePassword = 'GoogleAuth@ElevateFitness2026#';

      blocTest<RegisterCubit, RegisterState>(
        'emits [loading, initial with pre-filled params] on successful Google sign-in',
        setUp: () {
          when(
            () => mockSignInWithGoogleUseCase(),
          ).thenAnswer((_) async => const SuccessResponse(tSocialUser));
          when(
            () => mockGetProviderPasswordUseCase(
              EmailProviderStatus.registeredWithGoogle,
            ),
          ).thenAnswer((_) async => const SuccessResponse(tGooglePassword));
        },
        build: () => registerCubit,
        act: (cubit) => cubit.doIntent(const SignInWithGoogleIntent()),
        expect: () => [
          const RegisterState(registerResource: Resource.loading()),
          const RegisterState(
            registerResource: Resource.initial(),
            params: RegisterParameters(
              firstName: 'Ahmed',
              lastName: 'Ali',
              email: 'ahmed@gmail.com',
              password: tGooglePassword,
            ),
          ),
        ],
        verify: (_) {
          verify(() => mockSignInWithGoogleUseCase()).called(1);
          verify(
            () => mockGetProviderPasswordUseCase(
              EmailProviderStatus.registeredWithGoogle,
            ),
          ).called(1);
        },
      );

      test(
        'triggers NavigateEvent to multiStepRegistration on successful Google sign-in',
        () async {
          when(
            () => mockSignInWithGoogleUseCase(),
          ).thenAnswer((_) async => const SuccessResponse(tSocialUser));
          when(
            () => mockGetProviderPasswordUseCase(
              EmailProviderStatus.registeredWithGoogle,
            ),
          ).thenAnswer((_) async => const SuccessResponse(tGooglePassword));

          final events = <BaseUiEvent>[];
          final subscription = registerCubit.eventStream.listen(events.add);

          registerCubit.doIntent(const SignInWithGoogleIntent());
          await Future.delayed(Duration.zero);

          expect(events, hasLength(1));
          expect(events.first, isA<NavigateEvent>());
          expect(
            (events.first as NavigateEvent).route,
            equals(AppRoutes.multiStepRegistration),
          );

          await subscription.cancel();
        },
      );

      blocTest<RegisterCubit, RegisterState>(
        'emits [loading, initial] when user cancels Google sign-in picker',
        setUp: () {
          when(
            () => mockSignInWithGoogleUseCase(),
          ).thenAnswer((_) async => const SuccessResponse(null));
        },
        build: () => registerCubit,
        act: (cubit) => cubit.doIntent(const SignInWithGoogleIntent()),
        expect: () => [
          const RegisterState(registerResource: Resource.loading()),
          const RegisterState(registerResource: Resource.initial()),
        ],
        verify: (_) {
          verify(() => mockSignInWithGoogleUseCase()).called(1);
          verifyNever(() => mockGetProviderPasswordUseCase(any()));
        },
      );
    });

    group('SignInWithFacebookIntent', () {
      const tSocialUser = SocialAuthUser(
        email: 'facebookuser@gmail.com',
        firstName: 'Facebook',
        lastName: 'User',
        provider: 'facebook',
      );
      const tFacebookPassword = 'FacebookAuth@ElevateFitness2026#';

      blocTest<RegisterCubit, RegisterState>(
        'emits [loading, initial with pre-filled params] on successful Facebook sign-in',
        setUp: () {
          when(
            () => mockSignInWithFacebookUseCase(),
          ).thenAnswer((_) async => const SuccessResponse(tSocialUser));
          when(
            () => mockGetProviderPasswordUseCase(
              EmailProviderStatus.registeredWithFacebook,
            ),
          ).thenAnswer((_) async => const SuccessResponse(tFacebookPassword));
        },
        build: () => registerCubit,
        act: (cubit) => cubit.doIntent(const SignInWithFacebookIntent()),
        expect: () => [
          const RegisterState(registerResource: Resource.loading()),
          const RegisterState(
            registerResource: Resource.initial(),
            params: RegisterParameters(
              firstName: 'Facebook',
              lastName: 'User',
              email: 'facebookuser@gmail.com',
              password: tFacebookPassword,
            ),
          ),
        ],
        verify: (_) {
          verify(() => mockSignInWithFacebookUseCase()).called(1);
          verify(
            () => mockGetProviderPasswordUseCase(
              EmailProviderStatus.registeredWithFacebook,
            ),
          ).called(1);
        },
      );

      blocTest<RegisterCubit, RegisterState>(
        'emits [loading, initial] when user cancels Facebook sign-in dialog',
        setUp: () {
          when(
            () => mockSignInWithFacebookUseCase(),
          ).thenAnswer((_) async => const SuccessResponse(null));
        },
        build: () => registerCubit,
        act: (cubit) => cubit.doIntent(const SignInWithFacebookIntent()),
        expect: () => [
          const RegisterState(registerResource: Resource.loading()),
          const RegisterState(registerResource: Resource.initial()),
        ],
        verify: (_) {
          verify(() => mockSignInWithFacebookUseCase()).called(1);
          verifyNever(() => mockGetProviderPasswordUseCase(any()));
        },
      );

      blocTest<RegisterCubit, RegisterState>(
        'emits [loading, error] when Facebook sign-in fails',
        setUp: () {
          when(() => mockSignInWithFacebookUseCase()).thenAnswer(
            (_) async => ErrorResponse(failure: const NetworkFailure()),
          );
        },
        build: () => registerCubit,
        act: (cubit) => cubit.doIntent(const SignInWithFacebookIntent()),
        expect: () => [
          const RegisterState(registerResource: Resource.loading()),
          isA<RegisterState>().having(
            (s) => s.registerResource.isError,
            'isError',
            isTrue,
          ),
        ],
      );
    });
  });
}
