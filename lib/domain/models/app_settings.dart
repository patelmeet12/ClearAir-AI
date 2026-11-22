import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../core/constants/aqi_standards.dart';

class AppSettings extends Equatable {
  final ThemeMode themeMode;
  final AqiStandard aqiStandard;
  final bool reducedMotion;
  final bool isDemoMode;
  final bool useRealGenAi;
  final String genAiApiKey;
  final String genAiEndpoint;
  final bool allowGeolocation;

  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.aqiStandard = AqiStandard.usEpa,
    this.reducedMotion = false,
    this.isDemoMode = false,
    this.useRealGenAi = false,
    this.genAiApiKey = '',
    this.genAiEndpoint = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent',
    this.allowGeolocation = false,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    AqiStandard? aqiStandard,
    bool? reducedMotion,
    bool? isDemoMode,
    bool? useRealGenAi,
    String? genAiApiKey,
    String? genAiEndpoint,
    bool? allowGeolocation,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      aqiStandard: aqiStandard ?? this.aqiStandard,
      reducedMotion: reducedMotion ?? this.reducedMotion,
      isDemoMode: isDemoMode ?? this.isDemoMode,
      useRealGenAi: useRealGenAi ?? this.useRealGenAi,
      genAiApiKey: genAiApiKey ?? this.genAiApiKey,
      genAiEndpoint: genAiEndpoint ?? this.genAiEndpoint,
      allowGeolocation: allowGeolocation ?? this.allowGeolocation,
    );
  }

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.name,
    'aqiStandard': aqiStandard.name,
    'reducedMotion': reducedMotion,
    'isDemoMode': isDemoMode,
    'useRealGenAi': useRealGenAi,
    'genAiApiKey': genAiApiKey,
    'genAiEndpoint': genAiEndpoint,
    'allowGeolocation': allowGeolocation,
  };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    themeMode: ThemeMode.values.firstWhere(
      (m) => m.name == json['themeMode'],
      orElse: () => ThemeMode.system,
    ),
    aqiStandard: AqiStandard.values.firstWhere(
      (s) => s.name == json['aqiStandard'],
      orElse: () => AqiStandard.usEpa,
    ),
    reducedMotion: json['reducedMotion'] as bool? ?? false,
    isDemoMode: json['isDemoMode'] as bool? ?? false,
    useRealGenAi: json['useRealGenAi'] as bool? ?? false,
    genAiApiKey: json['genAiApiKey'] as String? ?? '',
    genAiEndpoint: json['genAiEndpoint'] as String? ??
        'https://generativelanguage.googleapis.com/v1beta/models/gemini-1.5-flash:generateContent',
    allowGeolocation: json['allowGeolocation'] as bool? ?? false,
  );

  @override
  List<Object?> get props => [
    themeMode,
    aqiStandard,
    reducedMotion,
    isDemoMode,
    useRealGenAi,
    genAiApiKey,
    genAiEndpoint,
    allowGeolocation,
  ];
}
