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
        'user-disabled' => const ForbiddenFailure(),
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
          final body = error.response?.data;
          final json = body is Map<String, dynamic> ? body : null;
          final serverMessage = json == null
              ? null
              : _extractBackendMessage(json);
          final errors = json?['errors'];
          final fieldErrors = errors is Map<String, dynamic> ? errors : null;

          return switch (statusCode) {
            400 => ValidationFailure(
              serverMessage: serverMessage,
              errors: fieldErrors,
              statusCode: statusCode,
            ),
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
              errors: fieldErrors,
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
      final message = data['message'] ?? data['error'] ?? data['msg'];
      if (message is String) {
        return _sanitizeBackendMessage(message);
      }
    }
    return null;
  }

  static String _sanitizeBackendMessage(String message) {
    // If backend returns Joi pattern failure for password:
    // e.g. '"password" with value "Passwordd123" fails to match the required pattern: /.../'
    if (message.contains('password') &&
        message.contains('fails to match the required pattern')) {
      return 'Password must be at least 8 characters long and contain uppercase, lowercase, numbers, and a special character (#?!@\$%^&*-).';
    }

    // Generic sanitization: Remove plain-text values in pattern errors like '"<field>" with value "<sensitive>" fails...'
    final patternRegex = RegExp(
      r'"([^"]+)" with value ".*?" fails to match the required pattern:? .*',
    );
    if (patternRegex.hasMatch(message)) {
      return message.replaceAllMapped(
        patternRegex,
        (m) => '${m.group(1)} does not match the required format.',
      );
    }

    return message;
  }
}
