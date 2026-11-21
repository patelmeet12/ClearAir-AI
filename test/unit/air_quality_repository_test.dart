import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:clearair_ai/core/constants/aqi_standards.dart';
import 'package:clearair_ai/data/datasources/local_storage_service.dart';
import 'package:clearair_ai/data/datasources/open_meteo_aqi_api.dart';
import 'package:clearair_ai/data/repositories_impl/air_quality_repository_impl.dart';
import 'package:clearair_ai/data/repositories_impl/location_repository_impl.dart';
import 'package:clearair_ai/domain/models/air_quality.dart';
import 'package:clearair_ai/domain/models/location.dart';

void main() {
  group('AirQualityRepository & Precedence Fallback Tests', () {
    const testLocation = LocationItem(
      id: 'loc_delhi',
      name: 'Delhi NCR',
      country: 'India',
      latitude: 28.6139,
      longitude: 77.2090,
      tag: LocationTag.home,
    );

    test('Demo mode returns deterministic simulated data', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = LocalStorageService(await SharedPreferences.getInstance());
      final api = OpenMeteoAqiApi();
      final repo = AirQualityRepositoryImpl(api: api, storage: storage);

      final result = await repo.getAirQuality(testLocation, demoMode: true);
      expect(result.dataSourceType, equals(DataSourceType.demo));
      expect(result.locationName, equals('Delhi NCR'));
      expect(result.aqi, greaterThan(0));
    });

    test('Live API call succeeds and caches fresh data', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = LocalStorageService(await SharedPreferences.getInstance());

      final mockClient = MockClient((request) async {
        if (request.url.host == 'air-quality-api.open-meteo.com') {
          return http.Response(
            jsonEncode({
              'current': {
                'us_aqi': 142,
                'pm2_5': 52.4,
                'pm10': 95.0,
                'nitrogen_dioxide': 30.0,
                'sulphur_dioxide': 12.0,
                'carbon_monoxide': 450.0,
                'ozone': 60.0,
              },
              'hourly': {
                'time': ['2026-11-21T12:00:00Z'],
                'us_aqi': [142],
                'pm2_5': [52.4],
              },
            }),
            200,
          );
        } else {
          return http.Response(
            jsonEncode({
              'current': {
                'temperature_2m': 22.5,
                'relative_humidity_2m': 45.0,
                'wind_speed_10m': 8.0,
                'weather_code': 0,
              },
            }),
            200,
          );
        }
      });

      final api = OpenMeteoAqiApi(client: mockClient);
      final repo = AirQualityRepositoryImpl(api: api, storage: storage);

      final fresh = await repo.getAirQuality(testLocation);
      expect(fresh.dataSourceType, equals(DataSourceType.live));
      expect(fresh.aqi, equals(142));
      expect(fresh.pm25, equals(52.4));

      // Verify stored in cache
      final cacheKey = 'aqi_cache_${testLocation.latitude}_${testLocation.longitude}';
      expect(storage.getJson(cacheKey), isNotNull);
    });

    test('Fresh cache (<30 min) is returned without firing network call', () async {
      final cacheKey = 'aqi_cache_${testLocation.latitude}_${testLocation.longitude}';
      final cachedSample = AirQualityData(
        locationName: testLocation.name,
        latitude: testLocation.latitude,
        longitude: testLocation.longitude,
        aqi: 110,
        category: AqiCategory.poor,
        pm25: 40.0,
        pm10: 75.0,
        no2: 20.0,
        so2: 10.0,
        co: 350.0,
        o3: 45.0,
        temperatureC: 21.0,
        humidityPercent: 55.0,
        windSpeedKmh: 12.0,
        weatherCode: 1,
        dataSourceType: DataSourceType.live,
        dataSourceName: 'Open-Meteo Test Data',
        lastUpdated: DateTime.now().subtract(const Duration(minutes: 10)),
        hourlyForecast: const [],
      );

      SharedPreferences.setMockInitialValues({
        cacheKey: jsonEncode(cachedSample.toJson()),
      });
      final storage = LocalStorageService(await SharedPreferences.getInstance());

      // Mock client that would fail if called
      final failClient = MockClient((_) async => http.Response('Error', 500));
      final api = OpenMeteoAqiApi(client: failClient);
      final repo = AirQualityRepositoryImpl(api: api, storage: storage);

      final result = await repo.getAirQuality(testLocation);
      expect(result.dataSourceType, equals(DataSourceType.cached));
      expect(result.aqi, equals(110));
    });

    test('Falls back to offline cache when live network fails', () async {
      final cacheKey = 'aqi_cache_${testLocation.latitude}_${testLocation.longitude}';
      final oldSample = AirQualityData(
        locationName: testLocation.name,
        latitude: testLocation.latitude,
        longitude: testLocation.longitude,
        aqi: 95,
        category: AqiCategory.moderate,
        pm25: 32.0,
        pm10: 60.0,
        no2: 18.0,
        so2: 8.0,
        co: 280.0,
        o3: 35.0,
        temperatureC: 19.0,
        humidityPercent: 60.0,
        windSpeedKmh: 15.0,
        weatherCode: 2,
        dataSourceType: DataSourceType.live,
        dataSourceName: 'Open-Meteo Live API',
        lastUpdated: DateTime.now().subtract(const Duration(hours: 3)), // Old cache
        hourlyForecast: const [],
      );

      SharedPreferences.setMockInitialValues({
        cacheKey: jsonEncode(oldSample.toJson()),
      });
      final storage = LocalStorageService(await SharedPreferences.getInstance());

      // Mock network failure
      final failClient = MockClient((_) async => throw Exception('Socket connection timeout'));
      final api = OpenMeteoAqiApi(client: failClient);
      final repo = AirQualityRepositoryImpl(api: api, storage: storage);

      // forceRefresh triggers live attempt, which fails and gracefully falls back to offline cache
      final result = await repo.getAirQuality(testLocation, forceRefresh: true);
      expect(result.dataSourceType, equals(DataSourceType.cached));
      expect(result.dataSourceName, contains('Offline Cache'));
      expect(result.aqi, equals(95));
    });

    test('Falls back to demo dataset when both network and cache are unavailable', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = LocalStorageService(await SharedPreferences.getInstance());

      final failClient = MockClient((_) async => http.Response('Internal Server Error', 500));
      final api = OpenMeteoAqiApi(client: failClient);
      final repo = AirQualityRepositoryImpl(api: api, storage: storage);

      final result = await repo.getAirQuality(testLocation);
      expect(result.dataSourceType, equals(DataSourceType.demo));
      expect(result.aqi, greaterThan(0));
    });
  });

  group('LocationRepository Dangling Default Key Cleanup Tests', () {
    test('Removing default location reassigns or clears default key in storage', () async {
      const loc1 = LocationItem(id: 'loc_1', name: 'Home', country: 'IN', latitude: 28.0, longitude: 77.0, isDefault: true);
      const loc2 = LocationItem(id: 'loc_2', name: 'Work', country: 'IN', latitude: 28.5, longitude: 77.2);

      SharedPreferences.setMockInitialValues({
        'saved_locations_list': jsonEncode([loc1.toJson(), loc2.toJson()]),
        'default_location_id': 'loc_1',
      });
      final storage = LocalStorageService(await SharedPreferences.getInstance());
      final repo = LocationRepositoryImpl(storage: storage);

      // Remove default location
      await repo.removeLocation('loc_1');

      // Verify loc_1 is removed
      final remaining = await repo.getSavedLocations();
      expect(remaining.length, equals(1));
      expect(remaining.first.id, equals('loc_2'));

      // Verify default ID was reassigned to loc_2, not dangling
      final defaultLoc = await repo.getDefaultLocation();
      expect(defaultLoc?.id, equals('loc_2'));
    });
  });
}
