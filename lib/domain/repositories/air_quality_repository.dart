import '../models/air_quality.dart';
import '../models/location.dart';

abstract class AirQualityRepository {
  Future<AirQualityData> getAirQuality(LocationItem location, {bool forceRefresh = false, bool demoMode = false});
  Future<List<LocationItem>> searchLocations(String query);
  Future<List<AirQualityData>> compareLocations(List<LocationItem> locations, {bool demoMode = false});
}
