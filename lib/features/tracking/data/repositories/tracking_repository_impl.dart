import 'package:background_location_tracker/core/error/exceptions.dart';
import 'package:background_location_tracker/core/error/failures.dart';
import 'package:background_location_tracker/features/tracking/data/datasources/location_local_datasource.dart';
import 'package:background_location_tracker/features/tracking/data/models/location_model.dart';
import 'package:background_location_tracker/features/tracking/domain/entities/location_entity.dart';
import 'package:background_location_tracker/features/tracking/domain/repositories/location_repository.dart';
import 'package:dartz/dartz.dart';

class TrackingRepositoryImpl implements LocationRepository {
  final LocationLocalDataSource localDataSource;

  TrackingRepositoryImpl(this.localDataSource);

  @override
  Future<Either<Failure, List<LocationEntity>>> getLocations() async {
    try {
      final locations = await localDataSource.getLocations();
      return Right(locations);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveLocation(
    LocationEntity location,
  ) async {
    try {
      final model = LocationModel(
        latitude: location.latitude,
        longitude: location.longitude,
        timestamp: location.timestamp,
        accuracy: location.accuracy,
      );

      await localDataSource.saveLocation(model);

      return const Right(null);
    } on CacheException catch (e) {
      return Left(CacheFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }


}
