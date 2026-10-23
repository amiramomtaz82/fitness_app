import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/go_routes/routes_names.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/auth/data/data_source/remote/firestore_user_data_source.dart';
import 'package:fitness_app/features/auth/data/data_source/remote/social_auth_data_source.dart';
import 'package:fitness_app/features/auth/domain/entities/register_parameters.dart';
import 'package:fitness_app/features/auth/domain/entities/social_auth_user.dart';
import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';
import 'package:fitness_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_cubit.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_intent.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockSocialAuthService extends Mock implements SocialAuthService {}

class MockFirestoreUserService extends Mock implements FirestoreUserService {}

void main() {
  late MockRegisterUseCase mockRegisterUseCase;
  late MockSocialAuthService mockSocialAuthService;
  late MockFirestoreUserService mockFirestoreUserService;
  late RegisterCubit registerCubit;

  setUpAll(() {
    registerFallbackValue(const RegisterParameters());
  });

  setUp(() {
    mockRegisterUseCase = MockRegisterUseCase();
    mockSocialAuthService = MockSocialAuthService();
    mockFirestoreUserService = MockFirestoreUserService();
    registerCubit = RegisterCubit(
      mockRegisterUseCase,
      mockSocialAuthService,
      mockFirestoreUserService,
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
        'emits state with isPasswordObscured false when toggled once',
        build: () => registerCubit,
        act: (cubit) => cubit.doIntent(const TogglePasswordVisibilityIntent()),
        expect: () => [const RegisterState(isPasswordObscured: false)],
      );

      blocTest<RegisterCubit, RegisterState>(
        'emits state with isPasswordObscured true when toggled twice',
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
        'emits state with updated account credentials in params',
        build: () => registerCubit,
        act: (cubit) => cubit.doIntent(
          const SubmitAccountCredentialsIntent(
            firstName: 'Ahmed',
            lastName: 'Ali',
            email: 'ahmed@example.com',
            password: 'Password123',
          ),
        ),
        expect: () => [
          const RegisterState(
            params: RegisterParameters(
              firstName: 'Ahmed',
              lastName: 'Ali',
              email: 'ahmed@example.com',
              password: 'Password123',
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
        'emits [loading, initial with pre-filled params] and saves user to firestore on successful Google sign-in',
        setUp: () {
          when(
            () => mockSocialAuthService.signInWithGoogle(),
          ).thenAnswer((_) async => tSocialUser);
          when(
            () => mockFirestoreUserService.getProviderPassword('google'),
          ).thenAnswer((_) async => tGooglePassword);
          when(
            () => mockFirestoreUserService.saveUser(
              email: any(named: 'email'),
              provider: any(named: 'provider'),
              firstName: any(named: 'firstName'),
              lastName: any(named: 'lastName'),
            ),
          ).thenAnswer((_) async {});
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
          verify(() => mockSocialAuthService.signInWithGoogle()).called(1);
          verify(
            () => mockFirestoreUserService.getProviderPassword('google'),
          ).called(1);
          verify(
            () => mockFirestoreUserService.saveUser(
              email: 'ahmed@gmail.com',
              provider: 'google',
              firstName: 'Ahmed',
              lastName: 'Ali',
            ),
          ).called(1);
        },
      );

      test(
        'triggers NavigateEvent to multiStepRegistration on successful Google sign-in',
        () async {
          when(
            () => mockSocialAuthService.signInWithGoogle(),
          ).thenAnswer((_) async => tSocialUser);
          when(
            () => mockFirestoreUserService.getProviderPassword('google'),
          ).thenAnswer((_) async => tGooglePassword);
          when(
            () => mockFirestoreUserService.saveUser(
              email: any(named: 'email'),
              provider: any(named: 'provider'),
              firstName: any(named: 'firstName'),
              lastName: any(named: 'lastName'),
            ),
          ).thenAnswer((_) async {});

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
            () => mockSocialAuthService.signInWithGoogle(),
          ).thenAnswer((_) async => null);
        },
        build: () => registerCubit,
        act: (cubit) => cubit.doIntent(const SignInWithGoogleIntent()),
        expect: () => [
          const RegisterState(registerResource: Resource.loading()),
          const RegisterState(registerResource: Resource.initial()),
        ],
        verify: (_) {
          verify(() => mockSocialAuthService.signInWithGoogle()).called(1);
          verifyNever(
            () => mockFirestoreUserService.getProviderPassword(any()),
          );
          verifyNever(
            () => mockFirestoreUserService.saveUser(
              email: any(named: 'email'),
              provider: any(named: 'provider'),
              firstName: any(named: 'firstName'),
              lastName: any(named: 'lastName'),
            ),
          );
        },
      );
    });
  });
}
