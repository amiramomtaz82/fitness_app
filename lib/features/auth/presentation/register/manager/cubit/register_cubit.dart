import 'package:injectable/injectable.dart';
import '../../../../../../core/base/base_cubit.dart';
import '../../../../../../core/base/ui_events.dart';
import '../../../../domain/use_cases/register_use_case.dart';
import 'register_state.dart';
import 'register_intent.dart';


@injectable
class RegisterCubit extends BaseCubit<RegisterState, BaseUiEvent> {
  final RegisterUseCase _registerUseCase;

  RegisterCubit(this._registerUseCase) : super(const RegisterState());


  void doIntent(RegisterIntent intent) {
    switch (intent) {
      case TogglePasswordVisibilityIntent():
        _togglePasswordVisibility();
    }
  }
  void _togglePasswordVisibility() {
    emit(state.copyWith(isPasswordObscured: !state.isPasswordObscured));
  }


}