/// Base class for all exceptions in the application
/// Exceptions are thrown at the data layer
class AppException implements Exception {
  final String message;
  
  const AppException(this.message);
  
  @override
  String toString() => message;
}

/// Server-related exceptions (API errors)
class ServerException extends AppException {
  final int? statusCode;
  
  const ServerException(String message, [this.statusCode]) : super(message);
}

/// Cache-related exceptions (local database errors)
class CacheException extends AppException {
  const CacheException([String message = 'Cache exception occurred']) : super(message);
}

/// Connection-related exceptions (no internet connection)
class ConnectionException extends AppException {
  const ConnectionException([String message = 'No internet connection']) : super(message);
}

/// Timeout-related exceptions (request timeout)
class TimeoutException extends AppException {
  const TimeoutException([String message = 'Request timeout']) : super(message);
}

/// Network-related exceptions (general network errors)
class NetworkException extends AppException {
  const NetworkException([String message = 'Network exception occurred']) : super(message);
}

/// Parsing exceptions (JSON parsing errors)
class ParsingException extends AppException {
  const ParsingException([String message = 'Parsing exception occurred']) : super(message);
}

/// Unauthorized exceptions (401, 403)
class UnauthorizedException extends AppException {
  const UnauthorizedException([String message = 'Unauthorized']) : super(message);
}

/// Not found exceptions (404)
class NotFoundException extends AppException {
  const NotFoundException([String message = 'Resource not found']) : super(message);
}
