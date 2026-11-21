import '../constants/aqi_standards.dart';

/// Enumeration of air pollutants tracked by Clean Air monitoring systems.
enum PollutantType {
  pm25('PM2.5', 'Fine Particulate Matter (≤ 2.5 µm)', 'µg/m³'),
  pm10('PM10', 'Inhalable Particulate Matter (≤ 10 µm)', 'µg/m³'),
  no2('NO2', 'Nitrogen Dioxide', 'µg/m³'),
  so2('SO2', 'Sulfur Dioxide', 'µg/m³'),
  co('CO', 'Carbon Monoxide', 'µg/m³'),
  o3('O3', 'Ground-Level Ozone', 'µg/m³');

  final String formula;
  final String label;
  final String unit;

  const PollutantType(this.formula, this.label, this.unit);
}

/// Centralized domain authority for pollutant health thresholds, standards,
/// sanitization, and unit specifications across WHO, US EPA, and India CPCB scales.
class PollutantStandards {
  // WHO Global Air Quality Guidelines (2021) 24-hour thresholds in µg/m³
  static const double whoPm25DailyLimit = 15.0;
  static const double whoPm10DailyLimit = 45.0;
  static const double whoNo2DailyLimit = 25.0;
  static const double whoSo2DailyLimit = 40.0;
  static const double whoO3DailyLimit = 100.0; // 8-hour daily maximum
  static const double whoCoDailyLimit = 4000.0; // 24-hour average in µg/m³ (4 mg/m³)

  // US EPA National Ambient Air Quality Standards (NAAQS) 24-hour / 1-hour thresholds in µg/m³
  static const double usEpaPm25Limit = 35.0; // 24-hour standard (35 µg/m³)
  static const double usEpaPm10Limit = 150.0; // 24-hour standard (150 µg/m³)
  static const double usEpaNo2Limit = 188.0; // 1-hour standard (~100 ppb -> ~188 µg/m³)
  static const double usEpaSo2Limit = 196.0; // 1-hour standard (~75 ppb -> ~196 µg/m³)
  static const double usEpaO3Limit = 137.0; // 8-hour standard (70 ppb -> ~137 µg/m³)
  static const double usEpaCoLimit = 10000.0; // 8-hour standard (9 ppm -> ~10,000 µg/m³)

  // India Central Pollution Control Board (CPCB) NAQI 24-hour thresholds in µg/m³
  static const double indiaCpcbPm25Limit = 60.0; // Satisfactory upper boundary
  static const double indiaCpcbPm10Limit = 100.0; // Satisfactory upper boundary
  static const double indiaCpcbNo2Limit = 80.0; // 24-hour standard
  static const double indiaCpcbSo2Limit = 80.0; // 24-hour standard
  static const double indiaCpcbO3Limit = 100.0; // 8-hour standard
  static const double indiaCpcbCoLimit = 2000.0; // 8-hour standard (2 mg/m³ -> 2000 µg/m³)

  /// Retrieves the numerical threshold boundary for a specific pollutant according to standard.
  static double getStandardLimit(PollutantType type, AqiStandard standard) {
    if (standard == AqiStandard.indiaNaqi) {
      switch (type) {
        case PollutantType.pm25:
          return indiaCpcbPm25Limit;
        case PollutantType.pm10:
          return indiaCpcbPm10Limit;
        case PollutantType.no2:
          return indiaCpcbNo2Limit;
        case PollutantType.so2:
          return indiaCpcbSo2Limit;
        case PollutantType.o3:
          return indiaCpcbO3Limit;
        case PollutantType.co:
          return indiaCpcbCoLimit;
      }
    } else {
      // US EPA / WHO Reference baseline
      switch (type) {
        case PollutantType.pm25:
          return whoPm25DailyLimit;
        case PollutantType.pm10:
          return whoPm10DailyLimit;
        case PollutantType.no2:
          return whoNo2DailyLimit;
        case PollutantType.so2:
          return whoSo2DailyLimit;
        case PollutantType.o3:
          return whoO3DailyLimit;
        case PollutantType.co:
          return whoCoDailyLimit;
      }
    }
  }

  /// Determines if a measured pollutant concentration is within the healthy boundary.
  static bool isWithinLimit(PollutantType type, double value, AqiStandard standard) {
    if (value.isNaN || value.isInfinite) return false;
    final limit = getStandardLimit(type, standard);
    return value <= limit;
  }

  /// Human-readable label for UI cards displaying the active authority limit.
  static String getLimitDescription(PollutantType type, AqiStandard standard) {
    final limit = getStandardLimit(type, standard);
    final suffix = standard == AqiStandard.indiaNaqi ? 'CPCB' : 'WHO';
    if (type == PollutantType.co && limit >= 1000) {
      return '${(limit / 1000).toStringAsFixed(0)} mg/m³ ($suffix)';
    }
    return '${limit.toStringAsFixed(0)} µg/m³ ($suffix)';
  }

  /// Sanitizes raw incoming telemetry: converts null, NaN, or negative sensor fault codes
  /// (e.g. -999.0, -1.0) into safe, non-negative values.
  static double sanitize(num? value, {double defaultValue = 0.0}) {
    if (value == null) return defaultValue;
    final double d = value.toDouble();
    if (d.isNaN || d.isInfinite || d < 0) {
      return defaultValue;
    }
    return d;
  }

  /// Health implications based on pollutant type and severity.
  static String getHealthWarning(PollutantType type, double value) {
    if (value <= 0) return 'Undetected or negligible concentration.';
    switch (type) {
      case PollutantType.pm25:
        if (value > 150) return 'Deep microscopic lung and bloodstream penetration. Highest cardiovascular risk.';
        if (value > 35) return 'Fine aerosol irritation for sensitive respiratory groups and asthmatics.';
        return 'Fine particulate level acceptable for normal daily activities.';
      case PollutantType.pm10:
        if (value > 250) return 'Severe dust haze causing airway inflammation, cough, and throat irritation.';
        if (value > 50) return 'Noticeable coarse particulate matter from road dust and construction.';
        return 'Coarse particulate within safe baseline.';
      case PollutantType.no2:
        if (value > 100) return 'Traffic combustion gas elevating asthma triggers and bronchial hyperactivity.';
        return 'Combustion byproduct within safe atmospheric dispersal limits.';
      case PollutantType.so2:
        if (value > 100) return 'Sulfur emissions from industrial fuel; can cause acute bronchoconstriction.';
        return 'Sulfur dioxide concentrations normal.';
      case PollutantType.o3:
        if (value > 150) return 'Photochemical smog causing airway irritation and reduced lung capacity.';
        return 'Ground-level ozone within safe ambient parameters.';
      case PollutantType.co:
        if (value > 10000) return 'Elevated carbon monoxide reducing oxygen transport to vital organs.';
        return 'Carbon monoxide levels safe and well below toxicity thresholds.';
    }
  }
}
