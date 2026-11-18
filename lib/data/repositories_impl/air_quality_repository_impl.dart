import '../../domain/models/air_quality.dart';
import '../../domain/models/location.dart';
import '../../domain/repositories/air_quality_repository.dart';
import '../datasources/open_meteo_aqi_api.dart';
import '../datasources/demo_data_provider.dart';
import '../datasources/local_storage_service.dart';

class AirQualityRepositoryImpl implements AirQualityRepository {
  final OpenMeteoAqiApi _api;
  final LocalStorageService _storage;

  AirQualityRepositoryImpl({
    required OpenMeteoAqiApi api,
    required LocalStorageService storage,
  })  : _api = api,
        _storage = storage;

  @override
  Future<AirQualityData> getAirQuality(
    LocationItem location, {
    bool forceRefresh = false,
    bool demoMode = false,
  }) async {
    if (demoMode) {
      return DemoDataProvider.getDemoAirQuality(location);
    }

    // Check cached data if not forcing refresh
    final cacheKey = 'aqi_cache_${location.latitude}_${location.longitude}';
    if (!forceRefresh) {
      final cachedJson = _storage.getJson(cacheKey);
      if (cachedJson != null) {
        try {
          final cachedData = AirQualityData.fromJson(cachedJson);
          // If cached within 30 minutes, reuse with cached badge
          if (DateTime.now().difference(cachedData.lastUpdated).inMinutes < 30) {
            return AirQualityData(
              locationName: cachedData.locationName,
              latitude: cachedData.latitude,
              longitude: cachedData.longitude,
              aqi: cachedData.aqi,
              category: cachedData.category,
              pm25: cachedData.pm25,
              pm10: cachedData.pm10,
              no2: cachedData.no2,
              so2: cachedData.so2,
              co: cachedData.co,
              o3: cachedData.o3,
              temperatureC: cachedData.temperatureC,
              humidityPercent: cachedData.humidityPercent,
              windSpeedKmh: cachedData.windSpeedKmh,
              weatherCode: cachedData.weatherCode,
              dataSourceType: DataSourceType.cached,
              dataSourceName: '${cachedData.dataSourceName} (Cached)',
              lastUpdated: cachedData.lastUpdated,
              hourlyForecast: cachedData.hourlyForecast,
            );
          }
        } catch (_) {}
      }
    }

    try {
      final fresh = await _api.fetchAirQuality(location);
      await _storage.setJson(cacheKey, fresh.toJson());
      return fresh;
    } catch (_) {
      // Return cached if available, else demo fallback
      final cachedJson = _storage.getJson(cacheKey);
      if (cachedJson != null) {
        try {
          return AirQualityData.fromJson(cachedJson);
        } catch (_) {}
      }
      return DemoDataProvider.getDemoAirQuality(location);
    }
  }

  @override
  Future<List<LocationItem>> searchLocations(String query) async {
    return _api.searchGeocoding(query);
  }

  @override
  Future<List<AirQualityData>> compareLocations(List<LocationItem> locations, {bool demoMode = false}) async {
    final List<AirQualityData> list = [];
    for (final loc in locations) {
      final data = await getAirQuality(loc, demoMode: demoMode);
      list.add(data);
    }
    return list;
  }
}
