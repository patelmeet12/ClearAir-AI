import 'dart:convert';

import 'package:clearair_ai/core/constants/aqi_standards.dart';
import 'package:clearair_ai/data/datasources/local_storage_service.dart';
import 'package:clearair_ai/domain/models/air_quality.dart';
import 'package:clearair_ai/domain/models/app_settings.dart';
import 'package:clearair_ai/main.dart';
import 'package:clearair_ai/presentation/providers/app_providers.dart';
import 'package:clearair_ai/presentation/screens/home_dashboard_screen.dart';
import 'package:clearair_ai/presentation/widgets/aqi_gauge.dart';
import 'package:clearair_ai/presentation/widgets/pollutant_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Accessibility & Semantics Verification', () {
    final mockAqi = AirQualityData(
      locationName: 'Delhi Test Center',
      latitude: 28.61,
      longitude: 77.20,
      aqi: 240,
      category: AqiCategory.veryPoor,
      pm25: 180.0,
      pm10: 280.0,
      no2: 65.0,
      so2: 25.0,
      co: 1800.0,
      o3: 45.0,
      temperatureC: 18.0,
      humidityPercent: 65.0,
      windSpeedKmh: 6.0,
      weatherCode: 45,
      dataSourceType: DataSourceType.demo,
      dataSourceName: 'ClearAir Demo Dataset',
      lastUpdated: DateTime(2026, 11, 21, 10, 0),
      hourlyForecast: const [],
    );

    testWidgets('AqiGauge presents comprehensive semantics for screen readers', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AqiGauge(
              airQuality: mockAqi,
              standard: AqiStandard.usEpa,
            ),
          ),
        ),
      );

      final gaugeSemantics = find.bySemanticsLabel(RegExp(r'Air Quality Index gauge showing 240.*US EPA AQI'));
      expect(gaugeSemantics, findsOneWidget);
    });

    testWidgets('AqiGauge adapts dynamically to India NAQI standard semantics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AqiGauge(
              airQuality: mockAqi,
              standard: AqiStandard.indiaNaqi,
            ),
          ),
        ),
      );

      final naqiSemantics = find.bySemanticsLabel(RegExp(r'Air Quality Index gauge showing 240.*India NAQI'));
      expect(naqiSemantics, findsOneWidget);
      expect(find.text('India NAQI'), findsOneWidget);
    });

    testWidgets('PollutantMetricCard provides accessible semantic descriptions', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: PollutantMetricCard(
              label: 'Fine Particulates',
              formula: 'PM2.5',
              value: '180.0',
              unit: 'µg/m³',
              safetyLimit: '15 µg/m³ (WHO)',
              isSafe: false,
            ),
          ),
        ),
      );

      final cardSemantics = find.bySemanticsLabel(
        RegExp(r'Fine Particulates \(PM2\.5\): 180\.0 µg/m³, Limit: 15 µg/m³ \(WHO\)\. Exceeds safe exposure limit'),
      );
      expect(cardSemantics, findsOneWidget);
    });

    testWidgets('PollutantMetricCard scales gracefully under large accessibility text scales', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(textScaler: TextScaler.linear(2.0)), // 200% font size
            child: Scaffold(
              body: SizedBox(
                width: 140,
                height: 100,
                child: PollutantMetricCard(
                  label: 'Fine Particulates',
                  formula: 'PM2.5',
                  value: '180.0',
                  unit: 'µg/m³',
                  safetyLimit: '15 µg/m³ (WHO)',
                  isSafe: false,
                ),
              ),
            ),
          ),
        ),
      );

      // Verify no exception or overflow occurs
      expect(tester.takeException(), isNull);
    });

    testWidgets('Interactive buttons meet Android tap target accessibility guidelines', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Atmospheric Data'),
              ),
            ),
          ),
        ),
      );

      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      handle.dispose();
    });

    testWidgets('Reduced motion propagates to MediaQuery disableAnimations and accessibleNavigation', (tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      SharedPreferences.setMockInitialValues({
        'clearair_app_settings': jsonEncode(const AppSettings(reducedMotion: true).toJson()),
      });
      final storage = await LocalStorageService.init();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(storage),
          ],
          child: const ClearAirApp(),
        ),
      );
      await tester.pumpAndSettle();

      final context = tester.element(find.byType(HomeDashboardScreen));
      expect(MediaQuery.disableAnimationsOf(context), isTrue);
      expect(MediaQuery.accessibleNavigationOf(context), isTrue);
    });
  });
}
