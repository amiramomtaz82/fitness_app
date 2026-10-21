import 'package:bloc_test/bloc_test.dart';
import 'package:fitness_app/core/base/ui_events.dart';
import 'package:fitness_app/core/base_response/base_response.dart';
import 'package:fitness_app/core/error/failures.dart';
import 'package:fitness_app/core/go_routes/routes_names.dart';
import 'package:fitness_app/core/resource/resource.dart';
import 'package:fitness_app/features/auth/domain/entities/login_params.dart';
import 'package:fitness_app/features/auth/domain/entities/user_entity.dart';
import 'package:fitness_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:fitness_app/features/auth/presentation/login/view_model/login_cubit.dart';
import 'package:fitness_app/features/auth/presentation/login/view_model/login_intent.dart';
import 'package:fitness_app/features/auth/presentation/login/view_model/login_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

const _testUser = UserEntity(id: 'user-id', email: 'test@test.com');

const _submit = LoginSubmittedIntent(
  email: ' test@test.com ',
  password: 'Pass1234',
);

final _wrongCredentials = ErrorResponse<UserEntity>(
  failure: const UnauthorizedFailure(
    serverMessage: 'incorrect email or password',
  ),
);

void main() {
  late MockLoginUseCase mockUseCase;
  late LoginCubit cubit;

  setUpAll(
    () => registerFallbackValue(const LoginParams(email: '', password: '')),
  );

  setUp(() {
    mockUseCase = MockLoginUseCase();
    cubit = LoginCubit(mockUseCase);
  });

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
      verify: (_) => verify(
        () => mockUseCase(
          const LoginParams(email: 'test@test.com', password: 'Pass1234'),
        ),
      ).called(1),
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
        isA<LoginState>().having(
          (s) => s.loginResource.errorMessage,
          'errorMessage',
          'incorrect email or password',
        ),
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
          isA<ShowSnackBarEvent>().having((e) => e.isError, 'isError', false),
          isA<NavigateReplacementEvent>().having(
            (e) => e.route,
            'route',
            AppRoutes.home,
          ),
        ]);
      });

      test('shows an error snackbar on wrong credentials', () async {
        when(
          () => mockUseCase(any()),
        ).thenAnswer((_) async => _wrongCredentials);
        final events = <BaseUiEvent>[];
        cubit.eventStream.listen(events.add);

        cubit.doIntent(_submit);
        await pumpEventQueue();

        expect(events, [
          isA<ShowSnackBarEvent>()
              .having((e) => e.isError, 'isError', true)
              .having(
                (e) => e.message,
                'message',
                'incorrect email or password',
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
