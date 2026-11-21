import 'dart:math' as math;
import '../constants/aqi_standards.dart';

/// Accurate, tested sub-index calculation engine adhering to US EPA and India CPCB standards.
class AqiCalculator {
  /// Calculate US EPA AQI from PM2.5 concentration in µg/m³ using official breakpoints.
  static int pm25ToAqi(double pm25) {
    if (pm25.isNaN || pm25 <= 0) return 0;
    if (pm25.isInfinite) return 500;

    if (pm25 <= 12.0) {
      return _linear(50, 0, 12.0, 0.0, pm25);
    } else if (pm25 <= 35.4) {
      return _linear(100, 51, 35.4, 12.1, pm25);
    } else if (pm25 <= 55.4) {
      return _linear(150, 101, 55.4, 35.5, pm25);
    } else if (pm25 <= 150.4) {
      return _linear(200, 151, 150.4, 55.5, pm25);
    } else if (pm25 <= 250.4) {
      return _linear(300, 201, 250.4, 150.5, pm25);
    } else if (pm25 <= 350.4) {
      return _linear(400, 301, 350.4, 250.5, pm25);
    } else if (pm25 <= 500.4) {
      return _linear(500, 401, 500.4, 350.5, pm25);
    } else {
      return 500;
    }
  }

  /// Calculate US EPA AQI from PM10 concentration in µg/m³ using official breakpoints.
  static int pm10ToUsAqi(double pm10) {
    if (pm10.isNaN || pm10 <= 0) return 0;
    if (pm10.isInfinite) return 500;

    if (pm10 <= 54.0) {
      return _linear(50, 0, 54.0, 0.0, pm10);
    } else if (pm10 <= 154.0) {
      return _linear(100, 51, 154.0, 55.0, pm10);
    } else if (pm10 <= 254.0) {
      return _linear(150, 101, 254.0, 155.0, pm10);
    } else if (pm10 <= 354.0) {
      return _linear(200, 151, 354.0, 255.0, pm10);
    } else if (pm10 <= 424.0) {
      return _linear(300, 201, 424.0, 355.0, pm10);
    } else if (pm10 <= 504.0) {
      return _linear(400, 301, 504.0, 425.0, pm10);
    } else if (pm10 <= 604.0) {
      return _linear(500, 401, 604.0, 505.0, pm10);
    } else {
      return 500;
    }
  }

  /// Calculate India NAQI (CPCB) from PM2.5 concentration in µg/m³
  static int pm25ToIndiaNaqi(double pm25) {
    if (pm25.isNaN || pm25 <= 0) return 0;
    if (pm25.isInfinite) return 500;

    if (pm25 <= 30.0) {
      return _linear(50, 0, 30.0, 0.0, pm25);
    } else if (pm25 <= 60.0) {
      return _linear(100, 51, 60.0, 31.0, pm25);
    } else if (pm25 <= 90.0) {
      return _linear(200, 101, 90.0, 61.0, pm25);
    } else if (pm25 <= 120.0) {
      return _linear(300, 201, 120.0, 91.0, pm25);
    } else if (pm25 <= 250.0) {
      return _linear(400, 301, 250.0, 121.0, pm25);
    } else if (pm25 <= 380.0) {
      return _linear(500, 401, 380.0, 250.1, pm25);
    } else {
      return 500;
    }
  }

  /// Calculate India NAQI (CPCB) from PM10 concentration in µg/m³
  static int pm10ToIndiaNaqi(double pm10) {
    if (pm10.isNaN || pm10 <= 0) return 0;
    if (pm10.isInfinite) return 500;

    if (pm10 <= 50.0) {
      return _linear(50, 0, 50.0, 0.0, pm10);
    } else if (pm10 <= 100.0) {
      return _linear(100, 51, 100.0, 51.0, pm10);
    } else if (pm10 <= 250.0) {
      return _linear(200, 101, 250.0, 101.0, pm10);
    } else if (pm10 <= 350.0) {
      return _linear(300, 201, 350.0, 251.0, pm10);
    } else if (pm10 <= 430.0) {
      return _linear(400, 301, 430.0, 351.0, pm10);
    } else if (pm10 <= 550.0) {
      return _linear(500, 401, 550.0, 431.0, pm10);
    } else {
      return 500;
    }
  }

  /// Calculates composite overall AQI based on selected standard and available pollutants.
  /// Follows the EPA/CPCB maximum sub-index principle.
  static int calculateAqi({
    required double pm25,
    double? pm10,
    AqiStandard standard = AqiStandard.usEpa,
  }) {
    if (standard == AqiStandard.indiaNaqi) {
      final aqiPm25 = pm25ToIndiaNaqi(pm25);
      if (pm10 != null && pm10 > 0) {
        final aqiPm10 = pm10ToIndiaNaqi(pm10);
        return math.max(aqiPm25, aqiPm10);
      }
      return aqiPm25;
    } else {
      final aqiPm25 = pm25ToAqi(pm25);
      if (pm10 != null && pm10 > 0) {
        final aqiPm10 = pm10ToUsAqi(pm10);
        return math.max(aqiPm25, aqiPm10);
      }
      return aqiPm25;
    }
  }

  static int _linear(int iHigh, int iLow, double cHigh, double cLow, double c) {
    if (cHigh == cLow) return iLow;
    final double result = ((iHigh - iLow) / (cHigh - cLow)) * (c - cLow) + iLow;
    return result.round().clamp(0, 500);
  }

  /// Estimated reduction in inhaled PM2.5 dose when wearing an N95 respirator correctly (95% filtration)
  static double calculateRespiratorExposureReduction({
    required double outdoorPm25,
    required double exposureHours,
    required bool wearingN95,
  }) {
    if (outdoorPm25 <= 0 || exposureHours <= 0) return 0.0;
    // Average resting/light exertion inhalation volume ~ 0.8 m3 / hour
    final double inhaledVolumeM3 = exposureHours * 0.8;
    final double totalAmbientDoseUg = outdoorPm25 * inhaledVolumeM3;
    if (wearingN95) {
      return totalAmbientDoseUg * 0.95; // 95% filtered out
    }
    return 0.0;
  }
}
