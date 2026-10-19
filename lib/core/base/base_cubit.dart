import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../error/failure_mapper.dart';
import '../error/failures.dart';
import 'cubit_message.dart';
import 'cubit_message_mapper.dart';
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

  /// Helper to emit a predefined success message
  void emitSuccess(CubitMessageType type) {
    final BaseUiEvent event = CubitMessageMapper.successEvent(type);
    if (event is E) {
      emitEvent(event);
    }
  }

  /// Helper to emit a custom string message
  void emitSuccessMessage(String message) {
    final BaseUiEvent event = ShowSnackBarEvent(
      message: message,
      isError: false,
    );
    if (event is E) {
      emitEvent(event);
    }
  }

  /// Helper to emit a Failure as an error UI event
  void emitFailure(Failure failure) {
    final BaseUiEvent event = FailureMapper.mapToUiEvent(failure);
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
