import 'dart:async';
import 'dart:io';

import 'package:background_location_tracker/core/constants/app_constants.dart';
import 'package:background_location_tracker/core/error/exceptions.dart';
import 'package:background_location_tracker/core/error/failures.dart';
import 'package:background_location_tracker/core/platform/platform_channel.dart';
import 'package:background_location_tracker/features/tracking/domain/repositories/location_repository.dart';
import 'package:background_location_tracker/features/tracking/domain/services/location_service.dart';
import 'package:background_location_tracker/features/tracking/domain/services/tracking_service.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';

class TrackingServiceImpl implements TrackingService {
  TrackingServiceImpl(
    this._locationService,
    this._locationRepository,
    this._platformChannel,
  );

  final LocationService _locationService;
  final LocationRepository _locationRepository;
  final PlatformChannel _platformChannel;

  StreamSubscription? _iosLocationSubscription;
@override
Future<Either<Failure, bool>> isTracking() async {
  try {
    final running = await FlutterBackgroundService().isRunning();

    return Right(running);
  } catch (e) {
    return Left(UnknownFailure(e.toString()));
  }
}
  @override
  Future<Either<Failure, void>> start() async {
    try {
      await _ensurePermissions();

      if (Platform.isAndroid) {
        final notificationsGranted =
            await _platformChannel.requestNotificationPermission();
        if (!notificationsGranted) {
          throw const LocationPermissionException(
            AppConstants.notificationPermissionRequired,
          );
        }

        final service = FlutterBackgroundService();
        final isRunning = await service.isRunning();
        if (!isRunning) {
          await service.startService();
        }
      } else if (Platform.isIOS) {
        // iOS has no long-running background service. Continuous updates
        // require an active CLLocationManager stream with Always permission
        // and UIBackgroundModes=location.
        await _iosLocationSubscription?.cancel();
        _iosLocationSubscription = _locationService.watchLocation().listen(
          (location) async {
            await _locationRepository.saveLocation(location);
          },
          onError: (_) {},
        );
      }

      return const Right(null);
    } on LocationPermissionException catch (e) {
      return Left(LocationPermissionFailure(e.message));
    } on LocationDisabledException catch (e) {
      return Left(LocationServiceDisabledFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> stop() async {
    try {
      if (Platform.isAndroid) {
        final service = FlutterBackgroundService();
        final isRunning = await service.isRunning();
        if (isRunning) {
          service.invoke('stopService');
        }
      } else if (Platform.isIOS) {
        await _iosLocationSubscription?.cancel();
        _iosLocationSubscription = null;
      }

      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<void> _ensurePermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationDisabledException(AppConstants.disablePermission);
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw const LocationPermissionException(
        AppConstants.locationPermissionDenied,
      );
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      throw const LocationPermissionException(
        AppConstants.locationPermissionException,
      );
    }

    // Upgrade When In Use → Always (required for background / killed tracking).
    if (permission == LocationPermission.whileInUse) {
      permission = await Geolocator.requestPermission();
    }

    if (permission != LocationPermission.always) {
      await Geolocator.openAppSettings();
      throw const LocationPermissionException(
        AppConstants.locationAlwaysPermissionRequired,
      );
    }
  }
}
