import 'package:background_location_tracker/features/tracking/domain/entities/location_entity.dart';
import 'package:equatable/equatable.dart';

abstract class TrackingEvent extends Equatable {
  const TrackingEvent();

  @override
  List<Object?> get props => [];
}
class CheckTrackingStatusRequested extends TrackingEvent {
  const CheckTrackingStatusRequested();
}

class SaveLocationRequested extends TrackingEvent {
  final LocationEntity location;

  const SaveLocationRequested(this.location);

  @override
  List<Object?> get props => [location];
}

class LoadLocationsRequested extends TrackingEvent {
  const LoadLocationsRequested();
}

class StartTrackingRequested extends TrackingEvent {
  const StartTrackingRequested();
}

class StopTrackingRequested extends TrackingEvent {
  const StopTrackingRequested();
}

class BatteryRequested extends TrackingEvent {
  const BatteryRequested();
}
