import 'package:injectable/injectable.dart';

import '../../../../../../core/base/base_cubit.dart';
import '../../../../../../core/base/ui_events.dart';
import '../../../../../../core/base_response/base_response.dart';
import '../../../../../../core/go_routes/routes_names.dart';
import '../../../../../../core/resource/resource.dart';
import '../../../../domain/entities/email_provider_status.dart';

import '../../../../domain/use_cases/get_provider_password_use_case.dart';
import '../../../../domain/use_cases/register_use_case.dart';
import '../../../../domain/use_cases/sign_in_with_facebook_use_case.dart';
import '../../../../domain/use_cases/sign_in_with_google_use_case.dart';
import 'register_intent.dart';
import 'register_state.dart';

@injectable
class RegisterCubit extends BaseCubit<RegisterState, BaseUiEvent> {
  // ignore: unused_field
  final RegisterUseCase _registerUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final GetProviderPasswordUseCase _getProviderPasswordUseCase;
  final SignInWithFacebookUseCase _signInWithFacebookUseCase;
  RegisterCubit(
    this._registerUseCase,
    this._signInWithGoogleUseCase,
    this._getProviderPasswordUseCase,
    this._signInWithFacebookUseCase,
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
    emitEvent(const NavigateEvent(AppRoutes.multiStepRegistration));
  }

  Future<void> _signInWithGoogle() async {
    emit(state.copyWith(registerResource: const Resource.loading()));

    final result = await _signInWithGoogleUseCase();

    switch (result) {
      case SuccessResponse(:final data):
        if (data == null) {
          // User intentionally cancelled the Google picker
          emit(state.copyWith(registerResource: const Resource.initial()));
          return;
        }

        // Get unified provider password from repository
        final passwordResult = await _getProviderPasswordUseCase(
          EmailProviderStatus.registeredWithGoogle,
        );

        switch (passwordResult) {
          case SuccessResponse(data: final providerPassword):
            emit(
              state.copyWith(
                registerResource: const Resource.initial(),
                params: state.params.copyWith(
                  firstName: data.firstName,
                  lastName: data.lastName,
                  email: data.email,
                  password: providerPassword,
                ),
              ),
            );
            // Navigate via typed UI Event
            emitEvent(const NavigateEvent(AppRoutes.multiStepRegistration));

          case ErrorResponse(:final failure):
            emit(state.copyWith(registerResource: Resource.error(failure)));
            emitFailure(failure);
        }

      case ErrorResponse(:final failure):
        emit(state.copyWith(registerResource: Resource.error(failure)));
        emitFailure(failure);
    }
  }

  // ==========================================
  // FACEBOOK SIGN-IN HANDLER
  // ==========================================
  Future<void> _signInWithFacebook() async {
    emit(state.copyWith(registerResource: const Resource.loading()));
    final result = await _signInWithFacebookUseCase();
    switch (result) {
      case SuccessResponse(:final data):
        if (data == null) {
          // User intentionally cancelled Facebook dialog
          emit(state.copyWith(registerResource: const Resource.initial()));
          return;
        }
        // Fetch unified Facebook provider password via UseCase (No hardcoded string!)
        final passwordResult = await _getProviderPasswordUseCase(
          EmailProviderStatus.registeredWithFacebook,
        );
        switch (passwordResult) {
          case SuccessResponse(data: final providerPassword):
            emit(
              state.copyWith(
                registerResource: const Resource.initial(),
                params: state.params.copyWith(
                  firstName: data.firstName,
                  lastName: data.lastName,
                  email: data.email,
                  password: providerPassword,
                ),
              ),
            );
            // Navigate to Screen 2 via UiEvent stream
            emitEvent(const NavigateEvent(AppRoutes.multiStepRegistration));
          case ErrorResponse(:final failure):
            emit(state.copyWith(registerResource: Resource.error(failure)));
            emitFailure(failure);
        }
      case ErrorResponse(:final failure):
        emit(state.copyWith(registerResource: Resource.error(failure)));
        emitFailure(failure);
    }
  }
}
