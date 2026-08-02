import 'package:background_location_tracker/core/error/exceptions.dart';
import 'package:background_location_tracker/core/error/failures.dart';
import 'package:background_location_tracker/core/platform/battery_channel.dart';
import 'package:background_location_tracker/features/tracking/domain/services/battery_service.dart';
import 'package:dartz/dartz.dart';

class BatteryServiceImpl implements BatteryService {
  final BatteryChannel batteryChannel;

  const BatteryServiceImpl(this.batteryChannel);

  @override
  Future<Either<Failure, int>> getBatteryPercentage() async {
    try {
      final batteryLevel = await batteryChannel.getBatteryPercentage();
      return Right(batteryLevel);
    } on PlatformChannelException catch (e) {
      return Left(PlatformFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }
}
