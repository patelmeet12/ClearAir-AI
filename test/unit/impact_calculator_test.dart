import 'package:clearair_ai/core/utils/impact_calculator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ImpactCalculator Tests', () {
    test('Calculates emissions and fuel savings for public transit shift', () {
      final result = ImpactCalculator.publicTransportTrip(distanceKm: 20.0, isMetro: true);

      expect(result.co2AvoidedKg, greaterThan(2.0));
      expect(result.fuelSavedLiters, closeTo(1.6, 0.1));
      expect(result.costSavedUsd, greaterThan(0.0));
      expect(result.pm25PreventedGrams, greaterThan(0.0));
      expect(result.assumptionNotes, contains('gasoline car'));
    });

    test('Calculates impact of avoiding vehicle idling', () {
      final result = ImpactCalculator.avoidedIdling(minutes: 15);

      expect(result.fuelSavedLiters, closeTo(0.3, 0.05));
      expect(result.co2AvoidedKg, greaterThan(0.5));
      expect(result.pm25PreventedGrams, greaterThan(0.0));
    });

    test('Calculates combined errands (trip chaining) impact', () {
      final result = ImpactCalculator.combinedErrands(tripsCombined: 3, estimatedDistanceSavedKm: 8.0);

      expect(result.co2AvoidedKg, greaterThan(1.0));
      expect(result.fuelSavedLiters, greaterThan(0.5));
      expect(result.assumptionNotes, contains('Cold-engine starts'));
    });

    test('ImpactCalculationResult addition operator aggregates metrics correctly', () {
      const a = ImpactCalculationResult(
        co2AvoidedKg: 2.5,
        fuelSavedLiters: 1.0,
        costSavedUsd: 3.0,
        pm25PreventedGrams: 0.05,
        assumptionNotes: 'Action A',
      );

      const b = ImpactCalculationResult(
        co2AvoidedKg: 1.5,
        fuelSavedLiters: 0.5,
        costSavedUsd: 1.5,
        pm25PreventedGrams: 0.03,
        assumptionNotes: 'Action B',
      );

      final sum = a + b;
      expect(sum.co2AvoidedKg, equals(4.0));
      expect(sum.fuelSavedLiters, equals(1.5));
      expect(sum.costSavedUsd, equals(4.5));
      expect(sum.pm25PreventedGrams, closeTo(0.08, 0.001));
    });
  });
}
