import 'package:background_location_tracker/core/error/failures.dart';
import 'package:background_location_tracker/features/tracking/domain/entities/location_entity.dart';
import 'package:background_location_tracker/features/tracking/domain/services/location_service.dart';
import 'package:dartz/dartz.dart';

class GetCurrentLocationUseCase {
  final LocationService locationService;

  const GetCurrentLocationUseCase(this.locationService);

  Future<Either<Failure, LocationEntity>> call() {
    return locationService.getCurrentLocation();
  }
}
