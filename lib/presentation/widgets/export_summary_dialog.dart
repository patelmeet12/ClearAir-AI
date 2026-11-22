import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/models/air_quality.dart';
import '../providers/indoor_provider.dart';
import '../providers/routine_provider.dart';
import '../providers/sustainable_provider.dart';

class ExportSummaryDialog extends StatelessWidget {
  final AirQualityData? aqiData;
  final RoutineState routineState;
  final IndoorState indoorState;
  final SustainableState sustState;

  const ExportSummaryDialog({
    super.key,
    required this.aqiData,
    required this.routineState,
    required this.indoorState,
    required this.sustState,
  });

  static Future<void> show({
    required BuildContext context,
    required AirQualityData? aqiData,
    required RoutineState routineState,
    required IndoorState indoorState,
    required SustainableState sustState,
  }) {
    return showDialog<void>(
      context: context,
      builder: (ctx) => ExportSummaryDialog(
        aqiData: aqiData,
        routineState: routineState,
        indoorState: indoorState,
        sustState: sustState,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final nowStr = DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now());
    final summaryText = '''
========================================
CLEARAIR AI — PERSONAL CLEAN AIR SUMMARY
Generated: $nowStr
Location: ${aqiData?.locationName ?? "Local"}
Current AQI: ${aqiData?.aqi ?? 150} (${aqiData?.category.title ?? "Poor"})
PM2.5: ${aqiData?.pm25.toStringAsFixed(1) ?? "N/A"} µg/m³
PM10: ${aqiData?.pm10.toStringAsFixed(1) ?? "N/A"} µg/m³
Data Source: ${aqiData?.dataSourceName ?? "ClearAir Local"}
----------------------------------------
DAILY ROUTINE PROGRESS:
Completed: ${routineState.completedCount} / ${routineState.routines.length} (${(routineState.completionRate * 100).toInt()}%)
CO2e Avoided Today: ${routineState.completedImpact.co2AvoidedKg.toStringAsFixed(2)} kg
Fuel Saved Today: ${routineState.completedImpact.fuelSavedLiters.toStringAsFixed(2)} L
----------------------------------------
INDOOR AIR QUALITY CHECKLIST:
Protection Score: ${(indoorState.completionRate * 100).toInt()}%
Filter Replacement Due: ${indoorState.isFilterReplacementDue ? "YES (Overdue)" : "NO (Clean)"}
----------------------------------------
MONTHLY SUSTAINABILITY ADOPTION:
Adopted Routines: ${sustState.adoptedCount}
Estimated Monthly CO2e Benefit: ${sustState.personalImpact.co2AvoidedKg.toStringAsFixed(1)} kg
Estimated Monthly Cost Savings: \$${sustState.personalImpact.costSavedUsd.toStringAsFixed(0)}
----------------------------------------
DISCLAIMER:
Environmental protection guidance only — not clinical medical advice.
========================================
''';

    return AlertDialog(
      title: const Text('ClearAir Environmental Report'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: SelectableText(
            summaryText,
            style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    );
  }
}
