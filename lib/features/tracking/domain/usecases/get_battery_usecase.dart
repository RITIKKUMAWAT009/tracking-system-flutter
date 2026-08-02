import 'package:background_location_tracker/core/error/failures.dart';
import 'package:background_location_tracker/features/tracking/domain/services/battery_service.dart';
import 'package:dartz/dartz.dart';

class GetBatteryUseCase {
  final BatteryService batteryService;

  const GetBatteryUseCase(this.batteryService);

  Future<Either<Failure, int>> call() async{
    return await batteryService.getBatteryPercentage();
  }
}
