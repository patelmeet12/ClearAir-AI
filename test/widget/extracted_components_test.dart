import 'package:clearair_ai/core/constants/aqi_standards.dart';
import 'package:clearair_ai/core/utils/impact_calculator.dart';
import 'package:clearair_ai/domain/models/air_quality.dart';
import 'package:clearair_ai/domain/models/household_profile.dart';
import 'package:clearair_ai/presentation/widgets/atmospheric_conditions_bar.dart';
import 'package:clearair_ai/presentation/widgets/family_safety_banner.dart';
import 'package:clearair_ai/presentation/widgets/guidance_card.dart';
import 'package:clearair_ai/presentation/widgets/impact_summary_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Modular Extracted Presentation Widgets Tests', () {
    final mockAqi = AirQualityData(
      locationName: 'Test Metro Area',
      latitude: 28.5,
      longitude: 77.2,
      aqi: 175,
      category: AqiCategory.poor,
      pm25: 65.0,
      pm10: 120.0,
      no2: 45.0,
      so2: 15.0,
      co: 900.0,
      o3: 50.0,
      temperatureC: 22.4,
      humidityPercent: 58.0,
      windSpeedKmh: 7.5,
      weatherCode: 0,
      dataSourceType: DataSourceType.live,
      dataSourceName: 'Station Test',
      lastUpdated: DateTime(2026, 11, 22, 12, 0),
      hourlyForecast: const [],
    );

    testWidgets('AtmosphericConditionsBar renders all meteorological metrics', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AtmosphericConditionsBar(airQuality: mockAqi),
          ),
        ),
      );

      expect(find.text('22.4°C'), findsOneWidget);
      expect(find.text('58%'), findsOneWidget);
      expect(find.text('7.5 km/h'), findsOneWidget);
      expect(find.text('Fair'), findsOneWidget);
    });

    testWidgets('GuidanceCard renders title, content, and styled icon', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GuidanceCard(
              title: 'Exercise Precaution',
              content: 'Avoid strenuous outdoor running today.',
              icon: Icons.directions_run,
              iconColor: Colors.orange,
            ),
          ),
        ),
      );

      expect(find.text('Exercise Precaution'), findsOneWidget);
      expect(find.text('Avoid strenuous outdoor running today.'), findsOneWidget);
      expect(find.byIcon(Icons.directions_run), findsOneWidget);
    });

    testWidgets('FamilySafetyBanner properly formats singular and plural member counts', (tester) async {
      const singleChildProfile = HouseholdProfile(
        adults: 2,
        children: 1,
        olderAdults: 0,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FamilySafetyBanner(householdProfile: singleChildProfile),
          ),
        ),
      );

      expect(find.textContaining('1 child and 0 older adults'), findsOneWidget);
    });

    testWidgets('ImpactSummaryCard displays aggregated avoided emissions and cost metrics', (tester) async {
      const impact = ImpactCalculationResult(
        co2AvoidedKg: 4.85,
        fuelSavedLiters: 2.10,
        costSavedUsd: 3.25,
        pm25PreventedGrams: 0.058,
        assumptionNotes: 'Test model calculation',
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ImpactSummaryCard(impact: impact, count: 5),
          ),
        ),
      );

      expect(find.text('ESTIMATED IMPACT (5 ACTIONS)'), findsOneWidget);
      expect(find.text('4.85 kg'), findsOneWidget);
      expect(find.text('2.10 L'), findsOneWidget);
      expect(find.text('\$3.25'), findsOneWidget);
      expect(find.text('58 mg'), findsOneWidget);
    });
  });
}
