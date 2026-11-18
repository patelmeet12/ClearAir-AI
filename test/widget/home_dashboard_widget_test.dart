import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clearair_ai/core/constants/aqi_standards.dart';
import 'package:clearair_ai/domain/models/air_quality.dart';
import 'package:clearair_ai/presentation/widgets/aqi_gauge.dart';
import 'package:clearair_ai/presentation/widgets/aqi_badge.dart';
import 'package:clearair_ai/presentation/widgets/data_status_indicator.dart';
import 'package:clearair_ai/presentation/widgets/pollutant_chip.dart';

void main() {
  group('Home Dashboard Widgets Test', () {
    final mockAqi = AirQualityData(
      locationName: 'Delhi Test Center',
      latitude: 28.61,
      longitude: 77.20,
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
      weatherCode: 45,
      dataSourceType: DataSourceType.demo,
      dataSourceName: 'ClearAir Demo Dataset',
      lastUpdated: DateTime(2026, 11, 17, 18, 0),
      hourlyForecast: const [],
    );

    testWidgets('AqiGauge displays location, category, score, and exposure level', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AqiGauge(airQuality: mockAqi),
          ),
        ),
      );

      expect(find.text('Delhi Test Center'), findsOneWidget);
      expect(find.text('382'), findsOneWidget);
      expect(find.text('SEVERE'), findsOneWidget);
      expect(find.text(AqiScale.exposureLevel(382)), findsOneWidget);
    });

    testWidgets('AqiBadge renders category title and colored circle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AqiBadge(category: AqiCategory.severe, isLarge: true),
          ),
        ),
      );

      expect(find.text('Severe'), findsOneWidget);
    });

    testWidgets('DataStatusIndicator displays source label, name, and timestamp', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DataStatusIndicator(
              dataSourceType: DataSourceType.demo,
              sourceName: 'ClearAir Demo Dataset',
              lastUpdated: DateTime(2026, 11, 17, 18, 0),
              hasLocationPermission: true,
            ),
          ),
        ),
      );

      expect(find.text('DEMO DATA'), findsOneWidget);
      expect(find.textContaining('ClearAir Demo Dataset'), findsOneWidget);
    });

    testWidgets('PollutantMetricCard renders formula, value, unit, and limit', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PollutantMetricCard(
              label: 'Fine Particulates',
              formula: 'PM2.5',
              value: '334.5',
              unit: 'µg/m³',
              safetyLimit: '15 µg/m³ (WHO)',
              isSafe: false,
            ),
          ),
        ),
      );

      expect(find.text('PM2.5'), findsOneWidget);
      expect(find.text('334.5'), findsOneWidget);
      expect(find.text('µg/m³'), findsOneWidget);
      expect(find.text('Limit: 15 µg/m³ (WHO)'), findsOneWidget);
    });
  });
}
