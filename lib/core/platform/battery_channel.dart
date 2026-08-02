import 'package:background_location_tracker/core/constants/app_constants.dart';
import 'package:background_location_tracker/core/error/exceptions.dart';
import 'package:flutter/services.dart';

class BatteryChannel {
  const BatteryChannel();

  static const MethodChannel _channel = MethodChannel(
    AppConstants.batteryChannelName,
  );

  Future<int> getBatteryPercentage() async {
    try {
      final level = await _channel.invokeMethod<int>(
        AppConstants.getBatteryMethod,
      );

      if (level == null) {
        throw const PlatformChannelException('Battery level is unavailable.');
      }

      return level;
    } on PlatformException catch (e) {
      throw PlatformChannelException(
        e.message ?? 'Failed to read battery level.',
      );
    }
  }
}
