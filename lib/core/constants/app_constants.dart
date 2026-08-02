class AppConstants {
  const AppConstants._();

  static const locationBox = 'locations';
  static const batteryChannelName = 'background_location_tracker/battery';
  static const getBatteryMethod = 'getBatteryLevel';
  static const batteryRefreshIntervalSeconds = 30;
  static const disablePermission =
      'Location services are disabled. Please enable GPS.';
  static const locationPermissionException =
      'Location permission permanently denied. Please enable it from Settings.';
  static const locationPermissionDenied = 'Location permission denied.';
  static const locationAlwaysPermissionRequired =
      'Always / Allow all the time location permission is required for background tracking. Enable it in Settings.';
  static const notificationPermissionRequired =
      'Notification permission is required to run location tracking in the background on Android.';
}
