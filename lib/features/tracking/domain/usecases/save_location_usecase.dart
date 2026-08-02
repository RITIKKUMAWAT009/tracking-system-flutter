import 'package:background_location_tracker/core/error/failures.dart';
import 'package:background_location_tracker/features/tracking/domain/entities/location_entity.dart';
import 'package:background_location_tracker/features/tracking/domain/repositories/location_repository.dart';
import 'package:dartz/dartz.dart';

class SaveLocationUseCase {
  final LocationRepository locationRepository;

  const SaveLocationUseCase(this.locationRepository);

  Future<Either<Failure, void>> call(LocationEntity location) {
    return locationRepository.saveLocation(location);
  }
}
