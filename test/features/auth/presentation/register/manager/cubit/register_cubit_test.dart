import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/go_routes/routes_names.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/auth/data/data_source/remote/firestore_user_data_source.dart';
import 'package:fitness_app/features/auth/data/data_source/remote/social_auth_data_source.dart';
import 'package:fitness_app/features/auth/domain/entities/social_auth_user.dart';
import 'package:fitness_app/features/auth/domain/entities/register_parameters.dart';
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

  const tUser = UserEntity(
    id: 'user_123',
    firstName: 'Ahmed',
    lastName: 'Ali',
    email: 'ahmed@example.com',
    gender: 'male',
    age: 25,
    weight: 75,
    height: 180,
    goal: 'Gain weight',
    activityLevel: 'level1',
  );

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

  group('RegisterCubit', () {
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

    group('Wizard Step Intents', () {
      blocTest<RegisterCubit, RegisterState>(
        'emits state with updated gender when UpdateGenderIntent is dispatched',
        build: () => registerCubit,
        act: (cubit) => cubit.doIntent(const UpdateGenderIntent('male')),
        expect: () => [
          const RegisterState(params: RegisterParameters(gender: 'male')),
        ],
      );

      blocTest<RegisterCubit, RegisterState>(
        'emits state with updated age when UpdateAgeIntent is dispatched',
        build: () => registerCubit,
        act: (cubit) => cubit.doIntent(const UpdateAgeIntent(25)),
        expect: () => [
          const RegisterState(params: RegisterParameters(age: 25)),
        ],
      );

      blocTest<RegisterCubit, RegisterState>(
        'emits state with updated weight when UpdateWeightIntent is dispatched',
        build: () => registerCubit,
        act: (cubit) => cubit.doIntent(const UpdateWeightIntent(75.5)),
        expect: () => [
          const RegisterState(params: RegisterParameters(weight: 75.5)),
        ],
      );

      blocTest<RegisterCubit, RegisterState>(
        'emits state with updated height when UpdateHeightIntent is dispatched',
        build: () => registerCubit,
        act: (cubit) => cubit.doIntent(const UpdateHeightIntent(180)),
        expect: () => [
          const RegisterState(params: RegisterParameters(height: 180)),
        ],
      );

      blocTest<RegisterCubit, RegisterState>(
        'emits state with updated goal when UpdateGoalIntent is dispatched',
        build: () => registerCubit,
        act: (cubit) => cubit.doIntent(const UpdateGoalIntent('Gain weight')),
        expect: () => [
          const RegisterState(params: RegisterParameters(goal: 'Gain weight')),
        ],
      );
    });

    group('SubmitFullRegistrationIntent', () {
      const tActivity = 'level1';
      const tFullParams = RegisterParameters(
        firstName: 'Ahmed',
        lastName: 'Ali',
        email: 'ahmed@example.com',
        password: 'Password123',
        gender: 'male',
        age: 25,
        weight: 75,
        height: 180,
        goal: 'Gain weight',
        activityLevel: tActivity,
      );

      blocTest<RegisterCubit, RegisterState>(
        'emits [loading, success] when registerUseCase succeeds',
        setUp: () {
          when(
            () => mockRegisterUseCase(any()),
          ).thenAnswer((_) async => const SuccessResponse<UserEntity>(tUser));
        },
        build: () => registerCubit,
        seed: () => const RegisterState(
          params: RegisterParameters(
            firstName: 'Ahmed',
            lastName: 'Ali',
            email: 'ahmed@example.com',
            password: 'Password123',
            gender: 'male',
            age: 25,
            weight: 75,
            height: 180,
            goal: 'Gain weight',
          ),
        ),
        act: (cubit) =>
            cubit.doIntent(const SubmitFullRegistrationIntent(tActivity)),
        expect: () => [
          const RegisterState(
            params: tFullParams,
            registerResource: Resource.loading(),
          ),
          const RegisterState(
            params: tFullParams,
            registerResource: Resource.success(tUser),
          ),
        ],
        verify: (_) {
          verify(() => mockRegisterUseCase(tFullParams)).called(1);
        },
      );

      test(
        'triggers success snackbar and NavigateReplacementEvent on registration success',
        () async {
          when(
            () => mockRegisterUseCase(any()),
          ).thenAnswer((_) async => const SuccessResponse<UserEntity>(tUser));

          final events = <BaseUiEvent>[];
          final subscription = registerCubit.eventStream.listen(events.add);

          registerCubit.doIntent(const SubmitFullRegistrationIntent(tActivity));
          await Future.delayed(Duration.zero);

          expect(events, hasLength(2));
          expect(events[0], isA<ShowSnackBarEvent>());
          expect(events[1], isA<NavigateReplacementEvent>());
          expect(
            (events[1] as NavigateReplacementEvent).route,
            equals(AppRoutes.login),
          );

          await subscription.cancel();
        },
      );

      blocTest<RegisterCubit, RegisterState>(
        'emits [loading, error] when registerUseCase fails',
        setUp: () {
          when(() => mockRegisterUseCase(any())).thenAnswer(
            (_) async => ErrorResponse<UserEntity>(
              failure: const ServerFailure(
                serverMessage: 'User already exists',
                statusCode: 409,
              ),
            ),
          );
        },
        build: () => registerCubit,
        act: (cubit) =>
            cubit.doIntent(const SubmitFullRegistrationIntent(tActivity)),
        expect: () => [
          const RegisterState(
            params: RegisterParameters(activityLevel: tActivity),
            registerResource: Resource.loading(),
          ),
          const RegisterState(
            params: RegisterParameters(activityLevel: tActivity),
            registerResource: Resource.error('User already exists'),
          ),
        ],
        verify: (_) {
          verify(() => mockRegisterUseCase(any())).called(1);
        },
      );

      test('triggers failure UI event on registration error', () async {
        when(() => mockRegisterUseCase(any())).thenAnswer(
          (_) async => ErrorResponse<UserEntity>(
            failure: const ServerFailure(
              serverMessage: 'User already exists',
              statusCode: 409,
            ),
          ),
        );

        final events = <BaseUiEvent>[];
        final subscription = registerCubit.eventStream.listen(events.add);

        registerCubit.doIntent(const SubmitFullRegistrationIntent(tActivity));
        await Future.delayed(Duration.zero);

        expect(events, hasLength(1));
        expect(events.first, isA<ShowSnackBarEvent>());
        final snackBarEvent = events.first as ShowSnackBarEvent;
        expect(snackBarEvent.isError, isTrue);
        expect(snackBarEvent.message, equals('User already exists'));

        await subscription.cancel();
      });
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
