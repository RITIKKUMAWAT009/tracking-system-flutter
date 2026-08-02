import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';
import '../entities/location_entity.dart';

abstract class LocationRepository {

  Future<Either<Failure, void>> saveLocation(LocationEntity location);

  Future<Either<Failure, List<LocationEntity>>> getLocations();

}
