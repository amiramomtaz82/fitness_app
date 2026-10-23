import 'package:injectable/injectable.dart';
import '../../../../../../core/base/base_cubit.dart';
import '../../../../../../core/base/cubit_message.dart';
import '../../../../../../core/base/ui_events.dart';
import '../../../../../../core/base_response/base_response.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/go_routes/routes_names.dart';
import '../../../../../../core/resource/resource.dart';
import '../../../../data/data_source/remote/firestore_user_data_source.dart';
import '../../../../data/data_source/remote/social_auth_data_source.dart';
import '../../../../domain/use_cases/register_use_case.dart';
import 'register_intent.dart';
import 'register_state.dart';

@injectable
class RegisterCubit extends BaseCubit<RegisterState, BaseUiEvent> {
  final RegisterUseCase _registerUseCase;
  final SocialAuthService _socialAuthService;
  final FirestoreUserService _firestoreUserService;

  RegisterCubit(
    this._registerUseCase,
    this._socialAuthService,
    this._firestoreUserService,
  ) : super(const RegisterState());

  void doIntent(RegisterIntent intent) {
    switch (intent) {
      case SignInWithGoogleIntent():
        _signInWithGoogle();

      case TogglePasswordVisibilityIntent():
        _togglePasswordVisibility();
      case SubmitAccountCredentialsIntent(
        :final firstName,
        :final lastName,
        :final email,
        :final password,
      ):
        _submitAccountCredentials(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
        );

      case SignInWithFacebookIntent():
        _signInWithFacebook();
    }
  }

  void _togglePasswordVisibility() {
    emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
  }

  void _submitAccountCredentials({
    required String firstName,
    required String lastName,
    required String email,
    required String password,
  }) {
    emit(
      state.copyWith(
        params: state.params.copyWith(
          firstName: firstName,
          lastName: lastName,
          email: email,
          password: password,
        ),
      ),
    );
  }







  // ==========================================
  // GOOGLE SIGN-IN HANDLER
  // ==========================================
  Future<void> _signInWithGoogle() async {
    emit(state.copyWith(registerResource: const Resource.loading()));
    try {
      final googleUser = await _socialAuthService.signInWithGoogle();
      if (googleUser == null) {
        // User cancelled Google picker
        emit(state.copyWith(registerResource: const Resource.initial()));
        return;
      }

      // 1. Get the unified Google provider password
      final providerPassword = await _firestoreUserService.getProviderPassword(
        'google',
      );

      // 2. 👇 SAVE USER IN FIRESTORE FOR FORGOT PASSWORD CHECK
      try {
        await _firestoreUserService.saveUser(
          email: googleUser.email,
          provider: 'google',
          firstName: googleUser.firstName,
          lastName: googleUser.lastName,
        );
      } catch (_) {
        // Ignored: Best-effort save for forgot-password verification
      }

      // 3. Pre-fill credentials into state
      emit(
        state.copyWith(
          registerResource: const Resource.initial(),
          params: state.params.copyWith(
            firstName: googleUser.firstName,
            lastName: googleUser.lastName,
            email: googleUser.email,
            password: providerPassword,
          ),
        ),
      );

      // 4. Navigate directly to Screen 2 (Select Gender) to continue the wizard
      emitEvent(const NavigateEvent(AppRoutes.multiStepRegistration));
    } catch (e) {
      final failure = UnknownFailure(serverMessage: e.toString());
      emit(state.copyWith(registerResource: Resource.error(failure)));
      emitFailure(failure);
    }
  }

  Future<void> _signInWithFacebook() async {
    emit(state.copyWith(registerResource: const Resource.loading()));
    try {
      final facebookUser = await _socialAuthService.signInWithFacebook();
      if (facebookUser == null) {
        // User cancelled picker
        emit(state.copyWith(registerResource: const Resource.initial()));
        return;
      }
      // 1. Get unified Facebook provider password
      final providerPassword = await _firestoreUserService.getProviderPassword(
        'facebook',
      );
      // 2. Save user in Firestore for forgot-password check
      try {
        await _firestoreUserService.saveUser(
          email: facebookUser.email,
          provider: 'facebook',
          firstName: facebookUser.firstName,
          lastName: facebookUser.lastName,
        );
      } catch (_) {
        // Ignored: Best-effort save for forgot-password verification
      }
      // 3. Pre-fill credentials into state
      emit(
        state.copyWith(
          registerResource: const Resource.initial(),
          params: state.params.copyWith(
            firstName: facebookUser.firstName,
            lastName: facebookUser.lastName,
            email: facebookUser.email,
            password: providerPassword,
          ),
        ),
      );
      // 4. Navigate directly to Screen 2 (Select Gender)
      emitEvent(const NavigateEvent(AppRoutes.multiStepRegistration));
    } catch (e) {
      // ✅ Emits typed Failure without raw strings!
      final failure = UnknownFailure(serverMessage: e.toString());
      emit(state.copyWith(registerResource: Resource.error(failure)));
      emitFailure(failure);
    }
  }
}
