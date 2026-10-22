import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../error/failures.dart';
import 'cubit_message.dart';
import 'ui_events.dart';

abstract class BaseCubit<State, E extends BaseUiEvent> extends Cubit<State> {
  BaseCubit(super.initialState);

  final StreamController<E> _uiEventStreamController =
      StreamController<E>.broadcast();

  Stream<E> get eventStream => _uiEventStreamController.stream;

  void emitEvent(E event) {
    if (_uiEventStreamController.isClosed) return;

    _uiEventStreamController.add(event);
  }

  // ✅ Directly emits the failure event without mapping to a string!
  void emitFailure(Failure failure) {
    final BaseUiEvent event = ShowErrorSnackBarEvent(failure);
    if (event is E) {
      emitEvent(event);
    }
  }

  /// ✅ Directly emits the success enum without mapping to a string!
  void emitSuccess(CubitMessageType type) {
    final BaseUiEvent event = ShowSuccessSnackBarEvent(type);
    if (event is E) {
      emitEvent(event);
    }
  }

  @override
  Future<void> close() {
    _uiEventStreamController.close();
    return super.close();
  }
}
