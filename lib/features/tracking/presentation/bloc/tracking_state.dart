import 'package:background_location_tracker/core/utils/app_enums.dart';
import 'package:background_location_tracker/features/tracking/domain/entities/location_entity.dart';
import 'package:equatable/equatable.dart';


class TrackingState extends Equatable {
  final TrackingStatus status;
  final List<LocationEntity> locations;
  final int batteryPercentage;
  final String? errorMessage;
  final bool isTracking;

  const TrackingState({
    this.status = TrackingStatus.initial,
    this.locations = const [],
    this.batteryPercentage = 0,
    this.errorMessage,
    this.isTracking = false,
  });

  TrackingState copyWith({
    TrackingStatus? status,
    List<LocationEntity>? locations,
    int? batteryPercentage,
    String? errorMessage,
    bool? isTracking,
  }) {
    return TrackingState(
      status: status ?? this.status,
      locations: locations ?? this.locations,
      batteryPercentage: batteryPercentage ?? this.batteryPercentage,
      errorMessage: errorMessage,
      isTracking: isTracking ?? this.isTracking,
    );
  }

  @override
  List<Object?> get props => [
        status,
        locations,
        batteryPercentage,
        errorMessage,
        isTracking,
      ];
}
