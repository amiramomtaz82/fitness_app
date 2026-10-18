sealed class Failure {
  final String? serverMessage;
  final int? statusCode;

  const Failure({this.serverMessage, this.statusCode});

  /// Alias for backward compatibility
  String? get message => serverMessage;
}

class ServerFailure extends Failure {
  const ServerFailure({super.serverMessage, super.statusCode});
}

class NetworkFailure extends Failure {
  const NetworkFailure({super.serverMessage, super.statusCode});
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure({super.serverMessage, super.statusCode = 401});
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure({super.serverMessage, super.statusCode = 403});
}

class NotFoundFailure extends Failure {
  const NotFoundFailure({super.serverMessage, super.statusCode = 404});
}

class ValidationFailure extends Failure {
  final Map<String, dynamic>? errors;
  const ValidationFailure({super.serverMessage, this.errors, super.statusCode = 422});
}

class UnknownFailure extends Failure {
  const UnknownFailure({super.serverMessage, super.statusCode});
}