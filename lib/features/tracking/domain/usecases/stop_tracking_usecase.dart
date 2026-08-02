import 'package:background_location_tracker/core/error/failures.dart';
import 'package:background_location_tracker/features/tracking/domain/services/tracking_service.dart';
import 'package:dartz/dartz.dart';

class StopTrackingUseCase {
  final TrackingService trackingService;

  const StopTrackingUseCase(this.trackingService);

  Future<Either<Failure, void>> call()async {
    return await trackingService.stop();
  }
}
