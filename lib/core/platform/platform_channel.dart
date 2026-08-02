import 'dart:io';

import 'package:flutter/services.dart';

class PlatformChannel {
  const PlatformChannel();

  static const _channel = MethodChannel('background_location_tracker/platform');

  /// Returns true when notifications can be shown (required for Android FGS).
  Future<bool> requestNotificationPermission() async {
    if (!Platform.isAndroid) {
      return true;
    }

    try {
      final granted = await _channel.invokeMethod<bool>(
        'requestNotificationPermission',
      );
      return granted ?? false;
    } on PlatformException {
      return false;
    }
  }
}
