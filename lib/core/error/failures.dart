abstract class Failure {
  final String message;

  const Failure(this.message);

  @override
  String toString() => message;
}

class LocationPermissionFailure extends Failure {
  const LocationPermissionFailure(super.message);
}

class LocationServiceDisabledFailure extends Failure {
  const LocationServiceDisabledFailure(super.message);
}

class CacheFailure extends Failure {
  const CacheFailure(super.message);
}

class PlatformFailure extends Failure {
  const PlatformFailure(super.message);
}

class UnknownFailure extends Failure {
  const UnknownFailure(super.message);
}
