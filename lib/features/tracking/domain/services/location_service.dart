import 'package:background_location_tracker/core/error/failures.dart';
import 'package:background_location_tracker/features/tracking/domain/entities/location_entity.dart';
import 'package:dartz/dartz.dart';

abstract class LocationService {
  Future<Either<Failure, LocationEntity>> getCurrentLocation();

  /// Continuous stream used for background / killed-app tracking.
  Stream<LocationEntity> watchLocation();
}
