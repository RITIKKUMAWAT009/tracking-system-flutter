import 'package:dartz/dartz.dart';

import '../../../../core/error/failures.dart';

abstract class BatteryService {
  Future<Either<Failure, int>> getBatteryPercentage();
}
