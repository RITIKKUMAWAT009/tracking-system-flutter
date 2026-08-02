import 'package:background_location_tracker/core/error/failures.dart';
import 'package:background_location_tracker/features/tracking/domain/services/tracking_service.dart';
import 'package:dartz/dartz.dart';

class StartTrackingUseCase {
  final TrackingService trackingService;

  const StartTrackingUseCase(this.trackingService);

  Future<Either<Failure, void>> call() async{
    return await trackingService.start();
  }
}
