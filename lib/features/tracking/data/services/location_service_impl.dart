import 'package:background_location_tracker/core/error/failures.dart';
import 'package:background_location_tracker/features/tracking/domain/entities/location_entity.dart';
import 'package:background_location_tracker/features/tracking/domain/services/location_service.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart' as geo;

class LocationServiceImpl implements LocationService {
  const LocationServiceImpl();


  @override
  Future<Either<Failure, LocationEntity>> getCurrentLocation() async {
    try {
      final position = await geo.Geolocator.getCurrentPosition(
        locationSettings: _locationSettings(),
      );

      return Right(_toEntity(position));
    } on geo.LocationServiceDisabledException {
      return const Left(
        LocationServiceDisabledFailure('Location services are disabled.'),
      );
    } on geo.PermissionDeniedException {
      return const Left(
        LocationPermissionFailure('Location permission denied.'),
      );
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Stream<LocationEntity> watchLocation() {
    return geo.Geolocator.getPositionStream(
      locationSettings: _locationSettings(),
    ).map(_toEntity);
  }

  LocationEntity _toEntity(geo.Position position) {
    return LocationEntity(
      latitude: position.latitude,
      longitude: position.longitude,
      timestamp: position.timestamp,
      accuracy: position.accuracy,
    );
  }

  geo.LocationSettings _locationSettings() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return geo.AndroidSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 0,
        intervalDuration: const Duration(seconds: 60),
      );
    }

    if (defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      return geo.AppleSettings(
        accuracy: geo.LocationAccuracy.high,
        distanceFilter: 0,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
        allowBackgroundLocationUpdates: true,
        activityType: geo.ActivityType.otherNavigation,
      );
    }

    return const geo.LocationSettings(
      accuracy: geo.LocationAccuracy.high,
      distanceFilter: 0,
    );
  }
}
