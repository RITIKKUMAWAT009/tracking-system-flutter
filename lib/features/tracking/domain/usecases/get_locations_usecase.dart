import 'package:background_location_tracker/core/error/failures.dart';
import 'package:background_location_tracker/features/tracking/domain/entities/location_entity.dart';
import 'package:background_location_tracker/features/tracking/domain/repositories/location_repository.dart';
import 'package:dartz/dartz.dart';

class GetLocationsUseCase {
  final LocationRepository locationRepository;

  const GetLocationsUseCase(this.locationRepository);

  Future<Either<Failure, List<LocationEntity>>> call()async {
    return await locationRepository.getLocations();
  }
}
