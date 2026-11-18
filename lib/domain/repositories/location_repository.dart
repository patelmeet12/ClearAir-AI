import '../models/location.dart';

abstract class LocationRepository {
  Future<List<LocationItem>> getSavedLocations();
  Future<void> saveLocation(LocationItem location);
  Future<void> removeLocation(String id);
  Future<LocationItem?> getDefaultLocation();
  Future<void> setDefaultLocation(String id);
}
