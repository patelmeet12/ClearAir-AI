import 'package:clearair_ai/core/constants/aqi_standards.dart';
import 'package:clearair_ai/core/utils/aqi_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AqiCalculator Multi-Standard & Boundary Tests', () {
    test('Calculates US EPA AQI from PM10 breakpoints accurately', () {
      expect(AqiCalculator.pm10ToUsAqi(0.0), equals(0));
      expect(AqiCalculator.pm10ToUsAqi(54.0), equals(50));
      expect(AqiCalculator.pm10ToUsAqi(154.0), equals(100));
      expect(AqiCalculator.pm10ToUsAqi(254.0), equals(150));
      expect(AqiCalculator.pm10ToUsAqi(354.0), equals(200));
      expect(AqiCalculator.pm10ToUsAqi(424.0), equals(300));
      expect(AqiCalculator.pm10ToUsAqi(504.0), equals(400));
      expect(AqiCalculator.pm10ToUsAqi(604.0), equals(500));
      expect(AqiCalculator.pm10ToUsAqi(800.0), equals(500)); // Cap at 500
    });

    test('Calculates India NAQI (CPCB) from PM2.5 breakpoints accurately', () {
      expect(AqiCalculator.pm25ToIndiaNaqi(0.0), equals(0));
      expect(AqiCalculator.pm25ToIndiaNaqi(30.0), equals(50));
      expect(AqiCalculator.pm25ToIndiaNaqi(60.0), equals(100));
      expect(AqiCalculator.pm25ToIndiaNaqi(90.0), equals(200));
      expect(AqiCalculator.pm25ToIndiaNaqi(120.0), equals(300));
      expect(AqiCalculator.pm25ToIndiaNaqi(250.0), equals(400));
      expect(AqiCalculator.pm25ToIndiaNaqi(380.0), equals(500));
      expect(AqiCalculator.pm25ToIndiaNaqi(500.0), equals(500));
    });

    test('Calculates India NAQI (CPCB) from PM10 breakpoints accurately', () {
      expect(AqiCalculator.pm10ToIndiaNaqi(0.0), equals(0));
      expect(AqiCalculator.pm10ToIndiaNaqi(50.0), equals(50));
      expect(AqiCalculator.pm10ToIndiaNaqi(100.0), equals(100));
      expect(AqiCalculator.pm10ToIndiaNaqi(250.0), equals(200));
      expect(AqiCalculator.pm10ToIndiaNaqi(350.0), equals(300));
      expect(AqiCalculator.pm10ToIndiaNaqi(430.0), equals(400));
      expect(AqiCalculator.pm10ToIndiaNaqi(550.0), equals(500));
    });

    test('calculateAqi picks the maximum sub-index under official EPA/CPCB rules', () {
      // Case 1: PM2.5 is the dominant pollutant
      final aqi1 = AqiCalculator.calculateAqi(
        pm25: 150.4, // US AQI = 200
        pm10: 50.0, // US AQI ~ 46
        standard: AqiStandard.usEpa,
      );
      expect(aqi1, equals(200));

      // Case 2: PM10 is the dominant pollutant
      final aqi2 = AqiCalculator.calculateAqi(
        pm25: 12.0, // US AQI = 50
        pm10: 354.0, // US AQI = 200
        standard: AqiStandard.usEpa,
      );
      expect(aqi2, equals(200));

      // Case 3: India NAQI standard calculation
      final aqiNaqi = AqiCalculator.calculateAqi(
        pm25: 90.0, // CPCB NAQI = 200
        pm10: 100.0, // CPCB NAQI = 100
        standard: AqiStandard.indiaNaqi,
      );
      expect(aqiNaqi, equals(200));

      // Case 4: NO2 is the dominant pollutant under EPA standard
      final aqiNo2 = AqiCalculator.calculateAqi(
        pm25: 10.0, // US AQI ~ 42
        no2: 676.0, // US AQI = 150
        standard: AqiStandard.usEpa,
      );
      expect(aqiNo2, equals(150));

      // Case 5: O3 is the dominant pollutant under India NAQI standard
      final aqiO3 = AqiCalculator.calculateAqi(
        pm25: 25.0, // CPCB NAQI ~ 42
        o3: 208.0, // CPCB NAQI = 300
        standard: AqiStandard.indiaNaqi,
      );
      expect(aqiO3, equals(300));
    });

    test('Calculates NO2, SO2, CO, and O3 sub-indices across US EPA and India NAQI', () {
      // US EPA NO2
      expect(AqiCalculator.no2ToUsAqi(100.0), equals(50));
      expect(AqiCalculator.no2ToUsAqi(188.0), equals(100));

      // US EPA SO2
      expect(AqiCalculator.so2ToUsAqi(92.0), equals(50));
      expect(AqiCalculator.so2ToUsAqi(196.0), equals(100));

      // US EPA CO
      expect(AqiCalculator.coToUsAqi(5000.0), equals(50));
      expect(AqiCalculator.coToUsAqi(10760.0), equals(100));

      // US EPA O3
      expect(AqiCalculator.o3ToUsAqi(106.0), equals(50));
      expect(AqiCalculator.o3ToUsAqi(137.0), equals(100));

      // India NAQI NO2
      expect(AqiCalculator.no2ToIndiaNaqi(40.0), equals(50));
      expect(AqiCalculator.no2ToIndiaNaqi(80.0), equals(100));
      expect(AqiCalculator.no2ToIndiaNaqi(180.0), equals(200));

      // India NAQI SO2
      expect(AqiCalculator.so2ToIndiaNaqi(40.0), equals(50));
      expect(AqiCalculator.so2ToIndiaNaqi(80.0), equals(100));

      // India NAQI CO
      expect(AqiCalculator.coToIndiaNaqi(1000.0), equals(50));
      expect(AqiCalculator.coToIndiaNaqi(2000.0), equals(100));

      // India NAQI O3
      expect(AqiCalculator.o3ToIndiaNaqi(50.0), equals(50));
      expect(AqiCalculator.o3ToIndiaNaqi(100.0), equals(100));
    });

    test('Boundary conditions and malformed inputs are guarded against crashes', () {
      expect(AqiCalculator.pm25ToAqi(-50.0), equals(0));
      expect(AqiCalculator.pm25ToAqi(double.nan), equals(0));
      expect(AqiCalculator.pm25ToAqi(double.infinity), equals(500));

      expect(AqiCalculator.pm10ToUsAqi(-10.0), equals(0));
      expect(AqiCalculator.pm10ToUsAqi(double.nan), equals(0));
      expect(AqiCalculator.pm10ToUsAqi(double.infinity), equals(500));

      expect(AqiCalculator.pm25ToIndiaNaqi(-100.0), equals(0));
      expect(AqiCalculator.pm25ToIndiaNaqi(double.nan), equals(0));
      expect(AqiCalculator.pm25ToIndiaNaqi(double.infinity), equals(500));

      expect(AqiCalculator.pm10ToIndiaNaqi(-100.0), equals(0));
      expect(AqiCalculator.pm10ToIndiaNaqi(double.nan), equals(0));
      expect(AqiCalculator.pm10ToIndiaNaqi(double.infinity), equals(500));
    });
  });
}
