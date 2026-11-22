import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/aqi_standards.dart';
import '../../core/errors/api_exception.dart';
import '../../core/utils/app_logger.dart';
import '../../core/utils/aqi_calculator.dart';
import '../../core/utils/pollutant_standards.dart';
import '../../domain/models/air_quality.dart';
import '../../domain/models/location.dart';
import 'demo_data_provider.dart';

class OpenMeteoAqiApi {
  final http.Client _client;

  OpenMeteoAqiApi({http.Client? client}) : _client = client ?? http.Client();

  Future<AirQualityData> fetchAirQuality(LocationItem location) async {
    // Validate coordinates
    if (location.latitude.isNaN ||
        location.latitude < -90.0 ||
        location.latitude > 90.0 ||
        location.longitude.isNaN ||
        location.longitude < -180.0 ||
        location.longitude > 180.0) {
      throw ApiException(
        'Invalid coordinates (${location.latitude}, ${location.longitude}) for ${location.name}',
      );
    }

    final aqiUri = Uri.parse(
      'https://air-quality-api.open-meteo.com/v1/air-quality'
      '?latitude=${location.latitude}&longitude=${location.longitude}'
      '&current=pm10,pm2_5,carbon_monoxide,nitrogen_dioxide,sulphur_dioxide,ozone,us_aqi'
      '&hourly=pm10,pm2_5,us_aqi&forecast_days=2',
    );

    final weatherUri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=${location.latitude}&longitude=${location.longitude}'
      '&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m',
    );

    try {
      final responses = await Future.wait([
        _client.get(aqiUri).timeout(const Duration(seconds: 7)),
        _client.get(weatherUri).timeout(const Duration(seconds: 7)),
      ]);

      final aqiRes = responses[0];
      final weatherRes = responses[1];

      if (aqiRes.statusCode != 200) {
        throw ApiException(
          'Open-Meteo Air Quality API failed with status ${aqiRes.statusCode}',
          statusCode: aqiRes.statusCode,
        );
      }

      final aqiJson = jsonDecode(aqiRes.body) as Map<String, dynamic>;
      final currentAqi = aqiJson['current'] as Map<String, dynamic>? ?? {};

      double tempC = 20.0;
      double humidity = 50.0;
      double windKmh = 10.0;
      int weatherCode = 0;

      if (weatherRes.statusCode == 200) {
        try {
          final weatherJson = jsonDecode(weatherRes.body) as Map<String, dynamic>;
          final currentW = weatherJson['current'] as Map<String, dynamic>? ?? {};
          tempC = PollutantStandards.sanitize(currentW['temperature_2m'] as num?, defaultValue: 20.0);
          humidity = PollutantStandards.sanitize(currentW['relative_humidity_2m'] as num?, defaultValue: 50.0);
          windKmh = PollutantStandards.sanitize(currentW['wind_speed_10m'] as num?, defaultValue: 10.0);
          weatherCode = (currentW['weather_code'] as num?)?.toInt() ?? 0;
        } catch (e) {
          AppLogger.warning('Weather metadata parse non-fatal fallback', e);
        }
      }

      final double pm25 = PollutantStandards.sanitize(currentAqi['pm2_5'] as num?, defaultValue: 12.0);
      final double pm10 = PollutantStandards.sanitize(currentAqi['pm10'] as num?, defaultValue: 25.0);
      final double no2 = PollutantStandards.sanitize(currentAqi['nitrogen_dioxide'] as num?, defaultValue: 15.0);
      final double so2 = PollutantStandards.sanitize(currentAqi['sulphur_dioxide'] as num?, defaultValue: 5.0);
      final double co = PollutantStandards.sanitize(currentAqi['carbon_monoxide'] as num?, defaultValue: 300.0);
      final double o3 = PollutantStandards.sanitize(currentAqi['ozone'] as num?, defaultValue: 40.0);

      // Extract or compute US AQI
      int aqi = (currentAqi['us_aqi'] as num?)?.toInt() ?? 0;
      if (aqi <= 0) {
        aqi = AqiCalculator.calculateAqi(pm25: pm25, pm10: pm10, standard: AqiStandard.usEpa);
      }

      // Parse hourly forecast
      final hourlyMap = aqiJson['hourly'] as Map<String, dynamic>?;
      final List<HourlyAqiPoint> points = [];
      if (hourlyMap != null) {
        final timeList = hourlyMap['time'] as List<dynamic>? ?? [];
        final aqiList = hourlyMap['us_aqi'] as List<dynamic>? ?? [];
        final pm25List = hourlyMap['pm2_5'] as List<dynamic>? ?? [];

        final limit = timeList.length < 24 ? timeList.length : 24;
        for (int i = 0; i < limit; i++) {
          final ptPm25 = (pm25List.length > i && pm25List[i] != null)
              ? PollutantStandards.sanitize(pm25List[i] as num?, defaultValue: pm25)
              : pm25;
          final ptAqi = (aqiList.length > i && aqiList[i] != null)
              ? (aqiList[i] as num).toInt()
              : AqiCalculator.pm25ToAqi(ptPm25);

          points.add(
            HourlyAqiPoint(
              time: DateTime.tryParse(timeList[i].toString()) ??
                  DateTime.now().add(Duration(hours: i)),
              aqi: ptAqi,
              pm25: ptPm25,
            ),
          );
        }
      }

      return AirQualityData(
        locationName: location.name,
        latitude: location.latitude,
        longitude: location.longitude,
        aqi: aqi,
        category: AqiScale.categoryForAqi(aqi),
        pm25: pm25,
        pm10: pm10,
        no2: no2,
        so2: so2,
        co: co,
        o3: o3,
        temperatureC: tempC,
        humidityPercent: humidity,
        windSpeedKmh: windKmh,
        weatherCode: weatherCode,
        dataSourceType: DataSourceType.live,
        dataSourceName: 'Open-Meteo Air Quality Global API (Live)',
        lastUpdated: DateTime.now(),
        hourlyForecast: points.isNotEmpty
            ? points
            : DemoDataProvider.getDemoAirQuality(location).hourlyForecast,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Network or atmospheric telemetry error: $e');
    }
  }

  Future<List<LocationItem>> searchGeocoding(String query) async {
    if (query.trim().isEmpty) return [];
    final uri = Uri.parse(
      'https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(query.trim())}&count=6&language=en&format=json',
    );
    try {
      final res = await _client.get(uri).timeout(const Duration(seconds: 5));
      if (res.statusCode == 200) {
        final json = jsonDecode(res.body) as Map<String, dynamic>;
        final results = json['results'] as List<dynamic>?;
        if (results == null) return [];
        return results.map((r) {
          final m = r as Map<String, dynamic>;
          final name = m['name'] as String? ?? 'Unknown';
          final admin1 = m['admin1'] as String?;
          final country = m['country'] as String? ?? '';
          final displayName = admin1 != null && admin1.isNotEmpty ? '$name, $admin1' : name;
          return LocationItem(
            id: 'geo_${m['id'] ?? "${m['latitude']}_${m['longitude']}"}',
            name: displayName,
            country: country,
            latitude: (m['latitude'] as num).toDouble(),
            longitude: (m['longitude'] as num).toDouble(),
            tag: LocationTag.other,
          );
        }).toList();
      }
    } catch (e) {
      AppLogger.warning('Geocoding search network error. Falling back to matching demo locations.', e);
      return DemoDataProvider.defaultDemoLocations
          .where((l) =>
              l.name.toLowerCase().contains(query.toLowerCase()) ||
              l.country.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    return [];
  }
}
