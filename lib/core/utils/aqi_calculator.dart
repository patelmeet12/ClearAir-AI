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

  /// Calculate US EPA AQI from NO2 concentration in µg/m³
  static int no2ToUsAqi(double no2) {
    if (no2.isNaN || no2 <= 0) return 0;
    if (no2.isInfinite) return 500;
    if (no2 <= 100.0) {
      return _linear(50, 0, 100.0, 0.0, no2);
    } else if (no2 <= 188.0) {
      return _linear(100, 51, 188.0, 100.1, no2);
    } else if (no2 <= 676.0) {
      return _linear(150, 101, 676.0, 188.1, no2);
    } else if (no2 <= 1220.0) {
      return _linear(200, 151, 1220.0, 676.1, no2);
    } else if (no2 <= 2348.0) {
      return _linear(300, 201, 2348.0, 1220.1, no2);
    } else {
      return _linear(500, 301, 3850.0, 2348.1, no2);
    }
  }

  /// Calculate US EPA AQI from SO2 concentration in µg/m³
  static int so2ToUsAqi(double so2) {
    if (so2.isNaN || so2 <= 0) return 0;
    if (so2.isInfinite) return 500;
    if (so2 <= 92.0) {
      return _linear(50, 0, 92.0, 0.0, so2);
    } else if (so2 <= 196.0) {
      return _linear(100, 51, 196.0, 92.1, so2);
    } else if (so2 <= 485.0) {
      return _linear(150, 101, 485.0, 196.1, so2);
    } else if (so2 <= 796.0) {
      return _linear(200, 151, 796.0, 485.1, so2);
    } else if (so2 <= 1582.0) {
      return _linear(300, 201, 1582.0, 796.1, so2);
    } else {
      return _linear(500, 301, 2630.0, 1582.1, so2);
    }
  }

  /// Calculate US EPA AQI from CO concentration in µg/m³
  static int coToUsAqi(double co) {
    if (co.isNaN || co <= 0) return 0;
    if (co.isInfinite) return 500;
    if (co <= 5000.0) {
      return _linear(50, 0, 5000.0, 0.0, co);
    } else if (co <= 10760.0) {
      return _linear(100, 51, 10760.0, 5000.1, co);
    } else if (co <= 14200.0) {
      return _linear(150, 101, 14200.0, 10760.1, co);
    } else if (co <= 17630.0) {
      return _linear(200, 151, 17630.0, 14200.1, co);
    } else if (co <= 34800.0) {
      return _linear(300, 201, 34800.0, 17630.1, co);
    } else {
      return _linear(500, 301, 57700.0, 34800.1, co);
    }
  }

  /// Calculate US EPA AQI from O3 concentration in µg/m³
  static int o3ToUsAqi(double o3) {
    if (o3.isNaN || o3 <= 0) return 0;
    if (o3.isInfinite) return 500;
    if (o3 <= 106.0) {
      return _linear(50, 0, 106.0, 0.0, o3);
    } else if (o3 <= 137.0) {
      return _linear(100, 51, 137.0, 106.1, o3);
    } else if (o3 <= 167.0) {
      return _linear(150, 101, 167.0, 137.1, o3);
    } else if (o3 <= 206.0) {
      return _linear(200, 151, 206.0, 167.1, o3);
    } else if (o3 <= 392.0) {
      return _linear(300, 201, 392.0, 206.1, o3);
    } else {
      return _linear(500, 301, 1176.0, 392.1, o3);
    }
  }

  /// Calculate India NAQI (CPCB) from NO2 concentration in µg/m³
  static int no2ToIndiaNaqi(double no2) {
    if (no2.isNaN || no2 <= 0) return 0;
    if (no2.isInfinite) return 500;
    if (no2 <= 40.0) {
      return _linear(50, 0, 40.0, 0.0, no2);
    } else if (no2 <= 80.0) {
      return _linear(100, 51, 80.0, 40.1, no2);
    } else if (no2 <= 180.0) {
      return _linear(200, 101, 180.0, 80.1, no2);
    } else if (no2 <= 280.0) {
      return _linear(300, 201, 280.0, 180.1, no2);
    } else if (no2 <= 400.0) {
      return _linear(400, 301, 400.0, 280.1, no2);
    } else {
      return _linear(500, 401, 500.0, 400.1, no2);
    }
  }

  /// Calculate India NAQI (CPCB) from SO2 concentration in µg/m³
  static int so2ToIndiaNaqi(double so2) {
    if (so2.isNaN || so2 <= 0) return 0;
    if (so2.isInfinite) return 500;
    if (so2 <= 40.0) {
      return _linear(50, 0, 40.0, 0.0, so2);
    } else if (so2 <= 80.0) {
      return _linear(100, 51, 80.0, 40.1, so2);
    } else if (so2 <= 380.0) {
      return _linear(200, 101, 380.0, 80.1, so2);
    } else if (so2 <= 800.0) {
      return _linear(300, 201, 800.0, 380.1, so2);
    } else if (so2 <= 1600.0) {
      return _linear(400, 301, 1600.0, 800.1, so2);
    } else {
      return _linear(500, 401, 2000.0, 1600.1, so2);
    }
  }

  /// Calculate India NAQI (CPCB) from CO concentration in µg/m³ (1 mg/m³ = 1000 µg/m³)
  static int coToIndiaNaqi(double co) {
    if (co.isNaN || co <= 0) return 0;
    if (co.isInfinite) return 500;
    if (co <= 1000.0) {
      return _linear(50, 0, 1000.0, 0.0, co);
    } else if (co <= 2000.0) {
      return _linear(100, 51, 2000.0, 1000.1, co);
    } else if (co <= 10000.0) {
      return _linear(200, 101, 10000.0, 2000.1, co);
    } else if (co <= 17000.0) {
      return _linear(300, 201, 17000.0, 10000.1, co);
    } else if (co <= 34000.0) {
      return _linear(400, 301, 34000.0, 17000.1, co);
    } else {
      return _linear(500, 401, 50000.0, 34000.1, co);
    }
  }

  /// Calculate India NAQI (CPCB) from O3 concentration in µg/m³
  static int o3ToIndiaNaqi(double o3) {
    if (o3.isNaN || o3 <= 0) return 0;
    if (o3.isInfinite) return 500;
    if (o3 <= 50.0) {
      return _linear(50, 0, 50.0, 0.0, o3);
    } else if (o3 <= 100.0) {
      return _linear(100, 51, 100.0, 50.1, o3);
    } else if (o3 <= 168.0) {
      return _linear(200, 101, 168.0, 100.1, o3);
    } else if (o3 <= 208.0) {
      return _linear(300, 201, 208.0, 168.1, o3);
    } else if (o3 <= 748.0) {
      return _linear(400, 301, 748.0, 208.1, o3);
    } else {
      return _linear(500, 401, 1000.0, 748.1, o3);
    }
  }

  /// Calculates composite overall AQI based on selected standard and available criteria pollutants.
  /// Follows the EPA/CPCB maximum sub-index principle across all evaluated pollutants.
  static int calculateAqi({
    required double pm25,
    double? pm10,
    double? no2,
    double? so2,
    double? co,
    double? o3,
    AqiStandard standard = AqiStandard.usEpa,
  }) {
    if (standard == AqiStandard.indiaNaqi) {
      int maxSubIndex = pm25ToIndiaNaqi(pm25);
      if (pm10 != null && pm10 > 0) {
        maxSubIndex = math.max(maxSubIndex, pm10ToIndiaNaqi(pm10));
      }
      if (no2 != null && no2 > 0) {
        maxSubIndex = math.max(maxSubIndex, no2ToIndiaNaqi(no2));
      }
      if (so2 != null && so2 > 0) {
        maxSubIndex = math.max(maxSubIndex, so2ToIndiaNaqi(so2));
      }
      if (co != null && co > 0) {
        maxSubIndex = math.max(maxSubIndex, coToIndiaNaqi(co));
      }
      if (o3 != null && o3 > 0) {
        maxSubIndex = math.max(maxSubIndex, o3ToIndiaNaqi(o3));
      }
      return maxSubIndex;
    } else {
      int maxSubIndex = pm25ToAqi(pm25);
      if (pm10 != null && pm10 > 0) {
        maxSubIndex = math.max(maxSubIndex, pm10ToUsAqi(pm10));
      }
      if (no2 != null && no2 > 0) {
        maxSubIndex = math.max(maxSubIndex, no2ToUsAqi(no2));
      }
      if (so2 != null && so2 > 0) {
        maxSubIndex = math.max(maxSubIndex, so2ToUsAqi(so2));
      }
      if (co != null && co > 0) {
        maxSubIndex = math.max(maxSubIndex, coToUsAqi(co));
      }
      if (o3 != null && o3 > 0) {
        maxSubIndex = math.max(maxSubIndex, o3ToUsAqi(o3));
      }
      return maxSubIndex;
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
