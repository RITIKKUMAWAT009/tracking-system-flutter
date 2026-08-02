import 'dart:async';
import 'dart:ui';

import 'package:background_location_tracker/features/tracking/data/datasources/location_local_datasource_impl.dart';
import 'package:background_location_tracker/features/tracking/data/repositories/tracking_repository_impl.dart';
import 'package:background_location_tracker/features/tracking/data/services/location_service_impl.dart';
import 'package:background_location_tracker/features/tracking/domain/entities/location_entity.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_background_service/flutter_background_service.dart';

class BackgroundTrackingService {
  const BackgroundTrackingService();

  Future<void> initialize() async {
    final service = FlutterBackgroundService();

    await service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: false,
        isForegroundMode: true,
        autoStartOnBoot: false,
        notificationChannelId: 'location_tracking',
        initialNotificationTitle: 'Location tracking active',
        initialNotificationContent: 'Collecting location updates in background',
        foregroundServiceNotificationId: 888,
        foregroundServiceTypes: const [AndroidForegroundType.location],
      ),
      iosConfiguration: IosConfiguration(
        autoStart: false,
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );
  }
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  // Brief BGAppRefresh wakeup only — continuous iOS tracking runs via
  // the main-isolate position stream with allowBackgroundLocationUpdates.
  final locationService = const LocationServiceImpl();
  final locationRepository = TrackingRepositoryImpl(
    const LocationLocalDatasourceImpl(),
  );

  final result = await locationService.getCurrentLocation();
  await result.fold((_) async {}, (LocationEntity location) async {
    await locationRepository.saveLocation(location);
  });

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  final locationService = const LocationServiceImpl();
  final locationRepository = TrackingRepositoryImpl(
    const LocationLocalDatasourceImpl(),
  );

  StreamSubscription<LocationEntity>? locationSubscription;

  Future<void> saveLocation(LocationEntity location) async {
    await locationRepository.saveLocation(location);

    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        await service.setForegroundNotificationInfo(
          title: 'Location tracking active',
          content:
              '${location.latitude.toStringAsFixed(5)}, '
              '${location.longitude.toStringAsFixed(5)}',
        );
      }
    }
  }

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) async {
    await locationSubscription?.cancel();
    service.stopSelf();
  });

  locationSubscription = locationService.watchLocation().listen(
    saveLocation,
    onError: (_) {},
  );
}
