import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/aqi_standards.dart';
import '../../domain/models/air_quality.dart';
import '../../domain/models/location.dart';
import 'demo_data_provider.dart';

class OpenMeteoAqiApi {
  final http.Client _client;

  OpenMeteoAqiApi({http.Client? client}) : _client = client ?? http.Client();

  Future<AirQualityData> fetchAirQuality(LocationItem location) async {
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

      if (aqiRes.statusCode == 200) {
        final aqiJson = jsonDecode(aqiRes.body) as Map<String, dynamic>;
        final currentAqi = aqiJson['current'] as Map<String, dynamic>? ?? {};

        double tempC = 20.0;
        double humidity = 50.0;
        double windKmh = 10.0;
        int weatherCode = 0;

        if (weatherRes.statusCode == 200) {
          final weatherJson = jsonDecode(weatherRes.body) as Map<String, dynamic>;
          final currentW = weatherJson['current'] as Map<String, dynamic>? ?? {};
          tempC = (currentW['temperature_2m'] as num?)?.toDouble() ?? 20.0;
          humidity = (currentW['relative_humidity_2m'] as num?)?.toDouble() ?? 50.0;
          windKmh = (currentW['wind_speed_10m'] as num?)?.toDouble() ?? 10.0;
          weatherCode = (currentW['weather_code'] as num?)?.toInt() ?? 0;
        }

        final int aqi = (currentAqi['us_aqi'] as num?)?.toInt() ?? 50;
        final double pm25 = (currentAqi['pm2_5'] as num?)?.toDouble() ?? 12.0;
        final double pm10 = (currentAqi['pm10'] as num?)?.toDouble() ?? 25.0;
        final double no2 = (currentAqi['nitrogen_dioxide'] as num?)?.toDouble() ?? 15.0;
        final double so2 = (currentAqi['sulphur_dioxide'] as num?)?.toDouble() ?? 5.0;
        final double co = (currentAqi['carbon_monoxide'] as num?)?.toDouble() ?? 300.0;
        final double o3 = (currentAqi['ozone'] as num?)?.toDouble() ?? 40.0;

        // Parse hourly forecast
        final hourlyMap = aqiJson['hourly'] as Map<String, dynamic>?;
        final List<HourlyAqiPoint> points = [];
        if (hourlyMap != null) {
          final timeList = hourlyMap['time'] as List<dynamic>? ?? [];
          final aqiList = hourlyMap['us_aqi'] as List<dynamic>? ?? [];
          final pm25List = hourlyMap['pm2_5'] as List<dynamic>? ?? [];

          final limit = timeList.length < 24 ? timeList.length : 24;
          for (int i = 0; i < limit; i++) {
            points.add(
              HourlyAqiPoint(
                time: DateTime.tryParse(timeList[i].toString()) ?? DateTime.now().add(Duration(hours: i)),
                aqi: (aqiList.length > i && aqiList[i] != null) ? (aqiList[i] as num).toInt() : aqi,
                pm25: (pm25List.length > i && pm25List[i] != null) ? (pm25List[i] as num).toDouble() : pm25,
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
          hourlyForecast: points.isNotEmpty ? points : DemoDataProvider.getDemoAirQuality(location).hourlyForecast,
        );
      } else {
        // Fallback to demo data on non-200
        return DemoDataProvider.getDemoAirQuality(location);
      }
    } catch (_) {
      // Offline fallback
      return DemoDataProvider.getDemoAirQuality(location);
    }
  }

  Future<List<LocationItem>> searchGeocoding(String query) async {
    if (query.trim().isEmpty) return [];
    final uri = Uri.parse('https://geocoding-api.open-meteo.com/v1/search?name=${Uri.encodeComponent(query)}&count=6&language=en&format=json');
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
    } catch (_) {
      // Filter demo locations if offline
      return DemoDataProvider.defaultDemoLocations
          .where((l) => l.name.toLowerCase().contains(query.toLowerCase()) || l.country.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    return [];
  }
}
