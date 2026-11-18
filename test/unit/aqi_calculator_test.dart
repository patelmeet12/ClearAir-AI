import 'package:flutter_test/flutter_test.dart';
import 'package:clearair_ai/core/constants/aqi_standards.dart';
import 'package:clearair_ai/core/utils/aqi_calculator.dart';

void main() {
  group('AqiCalculator & AqiScale Tests', () {
    test('Calculates correct US EPA AQI from PM2.5 concentrations', () {
      // Good category: 0 - 12 ug/m3
      expect(AqiCalculator.pm25ToAqi(0.0), equals(0));
      expect(AqiCalculator.pm25ToAqi(12.0), equals(50));

      // Moderate category: 12.1 - 35.4 ug/m3
      expect(AqiCalculator.pm25ToAqi(23.75), inInclusiveRange(70, 80));
      expect(AqiCalculator.pm25ToAqi(35.4), equals(100));

      // Poor / Sensitive: 35.5 - 55.4 ug/m3
      expect(AqiCalculator.pm25ToAqi(55.4), equals(150));

      // Unhealthy: 55.5 - 150.4 ug/m3
      expect(AqiCalculator.pm25ToAqi(150.4), equals(200));

      // Very Poor / Very Unhealthy: 150.5 - 250.4 ug/m3
      expect(AqiCalculator.pm25ToAqi(250.4), equals(300));

      // Severe / Hazardous: > 250.5 ug/m3
      expect(AqiCalculator.pm25ToAqi(350.4), equals(400));
      expect(AqiCalculator.pm25ToAqi(500.4), equals(500));
      expect(AqiCalculator.pm25ToAqi(700.0), equals(500)); // Cap at 500
    });

    test('Maps AQI values to appropriate categories for US EPA standard', () {
      expect(AqiScale.categoryForAqi(35, AqiStandard.usEpa), equals(AqiCategory.good));
      expect(AqiScale.categoryForAqi(75, AqiStandard.usEpa), equals(AqiCategory.moderate));
      expect(AqiScale.categoryForAqi(130, AqiStandard.usEpa), equals(AqiCategory.poor));
      expect(AqiScale.categoryForAqi(250, AqiStandard.usEpa), equals(AqiCategory.veryPoor));
      expect(AqiScale.categoryForAqi(380, AqiStandard.usEpa), equals(AqiCategory.severe));
    });

    test('Maps AQI values to appropriate categories for India NAQI standard', () {
      expect(AqiScale.categoryForAqi(40, AqiStandard.indiaNaqi), equals(AqiCategory.good));
      expect(AqiScale.categoryForAqi(80, AqiStandard.indiaNaqi), equals(AqiCategory.moderate));
      expect(AqiScale.categoryForAqi(180, AqiStandard.indiaNaqi), equals(AqiCategory.poor));
      expect(AqiScale.categoryForAqi(350, AqiStandard.indiaNaqi), equals(AqiCategory.veryPoor));
      expect(AqiScale.categoryForAqi(420, AqiStandard.indiaNaqi), equals(AqiCategory.severe));
    });

    test('Calculates N95 respirator personal exposure reduction', () {
      const double ambientPm25 = 200.0; // ug/m3
      const double hours = 2.0;

      // Inhaled volume = 2.0 * 0.8 = 1.6 m3
      // Total dose without mask = 200 * 1.6 = 320 ug
      // N95 filters 95% = 304 ug reduction
      final reduction = AqiCalculator.calculateRespiratorExposureReduction(
        outdoorPm25: ambientPm25,
        exposureHours: hours,
        wearingN95: true,
      );

      expect(reduction, closeTo(304.0, 0.1));

      final noMaskReduction = AqiCalculator.calculateRespiratorExposureReduction(
        outdoorPm25: ambientPm25,
        exposureHours: hours,
        wearingN95: false,
      );
      expect(noMaskReduction, equals(0.0));
    });
  });
}
