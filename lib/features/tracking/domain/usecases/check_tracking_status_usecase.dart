
import 'package:background_location_tracker/core/error/failures.dart';
import 'package:background_location_tracker/features/tracking/domain/services/tracking_service.dart';
import 'package:dartz/dartz.dart';

class CheckTrackingStatusUseCase {
  final TrackingService trackingService;

  const CheckTrackingStatusUseCase(this.trackingService);

  Future<Either<Failure, bool>> call() async{
    return await trackingService.isTracking();
  }
}
