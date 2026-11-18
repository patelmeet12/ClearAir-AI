import '../../core/constants/aqi_standards.dart';
import '../../domain/models/air_quality.dart';
import '../../domain/models/location.dart';

class DemoDataProvider {
  static final List<LocationItem> defaultDemoLocations = [
    const LocationItem(
      id: 'demo_delhi',
      name: 'Delhi NCR',
      country: 'India',
      latitude: 28.6139,
      longitude: 77.2090,
      tag: LocationTag.home,
      isDefault: true,
    ),
    const LocationItem(
      id: 'demo_los_angeles',
      name: 'Los Angeles, CA',
      country: 'United States',
      latitude: 34.0522,
      longitude: -118.2437,
      tag: LocationTag.workplace,
    ),
    const LocationItem(
      id: 'demo_london',
      name: 'London',
      country: 'United Kingdom',
      latitude: 51.5074,
      longitude: -0.1278,
      tag: LocationTag.other,
    ),
    const LocationItem(
      id: 'demo_beijing',
      name: 'Beijing',
      country: 'China',
      latitude: 39.9042,
      longitude: 116.4074,
      tag: LocationTag.other,
    ),
    const LocationItem(
      id: 'demo_zurich',
      name: 'Zurich',
      country: 'Switzerland',
      latitude: 47.3769,
      longitude: 8.5417,
      tag: LocationTag.other,
    ),
  ];

  static AirQualityData getDemoAirQuality(LocationItem location) {
    final now = DateTime.now();
    // Deterministic simulation based on location
    if (location.name.toLowerCase().contains('delhi')) {
      return AirQualityData(
        locationName: location.name,
        latitude: location.latitude,
        longitude: location.longitude,
        aqi: 382,
        category: AqiCategory.severe,
        pm25: 334.5,
        pm10: 480.2,
        no2: 88.4,
        so2: 24.1,
        co: 2850.0,
        o3: 32.0,
        temperatureC: 16.5,
        humidityPercent: 78.0,
        windSpeedKmh: 4.2,
        weatherCode: 45, // Fog / Smog
        dataSourceType: DataSourceType.demo,
        dataSourceName: 'ClearAir Demo Dataset (Simulated Winter Inversion Smog)',
        lastUpdated: now.subtract(const Duration(minutes: 8)),
        hourlyForecast: _generateForecast(382, 334.5, now),
      );
    } else if (location.name.toLowerCase().contains('los angeles')) {
      return AirQualityData(
        locationName: location.name,
        latitude: location.latitude,
        longitude: location.longitude,
        aqi: 118,
        category: AqiCategory.poor,
        pm25: 42.1,
        pm10: 68.0,
        no2: 38.0,
        so2: 4.5,
        co: 720.0,
        o3: 84.5,
        temperatureC: 24.0,
        humidityPercent: 52.0,
        windSpeedKmh: 12.0,
        weatherCode: 1, // Sunny / Haze
        dataSourceType: DataSourceType.demo,
        dataSourceName: 'ClearAir Demo Dataset (Simulated Ozone Season)',
        lastUpdated: now.subtract(const Duration(minutes: 15)),
        hourlyForecast: _generateForecast(118, 42.1, now),
      );
    } else if (location.name.toLowerCase().contains('london')) {
      return AirQualityData(
        locationName: location.name,
        latitude: location.latitude,
        longitude: location.longitude,
        aqi: 62,
        category: AqiCategory.moderate,
        pm25: 17.5,
        pm10: 29.0,
        no2: 32.5,
        so2: 6.2,
        co: 410.0,
        o3: 45.0,
        temperatureC: 8.5,
        humidityPercent: 84.0,
        windSpeedKmh: 18.5,
        weatherCode: 3, // Overcast
        dataSourceType: DataSourceType.demo,
        dataSourceName: 'ClearAir Demo Dataset (Simulated Moderate Urban)',
        lastUpdated: now.subtract(const Duration(minutes: 22)),
        hourlyForecast: _generateForecast(62, 17.5, now),
      );
    } else if (location.name.toLowerCase().contains('beijing')) {
      return AirQualityData(
        locationName: location.name,
        latitude: location.latitude,
        longitude: location.longitude,
        aqi: 215,
        category: AqiCategory.veryPoor,
        pm25: 165.0,
        pm10: 240.0,
        no2: 65.0,
        so2: 18.0,
        co: 1900.0,
        o3: 28.0,
        temperatureC: 2.0,
        humidityPercent: 60.0,
        windSpeedKmh: 7.0,
        weatherCode: 45, // Fog
        dataSourceType: DataSourceType.demo,
        dataSourceName: 'ClearAir Demo Dataset (Simulated Winter Heating Inversion)',
        lastUpdated: now.subtract(const Duration(minutes: 10)),
        hourlyForecast: _generateForecast(215, 165.0, now),
      );
    } else {
      // Default clean / moderate
      return AirQualityData(
        locationName: location.name,
        latitude: location.latitude,
        longitude: location.longitude,
        aqi: 32,
        category: AqiCategory.good,
        pm25: 7.8,
        pm10: 14.2,
        no2: 12.0,
        so2: 2.1,
        co: 250.0,
        o3: 42.0,
        temperatureC: 14.0,
        humidityPercent: 55.0,
        windSpeedKmh: 10.0,
        weatherCode: 0, // Clear
        dataSourceType: DataSourceType.demo,
        dataSourceName: 'ClearAir Demo Dataset (Clean Baseline)',
        lastUpdated: now.subtract(const Duration(minutes: 5)),
        hourlyForecast: _generateForecast(32, 7.8, now),
      );
    }
  }

  static List<HourlyAqiPoint> _generateForecast(int baseAqi, double basePm25, DateTime start) {
    final List<HourlyAqiPoint> points = [];
    // 24 hour forecast variation simulating diurnal curve (peak morning 8am and night 9pm, dip midday)
    for (int i = 0; i < 24; i++) {
      final t = start.add(Duration(hours: i));
      final hour = t.hour;
      double factor = 1.0;
      if (hour >= 7 && hour <= 10) {
        factor = 1.25; // Morning rush + inversion peak
      } else if (hour >= 13 && hour <= 16) {
        factor = 0.8; // Afternoon solar mixing dip
      } else if (hour >= 20 && hour <= 23) {
        factor = 1.35; // Night cooling boundary layer collapse
      } else if (hour >= 0 && hour <= 5) {
        factor = 1.15;
      }

      final int aqi = (baseAqi * factor).round().clamp(10, 500);
      final double pm25 = (basePm25 * factor).clamp(2.0, 600.0);
      points.add(HourlyAqiPoint(time: t, aqi: aqi, pm25: pm25));
    }
    return points;
  }
}
