import '../error/error_handler.dart';
import '../error/failures.dart';

sealed class BaseResponse<T> {
  const BaseResponse();
}

class SuccessResponse<T> extends BaseResponse<T> {
  final T data;
  const SuccessResponse(this.data);
}

class ErrorResponse<T> extends BaseResponse<T> {
  final Failure failure;
  final Object? error;

  ErrorResponse({
    this.error,
    String? errMessage,
    Failure? failure,
    int? statusCode,
  }) : failure =
           failure ??
           (error is Failure
               ? error
               : (error != null
                     ? ErrorHandler.handle(error)
                     : UnknownFailure(
                         serverMessage: errMessage,
                         statusCode: statusCode,
                       )));

  // Backward-compatible getters
  String get errMessage => failure.serverMessage ?? 'Something went wrong';
  int? get statusCode => failure.statusCode;
  bool get isUnauthorized =>
      failure is UnauthorizedFailure || statusCode == 401;
}
