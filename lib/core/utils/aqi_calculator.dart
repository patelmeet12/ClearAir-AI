class AqiCalculator {
  /// Calculate US EPA AQI from PM2.5 concentration in ug/m3 using official breakpoints
  static int pm25ToAqi(double pm25) {
    if (pm25 < 0) return 0;
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

  static int _linear(int iHigh, int iLow, double cHigh, double cLow, double c) {
    final double result = ((iHigh - iLow) / (cHigh - cLow)) * (c - cLow) + iLow;
    return result.round();
  }

  /// Estimated reduction in inhaled PM2.5 dose when wearing an N95 respirator correctly (95% filtration)
  static double calculateRespiratorExposureReduction({
    required double outdoorPm25,
    required double exposureHours,
    required bool wearingN95,
  }) {
    // Average resting/light exertion inhalation volume ~ 0.8 m3 / hour
    final double inhaledVolumeM3 = exposureHours * 0.8;
    final double totalAmbientDoseUg = outdoorPm25 * inhaledVolumeM3;
    if (wearingN95) {
      return totalAmbientDoseUg * 0.95; // 95% filtered out
    }
    return 0.0;
  }
}
