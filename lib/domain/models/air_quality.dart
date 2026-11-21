import 'package:equatable/equatable.dart';
import '../../core/constants/aqi_standards.dart';

enum DataSourceType {
  live('Live Data', 'Real-time readings fetched from air monitoring networks'),
  cached('Cached Data', 'Previously fetched data retained for offline resilience'),
  estimated('Estimated Data', 'Model-derived atmospheric estimate based on surrounding grid'),
  demo('Demo Data', 'Simulated deterministic dataset for demonstration & testing');

  final String label;
  final String description;
  const DataSourceType(this.label, this.description);
}

class HourlyAqiPoint extends Equatable {
  final DateTime time;
  final int aqi;
  final double pm25;

  const HourlyAqiPoint({
    required this.time,
    required this.aqi,
    required this.pm25,
  });

  HourlyAqiPoint copyWith({
    DateTime? time,
    int? aqi,
    double? pm25,
  }) {
    return HourlyAqiPoint(
      time: time ?? this.time,
      aqi: aqi ?? this.aqi,
      pm25: pm25 ?? this.pm25,
    );
  }

  Map<String, dynamic> toJson() => {
    'time': time.toIso8601String(),
    'aqi': aqi,
    'pm25': pm25,
  };

  factory HourlyAqiPoint.fromJson(Map<String, dynamic> json) => HourlyAqiPoint(
    time: DateTime.parse(json['time'] as String),
    aqi: json['aqi'] as int,
    pm25: (json['pm25'] as num).toDouble(),
  );

  @override
  List<Object?> get props => [time, aqi, pm25];
}

class AirQualityData extends Equatable {
  final String locationName;
  final double latitude;
  final double longitude;
  final int aqi;
  final AqiCategory category;
  final double pm25; // µg/m³
  final double pm10; // µg/m³
  final double no2; // µg/m³
  final double so2; // µg/m³
  final double co; // µg/m³
  final double o3; // µg/m³
  final double temperatureC;
  final double humidityPercent;
  final double windSpeedKmh;
  final int weatherCode;
  final DataSourceType dataSourceType;
  final String dataSourceName;
  final DateTime lastUpdated;
  final List<HourlyAqiPoint> hourlyForecast;

  const AirQualityData({
    required this.locationName,
    required this.latitude,
    required this.longitude,
    required this.aqi,
    required this.category,
    required this.pm25,
    required this.pm10,
    required this.no2,
    required this.so2,
    required this.co,
    required this.o3,
    required this.temperatureC,
    required this.humidityPercent,
    required this.windSpeedKmh,
    required this.weatherCode,
    required this.dataSourceType,
    required this.dataSourceName,
    required this.lastUpdated,
    required this.hourlyForecast,
  });

  /// Evaluates the AQI category dynamically under the specified measurement standard.
  AqiCategory getCategory([AqiStandard standard = AqiStandard.usEpa]) {
    return AqiScale.categoryForAqi(aqi, standard);
  }

  AirQualityData copyWith({
    String? locationName,
    double? latitude,
    double? longitude,
    int? aqi,
    AqiCategory? category,
    double? pm25,
    double? pm10,
    double? no2,
    double? so2,
    double? co,
    double? o3,
    double? temperatureC,
    double? humidityPercent,
    double? windSpeedKmh,
    int? weatherCode,
    DataSourceType? dataSourceType,
    String? dataSourceName,
    DateTime? lastUpdated,
    List<HourlyAqiPoint>? hourlyForecast,
  }) {
    return AirQualityData(
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      aqi: aqi ?? this.aqi,
      category: category ?? this.category,
      pm25: pm25 ?? this.pm25,
      pm10: pm10 ?? this.pm10,
      no2: no2 ?? this.no2,
      so2: so2 ?? this.so2,
      co: co ?? this.co,
      o3: o3 ?? this.o3,
      temperatureC: temperatureC ?? this.temperatureC,
      humidityPercent: humidityPercent ?? this.humidityPercent,
      windSpeedKmh: windSpeedKmh ?? this.windSpeedKmh,
      weatherCode: weatherCode ?? this.weatherCode,
      dataSourceType: dataSourceType ?? this.dataSourceType,
      dataSourceName: dataSourceName ?? this.dataSourceName,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      hourlyForecast: hourlyForecast ?? this.hourlyForecast,
    );
  }

  Map<String, dynamic> toJson() => {
    'locationName': locationName,
    'latitude': latitude,
    'longitude': longitude,
    'aqi': aqi,
    'category': category.name,
    'pm25': pm25,
    'pm10': pm10,
    'no2': no2,
    'so2': so2,
    'co': co,
    'o3': o3,
    'temperatureC': temperatureC,
    'humidityPercent': humidityPercent,
    'windSpeedKmh': windSpeedKmh,
    'weatherCode': weatherCode,
    'dataSourceType': dataSourceType.name,
    'dataSourceName': dataSourceName,
    'lastUpdated': lastUpdated.toIso8601String(),
    'hourlyForecast': hourlyForecast.map((e) => e.toJson()).toList(),
  };

  factory AirQualityData.fromJson(Map<String, dynamic> json) => AirQualityData(
    locationName: json['locationName'] as String,
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    aqi: json['aqi'] as int,
    category: AqiCategory.values.firstWhere(
      (c) => c.name == json['category'],
      orElse: () => AqiCategory.moderate,
    ),
    pm25: (json['pm25'] as num).toDouble(),
    pm10: (json['pm10'] as num).toDouble(),
    no2: (json['no2'] as num).toDouble(),
    so2: (json['so2'] as num).toDouble(),
    co: (json['co'] as num).toDouble(),
    o3: (json['o3'] as num).toDouble(),
    temperatureC: (json['temperatureC'] as num).toDouble(),
    humidityPercent: (json['humidityPercent'] as num).toDouble(),
    windSpeedKmh: (json['windSpeedKmh'] as num).toDouble(),
    weatherCode: json['weatherCode'] as int,
    dataSourceType: DataSourceType.values.firstWhere(
      (d) => d.name == json['dataSourceType'],
      orElse: () => DataSourceType.demo,
    ),
    dataSourceName: json['dataSourceName'] as String,
    lastUpdated: DateTime.parse(json['lastUpdated'] as String),
    hourlyForecast: (json['hourlyForecast'] as List<dynamic>?)
            ?.map((e) => HourlyAqiPoint.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [],
  );

  @override
  List<Object?> get props => [
    locationName,
    latitude,
    longitude,
    aqi,
    category,
    pm25,
    pm10,
    no2,
    so2,
    co,
    o3,
    temperatureC,
    humidityPercent,
    windSpeedKmh,
    weatherCode,
    dataSourceType,
    dataSourceName,
    lastUpdated,
    hourlyForecast,
  ];
}
