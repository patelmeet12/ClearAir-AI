import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

enum AqiStandard {
  usEpa('US EPA AQI', 'Standard 0-500 index used internationally by US EPA and Open-Meteo'),
  indiaNaqi('India NAQI', 'National Air Quality Index standard with Severe 400+ smog categories');

  final String label;
  final String description;
  const AqiStandard(this.label, this.description);
}

enum AqiCategory {
  good('Good', 'Air quality is satisfactory and poses little or no risk.', AppColors.aqiGood),
  moderate('Moderate', 'Air quality is acceptable; sensitive individuals should consider limiting prolonged outdoor exertion.', AppColors.aqiModerate),
  poor('Poor', 'Members of sensitive groups may experience health effects. General public less likely affected.', AppColors.aqiPoor),
  veryPoor('Very Poor', 'Increased likelihood of adverse effects and aggravation to heart and lungs. Avoid strenuous outdoor activities.', AppColors.aqiVeryPoor),
  severe('Severe', 'Emergency conditions. Everyone should avoid all outdoor physical activity and keep indoor spaces sealed.', AppColors.aqiSevere);

  final String title;
  final String healthImplication;
  final Color color;

  const AqiCategory(this.title, this.healthImplication, this.color);

  String outdoorGuidance() {
    switch (this) {
      case AqiCategory.good:
        return 'Ideal conditions for outdoor walks, cycling, running, and school sports.';
      case AqiCategory.moderate:
        return 'Generally safe for outdoor activities. Unusually sensitive people should take breaks.';
      case AqiCategory.poor:
        return 'Reduce prolonged outdoor exertion. Children and older adults should reschedule vigorous sports.';
      case AqiCategory.veryPoor:
        return 'Avoid outdoor exercise. Keep commutes brief and wear a well-fitted particulate respirator (N95/FFP2).';
      case AqiCategory.severe:
        return 'Hazardous air. Strictly cancel outdoor activities. Stay indoors with air purification running.';
    }
  }

  String indoorGuidance() {
    switch (this) {
      case AqiCategory.good:
        return 'Excellent time for natural ventilation and fresh air circulation.';
      case AqiCategory.moderate:
        return 'Ventilation is safe during midday hours when humidity and pollution dip.';
      case AqiCategory.poor:
        return 'Keep windows mostly closed. Run indoor air purifiers on low/medium speed.';
      case AqiCategory.veryPoor:
        return 'Keep all doors and windows tightly shut. Run true HEPA purifiers continuously. Avoid cooking fumes.';
      case AqiCategory.severe:
        return 'Create a clean-air room. Seal window leaks with damp towels. Turn purifiers to high. No candles or incense.';
    }
  }
}

class AqiScale {
  static AqiCategory categoryForAqi(int aqi, [AqiStandard standard = AqiStandard.usEpa]) {
    if (standard == AqiStandard.usEpa) {
      if (aqi <= 50) return AqiCategory.good;
      if (aqi <= 100) return AqiCategory.moderate;
      if (aqi <= 150) return AqiCategory.poor;
      if (aqi <= 200) return AqiCategory.poor; // Unhealthy
      if (aqi <= 300) return AqiCategory.veryPoor;
      return AqiCategory.severe;
    } else {
      // India NAQI
      if (aqi <= 50) return AqiCategory.good;
      if (aqi <= 100) return AqiCategory.moderate; // Satisfactory
      if (aqi <= 200) return AqiCategory.poor; // Moderate
      if (aqi <= 300) return AqiCategory.poor; // Poor
      if (aqi <= 400) return AqiCategory.veryPoor; // Very Poor
      return AqiCategory.severe; // Severe 401-500
    }
  }

  static String exposureLevel(int aqi) {
    if (aqi <= 50) return 'Minimal Exposure';
    if (aqi <= 100) return 'Low-Moderate Exposure';
    if (aqi <= 150) return 'Elevated Sensitive Exposure';
    if (aqi <= 200) return 'High Public Exposure';
    if (aqi <= 300) return 'Very High Hazardous Exposure';
    return 'Extreme Toxic Smog Exposure';
  }
}
