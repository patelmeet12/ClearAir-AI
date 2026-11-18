import '../constants/emission_factors.dart';

class ImpactCalculationResult {
  final double co2AvoidedKg;
  final double fuelSavedLiters;
  final double costSavedUsd;
  final double pm25PreventedGrams;
  final String assumptionNotes;

  const ImpactCalculationResult({
    required this.co2AvoidedKg,
    required this.fuelSavedLiters,
    required this.costSavedUsd,
    required this.pm25PreventedGrams,
    required this.assumptionNotes,
  });

  ImpactCalculationResult operator +(ImpactCalculationResult other) {
    return ImpactCalculationResult(
      co2AvoidedKg: co2AvoidedKg + other.co2AvoidedKg,
      fuelSavedLiters: fuelSavedLiters + other.fuelSavedLiters,
      costSavedUsd: costSavedUsd + other.costSavedUsd,
      pm25PreventedGrams: pm25PreventedGrams + other.pm25PreventedGrams,
      assumptionNotes: assumptionNotes,
    );
  }

  static const zero = ImpactCalculationResult(
    co2AvoidedKg: 0.0,
    fuelSavedLiters: 0.0,
    costSavedUsd: 0.0,
    pm25PreventedGrams: 0.0,
    assumptionNotes: 'No actions completed yet.',
  );
}

class ImpactCalculator {
  /// Shift from Solo Car to Public Metro / Bus for [distanceKm]
  static ImpactCalculationResult publicTransportTrip({required double distanceKm, bool isMetro = true}) {
    final double carCo2G = distanceKm * EmissionFactors.carSoloGasolineCo2PerKm;
    final double transitCo2G = distanceKm * (isMetro ? EmissionFactors.electricMetroCo2PerKm : EmissionFactors.publicBusCo2PerKm);
    final double netCo2Kg = (carCo2G - transitCo2G) / 1000.0;

    final double fuelSavedL = distanceKm / EmissionFactors.avgFuelEfficiencyKmPerLiter;
    final double costSavedUsd = (fuelSavedL * EmissionFactors.avgFuelCostPerLiterUsd) - (isMetro ? 2.0 : 1.5); // Minus ticket
    final double pm25G = (distanceKm * (EmissionFactors.carGasolinePm25PerKmMg - EmissionFactors.busPm25PerKmMg)) / 1000.0;

    return ImpactCalculationResult(
      co2AvoidedKg: netCo2Kg > 0 ? netCo2Kg : 0.0,
      fuelSavedLiters: fuelSavedL,
      costSavedUsd: costSavedUsd > 0 ? costSavedUsd : 0.0,
      pm25PreventedGrams: pm25G > 0 ? pm25G : 0.0,
      assumptionNotes: 'Assumes replacing single-occupancy gasoline car (~171g CO2/km) with public transit (${isMetro ? "28g" : "68g"} CO2/pass-km). Fuel economy baseline: 12.5 km/L.',
    );
  }

  /// Avoided Vehicle Idling for [minutes]
  static ImpactCalculationResult avoidedIdling({required int minutes}) {
    final double fuelL = (minutes / 60.0) * EmissionFactors.idlingFuelConsumptionPerHourLiters;
    final double co2Kg = fuelL * EmissionFactors.gasolineCo2PerLiterKg;
    final double costSaved = fuelL * EmissionFactors.avgFuelCostPerLiterUsd;
    // Tailpipe PM2.5 at idle ~ 0.45 g/hour
    final double pm25G = (minutes / 60.0) * 0.45;

    return ImpactCalculationResult(
      co2AvoidedKg: co2Kg,
      fuelSavedLiters: fuelL,
      costSavedUsd: costSaved,
      pm25PreventedGrams: pm25G,
      assumptionNotes: 'Engine idle consumption baseline: 1.2 L/hr gasoline; 2.31 kg CO2/L combustion factor; 0.45 g PM2.5/hr idle emissions.',
    );
  }

  /// Combining errands (Trip Chaining) for [tripsCombined] errands
  static ImpactCalculationResult combinedErrands({int tripsCombined = 2, double estimatedDistanceSavedKm = 6.0}) {
    final double co2Kg = (estimatedDistanceSavedKm * EmissionFactors.carSoloGasolineCo2PerKm) / 1000.0;
    final double fuelL = estimatedDistanceSavedKm / EmissionFactors.avgFuelEfficiencyKmPerLiter;
    final double costSaved = fuelL * EmissionFactors.avgFuelCostPerLiterUsd;
    final double pm25G = (estimatedDistanceSavedKm * EmissionFactors.carGasolinePm25PerKmMg) / 1000.0;

    return ImpactCalculationResult(
      co2AvoidedKg: co2Kg,
      fuelSavedLiters: fuelL,
      costSavedUsd: costSaved,
      pm25PreventedGrams: pm25G,
      assumptionNotes: 'Cold-engine starts emit up to 2x more pollutants. Combining errands eliminates cold-start cycles and an estimated $estimatedDistanceSavedKm km of driving.',
    );
  }

  /// Indoor Energy Efficiency (e.g. smart thermostat, LED, turn off standby)
  static ImpactCalculationResult energyEfficiency({double kwhSaved = 2.5}) {
    final double co2Kg = kwhSaved * EmissionFactors.gridElectricityCo2PerKwhKg;
    final double costSaved = kwhSaved * 0.16; // $0.16/kWh baseline

    return ImpactCalculationResult(
      co2AvoidedKg: co2Kg,
      fuelSavedLiters: 0.0,
      costSavedUsd: costSaved,
      pm25PreventedGrams: kwhSaved * 0.04, // Avoided thermal power plant PM emissions
      assumptionNotes: 'Grid emissions factor: 0.475 kg CO2e/kWh (global grid average). Power cost baseline: \$0.16/kWh.',
    );
  }
}
