import 'package:fitness_app/features/auth/domain/use_cases/get_provider_password_use_case.dart';
import 'package:fitness_app/features/auth/domain/use_cases/register_use_case.dart';
import 'package:fitness_app/features/auth/domain/use_cases/sign_in_with_facebook_use_case.dart';
import 'package:fitness_app/features/auth/domain/use_cases/sign_in_with_google_use_case.dart';
import 'package:fitness_app/features/auth/presentation/register/manager/cubit/register_cubit.dart';
import 'package:mocktail/mocktail.dart';

class MockRegisterUseCase extends Mock implements RegisterUseCase {}

class MockSignInWithGoogleUseCase extends Mock
    implements SignInWithGoogleUseCase {}

class MockGetProviderPasswordUseCase extends Mock
    implements GetProviderPasswordUseCase {}

class MockSignInWithFacebookUseCase extends Mock
    implements SignInWithFacebookUseCase {}

RegisterCubit createTestRegisterCubit({
  RegisterUseCase? registerUseCase,
  SignInWithGoogleUseCase? signInWithGoogleUseCase,
  GetProviderPasswordUseCase? getProviderPasswordUseCase,
  SignInWithFacebookUseCase? signInWithFacebookUseCase,
}) {
  return RegisterCubit(
    registerUseCase ?? MockRegisterUseCase(),
    signInWithGoogleUseCase ?? MockSignInWithGoogleUseCase(),
    getProviderPasswordUseCase ?? MockGetProviderPasswordUseCase(),
    signInWithFacebookUseCase ?? MockSignInWithFacebookUseCase(),
  );
}
