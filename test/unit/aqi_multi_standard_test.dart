import 'package:flutter_test/flutter_test.dart';
import 'package:clearair_ai/core/constants/aqi_standards.dart';
import 'package:clearair_ai/core/utils/aqi_calculator.dart';

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
