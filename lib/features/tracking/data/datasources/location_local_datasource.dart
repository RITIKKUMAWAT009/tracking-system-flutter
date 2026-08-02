import 'package:background_location_tracker/features/tracking/data/models/location_model.dart';

abstract class LocationLocalDataSource {
  Future<void> saveLocation(LocationModel location);

  Future<List<LocationModel>> getLocations();

  Future<void> clearLocations();
}
