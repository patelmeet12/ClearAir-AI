import '../../core/utils/app_logger.dart';
import '../../domain/models/air_quality.dart';
import '../../domain/models/location.dart';
import '../../domain/repositories/air_quality_repository.dart';
import '../datasources/demo_data_provider.dart';
import '../datasources/local_storage_service.dart';
import '../datasources/open_meteo_aqi_api.dart';

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

    final cacheKey = 'aqi_cache_${location.latitude}_${location.longitude}';

    // 1. Check cached data if not forcing refresh
    if (!forceRefresh) {
      final cachedJson = _storage.getJson(cacheKey);
      if (cachedJson != null) {
        try {
          final cachedData = AirQualityData.fromJson(cachedJson);
          // If cached within 30 minutes, reuse with cached badge
          if (DateTime.now().difference(cachedData.lastUpdated).inMinutes < 30) {
            return cachedData.copyWith(
              dataSourceType: DataSourceType.cached,
              dataSourceName: '${cachedData.dataSourceName} (Cached)',
            );
          }
        } catch (e) {
          AppLogger.warning('Failed to parse cached air quality data for ${location.name}', e);
        }
      }
    }

    // 2. Fetch fresh live telemetry from network
    try {
      final fresh = await _api.fetchAirQuality(location);
      if (fresh.dataSourceType == DataSourceType.live) {
        await _storage.setJson(cacheKey, fresh.toJson());
      }
      return fresh;
    } catch (e) {
      AppLogger.warning('Live telemetry fetch failed for ${location.name}. Attempting cache fallback.', e);

      // 3. Fallback to offline cache if network call fails
      final cachedJson = _storage.getJson(cacheKey);
      if (cachedJson != null) {
        try {
          final cachedData = AirQualityData.fromJson(cachedJson);
          return cachedData.copyWith(
            dataSourceType: DataSourceType.cached,
            dataSourceName: '${cachedData.dataSourceName} (Offline Cache)',
          );
        } catch (cacheParseError) {
          AppLogger.warning('Corrupted offline cache for ${location.name}', cacheParseError);
        }
      }

      // 4. Final fallback to deterministic demo dataset if no cache exists
      AppLogger.info('Using fallback demo dataset for ${location.name}');
      return DemoDataProvider.getDemoAirQuality(location);
    }
  }

  @override
  Future<List<LocationItem>> searchLocations(String query) async {
    return _api.searchGeocoding(query);
  }

  @override
  Future<List<AirQualityData>> compareLocations(
    List<LocationItem> locations, {
    bool demoMode = false,
  }) async {
    final List<AirQualityData> list = [];
    for (final loc in locations) {
      final data = await getAirQuality(loc, demoMode: demoMode);
      list.add(data);
    }
    return list;
  }
}
