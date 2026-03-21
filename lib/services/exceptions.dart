/// Custom exception hierarchy for Swiss Departure Board.
/// All app-level exceptions extend [AppException].
abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);

  @override
  String toString() => '$runtimeType: $message';
}

/// API request timed out.
class ApiTimeoutException extends AppException {
  const ApiTimeoutException() : super('Request timed out');
}

/// Device has no network connection.
class NoNetworkException extends AppException {
  const NoNetworkException() : super('No network connection');
}

/// Server returned a non-200 HTTP status.
class ApiException extends AppException {
  final int statusCode;
  const ApiException(this.statusCode, String message) : super(message);
}

/// API response could not be parsed.
class ApiParseException extends AppException {
  const ApiParseException(String message) : super(message);
}

/// User denied location permission.
class LocationPermissionDeniedException extends AppException {
  const LocationPermissionDeniedException()
      : super('Location permission denied');
}

/// Device location services are disabled.
class LocationServiceDisabledException extends AppException {
  const LocationServiceDisabledException()
      : super('Location service is disabled');
}

/// Location request timed out.
class LocationTimeoutException extends AppException {
  const LocationTimeoutException() : super('Location request timed out');
}
