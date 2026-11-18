/// Transparent emission factors and physical assumptions
/// Used to calculate environmental impact without exaggeration.
class EmissionFactors {
  // Transport emissions per passenger-kilometer (in grams CO2e)
  static const double carSoloGasolineCo2PerKm = 171.0; // g CO2e / km
  static const double carpool2PersonCo2PerKm = 85.5; // g CO2e / km per person
  static const double publicBusCo2PerKm = 68.0; // g CO2e / pass-km
  static const double electricMetroCo2PerKm = 28.0; // g CO2e / pass-km
  static const double cyclingWalkingCo2PerKm = 0.0; // Zero direct tailpipe

  // Fine particulate matter (PM2.5) tailpipe + non-exhaust brake/tire wear (mg per km)
  static const double carGasolinePm25PerKmMg = 24.0; // mg PM2.5 / km
  static const double busPm25PerKmMg = 6.0; // mg PM2.5 / passenger-km

  // Vehicle Idling
  static const double idlingFuelConsumptionPerHourLiters = 1.2; // L / hour
  static const double gasolineCo2PerLiterKg = 2.31; // kg CO2 / L
  static const double idlingCo2PerMinuteKg = (1.2 * 2.31) / 60.0; // ~0.046 kg CO2/min

  // Energy & Household
  static const double gridElectricityCo2PerKwhKg = 0.475; // Global weighted avg kg CO2e / kWh
  static const double cookingGasLpgCo2PerKg = 2.98; // kg CO2 / kg LPG

  // Fuel price baseline for cost savings estimate (USD average)
  static const double avgFuelCostPerLiterUsd = 1.35;
  static const double avgFuelEfficiencyKmPerLiter = 12.5; // ~8 L/100km
}
