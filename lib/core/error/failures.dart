/// Base class for all failures in the application
/// Failures represent errors at the domain layer
abstract class Failure {
  final String message;
  
  const Failure(this.message);
  
  @override
  String toString() => message;
}

/// Server-related failures (API errors, 500, etc.)
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

/// Cache-related failures (local database errors)
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error occurred']) : super(message);
}

/// Connection-related failures (no internet connection)
class ConnectionFailure extends Failure {
  const ConnectionFailure([String message = 'No internet connection']) : super(message);
}

/// Timeout-related failures (request timeout)
class TimeoutFailure extends Failure {
  const TimeoutFailure([String message = 'Request timeout']) : super(message);
}

/// Network-related failures (general network errors)
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network error occurred']) : super(message);
}

/// Validation failures (invalid input)
class ValidationFailure extends Failure {
  const ValidationFailure([String message = 'Validation error occurred']) : super(message);
}

/// Not found failures (404, resource not found)
class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Resource not found']) : super(message);
}

/// Unauthorized failures (401, 403)
class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure([String message = 'Unauthorized access']) : super(message);
}
