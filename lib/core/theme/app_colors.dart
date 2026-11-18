import 'package:flutter/material.dart';

/// App color palette designed for high contrast and environmental clarity.
/// Complies with WCAG 2.2 AA contrast standards.
class AppColors {
  // Brand foundations
  static const Color primaryTeal = Color(0xFF0D9488); // Teal 600
  static const Color primaryTealLight = Color(0xFF14B8A6); // Teal 500
  static const Color primaryTealDark = Color(0xFF0F766E); // Teal 700

  static const Color accentGreen = Color(0xFF10B981); // Emerald 500
  static const Color accentGreenDark = Color(0xFF059669); // Emerald 600

  static const Color navyDarkest = Color(0xFF0A1128); // Foundation dark
  static const Color navySurface = Color(0xFF0F172A); // Slate 900
  static const Color navyCard = Color(0xFF1E293B); // Slate 800
  static const Color navyCardBorder = Color(0xFF334155); // Slate 700

  static const Color lightBg = Color(0xFFF8FAFC); // Slate 50
  static const Color lightCard = Color(0xFFFFFFFF);
  static const Color lightCardBorder = Color(0xFFE2E8F0); // Slate 200
  static const Color lightTextPrimary = Color(0xFF0F172A); // Slate 900
  static const Color lightTextSecondary = Color(0xFF475569); // Slate 600
  static const Color lightTextMuted = Color(0xFF64748B); // Slate 500

  static const Color darkTextPrimary = Color(0xFFF8FAFC); // Slate 50
  static const Color darkTextSecondary = Color(0xFFCBD5E1); // Slate 300
  static const Color darkTextMuted = Color(0xFF94A3B8); // Slate 400

  // Air Quality Status Colors (EPA / Global standard palette)
  static const Color aqiGood = Color(0xFF10B981); // Emerald 500 (0-50)
  static const Color aqiModerate = Color(0xFFF59E0B); // Amber 500 (51-100)
  static const Color aqiPoor = Color(0xFFF97316); // Orange 500 (101-150 / Sensitive)
  static const Color aqiUnhealthy = Color(0xFFEF4444); // Red 500 (151-200)
  static const Color aqiVeryPoor = Color(0xFF8B5CF6); // Purple 500 (201-300)
  static const Color aqiSevere = Color(0xFF701A75); // Deep Fuchsia / Maroon (301+)

  // State colors
  static const Color statusLive = Color(0xFF0284C7); // Sky 600
  static const Color statusCached = Color(0xFFD97706); // Amber 600
  static const Color statusDemo = Color(0xFF9333EA); // Purple 600
  static const Color statusEstimated = Color(0xFF2563EB); // Blue 600

  static Color forAqi(int aqi) {
    if (aqi <= 50) return aqiGood;
    if (aqi <= 100) return aqiModerate;
    if (aqi <= 150) return aqiPoor;
    if (aqi <= 200) return aqiUnhealthy;
    if (aqi <= 300) return aqiVeryPoor;
    return aqiSevere;
  }
}
