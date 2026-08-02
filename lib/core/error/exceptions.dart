abstract class AppException implements Exception {
  final String message;

  const AppException(this.message);

  @override
  String toString() => message;
}

class LocationPermissionException extends AppException {
  const LocationPermissionException(super.message);
}

class LocationDisabledException extends AppException {
  const LocationDisabledException(super.message);
}

class CacheException extends AppException {
  const CacheException(super.message);
}

class PlatformChannelException extends AppException {
  const PlatformChannelException(super.message);
}

class UnknownException extends AppException {
  const UnknownException(super.message);
}
