import 'package:background_location_tracker/core/error/failures.dart';
import 'package:dartz/dartz.dart';

abstract class TrackingService {
  Future<Either<Failure, void>> start();

  Future<Either<Failure, void>> stop();
}
