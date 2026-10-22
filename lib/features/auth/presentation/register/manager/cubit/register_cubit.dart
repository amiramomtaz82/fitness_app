import 'package:injectable/injectable.dart';
import '../../../../../../core/base/base_cubit.dart';
import '../../../../../../core/base/cubit_message.dart';
import '../../../../../../core/base/ui_events.dart';
import '../../../../../../core/base_response/base_response.dart';
import '../../../../../../core/go_routes/routes_names.dart';
import '../../../../../../core/resource/resource.dart';
import '../../../../domain/use_cases/register_use_case.dart';
import 'register_intent.dart';
import 'register_state.dart';

@injectable
class RegisterCubit extends BaseCubit<RegisterState, BaseUiEvent> {
  final RegisterUseCase _registerUseCase;

  RegisterCubit(this._registerUseCase) : super(const RegisterState());

  void doIntent(RegisterIntent intent) {
    switch (intent) {
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
      case UpdateGenderIntent(:final gender):
        _updateGender(gender);
      case UpdateAgeIntent(:final age):
        _updateAge(age);
      case UpdateWeightIntent(:final weight):
        _updateWeight(weight);
      case UpdateHeightIntent(:final height):
        _updateHeight(height);
      case UpdateGoalIntent(:final goal):
        _updateGoal(goal);
      case SubmitFullRegistrationIntent(:final activityLevel):
        _submitFullRegistration(activityLevel);
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
    emit(state.copyWith(
      params: state.params.copyWith(
        firstName: firstName,
        lastName: lastName,
        email: email,
        password: password,
      ),
    ));
  }

  void _updateGender(String gender) {
    emit(state.copyWith(params: state.params.copyWith(gender: gender)));
  }

  void _updateAge(int age) {
    emit(state.copyWith(params: state.params.copyWith(age: age)));
  }

  void _updateWeight(num weight) {
    emit(state.copyWith(params: state.params.copyWith(weight: weight)));
  }

  void _updateHeight(num height) {
    emit(state.copyWith(params: state.params.copyWith(height: height)));
  }

  void _updateGoal(String goal) {
    emit(state.copyWith(params: state.params.copyWith(goal: goal)));
  }

  Future<void> _submitFullRegistration(String activityLevel) async {
    final fullParams = state.params.copyWith(activityLevel: activityLevel);
    emit(state.copyWith(
      params: fullParams,
      registerResource: const Resource.loading(),
    ));

    final response = await _registerUseCase(fullParams);

    switch (response) {
      case SuccessResponse(:final data):
        emit(state.copyWith(registerResource: Resource.success(data)));
        emitSuccess(CubitMessageType.registerSuccess);
        emitEvent(const NavigateReplacementEvent(AppRoutes.login));

      case ErrorResponse(:final failure):
        final errorMsg = failure.serverMessage ?? 'Registration failed';
        emit(state.copyWith(
          registerResource: Resource.error(errorMsg),
        ));
        emitFailure(failure);
    }
  }
}