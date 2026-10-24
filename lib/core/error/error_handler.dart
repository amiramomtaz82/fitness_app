import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'exceptions.dart';
import 'failures.dart';

class ErrorHandler {
  static Failure handle(Object error) {
    if (error is Failure) return error;

    if (error is ServerException) {
      return ServerFailure(
        serverMessage: error.message,
        statusCode: error.statusCode,
      );
    }

    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'user-not-found' => const NotFoundFailure(),
        'wrong-password' => const UnauthorizedFailure(),
        'user-disabled'  => const ForbiddenFailure(),
        'network-request-failed' => const NetworkFailure(),
        _ => const ServerFailure(),
      };
    }

    if (error is FirebaseException) {
      return switch (error.code) {
        'permission-denied' => const ForbiddenFailure(),
        'not-found' => const NotFoundFailure(),
        'unavailable' => const NetworkFailure(),
        _ => const ServerFailure(),
      };
    }
    //======================================================
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
        case DioExceptionType.connectionError:
          return const NetworkFailure();

        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          final serverMessage = _extractBackendMessage(error.response?.data);

          return switch (statusCode) {
            401 => UnauthorizedFailure(
              serverMessage: serverMessage,
              statusCode: statusCode,
            ),
            403 => ForbiddenFailure(
              serverMessage: serverMessage,
              statusCode: statusCode,
            ),
            404 => NotFoundFailure(
              serverMessage: serverMessage,
              statusCode: statusCode,
            ),
            422 => ValidationFailure(
              serverMessage: serverMessage,
              errors: error.response?.data is Map<String, dynamic>
                  ? error.response?.data['errors']
                  : null,
              statusCode: statusCode,
            ),
            _ => ServerFailure(
              serverMessage: serverMessage,
              statusCode: statusCode,
            ),
          };

        default:
          return UnknownFailure(serverMessage: error.message);
      }
    }

    return UnknownFailure(serverMessage: error.toString());
  }

  // Backward-compatible helpers
  static String extractErrorMessage(Object error) =>
      handle(error).serverMessage ?? 'Something went wrong';
  static int? extractStatusCode(Object error) => handle(error).statusCode;

  static String? _extractBackendMessage(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data['message'] ?? data['error'] ?? data['msg'];
    }
    return null;
  }
}
