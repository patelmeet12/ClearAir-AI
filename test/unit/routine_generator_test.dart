import 'package:flutter_test/flutter_test.dart';
import 'package:clearair_ai/core/constants/aqi_standards.dart';
import 'package:clearair_ai/data/datasources/local_storage_service.dart';
import 'package:clearair_ai/data/repositories_impl/routine_repository_impl.dart';
import 'package:clearair_ai/domain/models/air_quality.dart';
import 'package:clearair_ai/domain/models/household_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('RoutineRepository & Safe Routine Generation Tests', () {
    late RoutineRepositoryImpl repository;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorageService.init();
      repository = RoutineRepositoryImpl(storage: storage);
    });

    test('Never recommends outdoor cycling or running during severe smog (AQI >= 200)', () async {
      final severeAqi = AirQualityData(
        locationName: 'Delhi NCR',
        latitude: 28.61,
        longitude: 77.20,
        aqi: 380,
        category: AqiCategory.severe,
        pm25: 320.0,
        pm10: 450.0,
        no2: 80.0,
        so2: 20.0,
        co: 2500.0,
        o3: 30.0,
        temperatureC: 15.0,
        humidityPercent: 80.0,
        windSpeedKmh: 4.0,
        weatherCode: 45,
        dataSourceType: DataSourceType.demo,
        dataSourceName: 'Test Demo',
        lastUpdated: DateTime.now(),
        hourlyForecast: const [],
      );

      const profile = HouseholdProfile(children: 1, olderAdults: 1);

      final routines = await repository.generateDailyRoutines(
        airQuality: severeAqi,
        profile: profile,
      );

      expect(routines, isNotEmpty);

      // Verify no routine recommends outdoor running or cycling
      for (final r in routines) {
        expect(r.title.toLowerCase().contains('cycle'), isFalse, reason: 'Must not advise outdoor cycling in severe smog');
        expect(r.title.toLowerCase().contains('walk in park'), isFalse, reason: 'Must not advise outdoor walks in severe smog');
      }

      // Verify morning commute recommends protected transit with N95
      final morning = routines.firstWhere((r) => r.timeSlot.name == 'morning');
      expect(morning.title, contains('N95'));
      expect(morning.title, contains('Metro'));
    });

    test('Recommends active green commute when AQI is Good (< 50)', () async {
      final cleanAqi = AirQualityData(
        locationName: 'Zurich Alpine',
        latitude: 47.37,
        longitude: 8.54,
        aqi: 28,
        category: AqiCategory.good,
        pm25: 6.5,
        pm10: 12.0,
        no2: 10.0,
        so2: 2.0,
        co: 200.0,
        o3: 40.0,
        temperatureC: 18.0,
        humidityPercent: 50.0,
        windSpeedKmh: 12.0,
        weatherCode: 0,
        dataSourceType: DataSourceType.demo,
        dataSourceName: 'Test Demo Clean',
        lastUpdated: DateTime.now(),
        hourlyForecast: const [],
      );

      const profile = HouseholdProfile(children: 0, olderAdults: 0);

      final routines = await repository.generateDailyRoutines(
        airQuality: cleanAqi,
        profile: profile,
      );

      final morning = routines.firstWhere((r) => r.timeSlot.name == 'morning');
      expect(morning.title, contains('Active Green Commute'));
    });
  });
}
