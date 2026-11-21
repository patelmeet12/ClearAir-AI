import 'package:flutter_test/flutter_test.dart';
import 'package:clearair_ai/core/constants/aqi_standards.dart';
import 'package:clearair_ai/core/utils/pollutant_standards.dart';

void main() {
  group('PollutantStandards Unit Tests', () {
    test('Standard limit lookup for US EPA / WHO baseline', () {
      expect(PollutantStandards.getStandardLimit(PollutantType.pm25, AqiStandard.usEpa), equals(15.0));
      expect(PollutantStandards.getStandardLimit(PollutantType.pm10, AqiStandard.usEpa), equals(45.0));
      expect(PollutantStandards.getStandardLimit(PollutantType.no2, AqiStandard.usEpa), equals(25.0));
      expect(PollutantStandards.getStandardLimit(PollutantType.so2, AqiStandard.usEpa), equals(40.0));
      expect(PollutantStandards.getStandardLimit(PollutantType.o3, AqiStandard.usEpa), equals(100.0));
      expect(PollutantStandards.getStandardLimit(PollutantType.co, AqiStandard.usEpa), equals(4000.0));
    });

    test('Standard limit lookup for India CPCB NAQI baseline', () {
      expect(PollutantStandards.getStandardLimit(PollutantType.pm25, AqiStandard.indiaNaqi), equals(60.0));
      expect(PollutantStandards.getStandardLimit(PollutantType.pm10, AqiStandard.indiaNaqi), equals(100.0));
      expect(PollutantStandards.getStandardLimit(PollutantType.no2, AqiStandard.indiaNaqi), equals(80.0));
      expect(PollutantStandards.getStandardLimit(PollutantType.so2, AqiStandard.indiaNaqi), equals(80.0));
      expect(PollutantStandards.getStandardLimit(PollutantType.o3, AqiStandard.indiaNaqi), equals(100.0));
      expect(PollutantStandards.getStandardLimit(PollutantType.co, AqiStandard.indiaNaqi), equals(2000.0));
    });

    test('isWithinLimit boundary checks', () {
      // Below limit
      expect(PollutantStandards.isWithinLimit(PollutantType.pm25, 10.0, AqiStandard.usEpa), isTrue);
      // Exactly at limit
      expect(PollutantStandards.isWithinLimit(PollutantType.pm25, 15.0, AqiStandard.usEpa), isTrue);
      // Above limit
      expect(PollutantStandards.isWithinLimit(PollutantType.pm25, 15.1, AqiStandard.usEpa), isFalse);

      // India NAQI boundary
      expect(PollutantStandards.isWithinLimit(PollutantType.pm25, 55.0, AqiStandard.indiaNaqi), isTrue);
      expect(PollutantStandards.isWithinLimit(PollutantType.pm25, 65.0, AqiStandard.indiaNaqi), isFalse);
    });

    test('isWithinLimit handles NaN, infinite, and negative numbers safely', () {
      expect(PollutantStandards.isWithinLimit(PollutantType.pm25, double.nan, AqiStandard.usEpa), isFalse);
      expect(PollutantStandards.isWithinLimit(PollutantType.pm25, double.infinity, AqiStandard.usEpa), isFalse);
      expect(PollutantStandards.isWithinLimit(PollutantType.pm25, double.negativeInfinity, AqiStandard.usEpa), isFalse);
    });

    test('sanitize cleans corrupted, null, and negative sensor codes', () {
      expect(PollutantStandards.sanitize(null), equals(0.0));
      expect(PollutantStandards.sanitize(null, defaultValue: 10.0), equals(10.0));
      expect(PollutantStandards.sanitize(-999.0), equals(0.0));
      expect(PollutantStandards.sanitize(-1.0), equals(0.0));
      expect(PollutantStandards.sanitize(double.nan), equals(0.0));
      expect(PollutantStandards.sanitize(double.infinity), equals(0.0));
      expect(PollutantStandards.sanitize(42.5), equals(42.5));
    });

    test('getLimitDescription formats units accurately for both standards', () {
      expect(PollutantStandards.getLimitDescription(PollutantType.pm25, AqiStandard.usEpa), equals('15 µg/m³ (WHO)'));
      expect(PollutantStandards.getLimitDescription(PollutantType.pm25, AqiStandard.indiaNaqi), equals('60 µg/m³ (CPCB)'));
      expect(PollutantStandards.getLimitDescription(PollutantType.co, AqiStandard.usEpa), equals('4 mg/m³ (WHO)'));
      expect(PollutantStandards.getLimitDescription(PollutantType.co, AqiStandard.indiaNaqi), equals('2 mg/m³ (CPCB)'));
    });

    test('getHealthWarning provides informative implications across pollutants', () {
      expect(PollutantStandards.getHealthWarning(PollutantType.pm25, 180.0), contains('bloodstream'));
      expect(PollutantStandards.getHealthWarning(PollutantType.pm25, 0.0), contains('Undetected'));
      expect(PollutantStandards.getHealthWarning(PollutantType.pm10, 300.0), contains('inflammation'));
      expect(PollutantStandards.getHealthWarning(PollutantType.no2, 120.0), contains('asthma'));
      expect(PollutantStandards.getHealthWarning(PollutantType.so2, 120.0), contains('Sulfur'));
      expect(PollutantStandards.getHealthWarning(PollutantType.o3, 160.0), contains('Photochemical'));
      expect(PollutantStandards.getHealthWarning(PollutantType.co, 15000.0), contains('oxygen'));
    });
  });
}
