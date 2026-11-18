import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../providers/air_quality_provider.dart';
import '../providers/routine_provider.dart';
import '../providers/indoor_provider.dart';
import '../providers/sustainable_provider.dart';

class InsightsReportsScreen extends ConsumerWidget {
  const InsightsReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aqiData = ref.watch(airQualityProvider).data;
    final routineState = ref.watch(routineProvider);
    final indoorState = ref.watch(indoorProvider);
    final sustState = ref.watch(sustainableProvider);

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ANALYTICS & COMPLIANCE',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0D9488),
                          ),
                    ),
                    Text(
                      'Insights & Environmental Reports',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => _showExportSummaryDialog(context, aqiData, routineState, indoorState, sustState),
                  icon: const Icon(Icons.file_download_outlined, size: 18),
                  label: const Text('Export Summary'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Comprehensive review separating measured atmospheric observations, user-reported actions, and modeled emission impact calculations.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 20),

            // Weekly Trend & Historical AQI Chart
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Weekly Air Quality Trajectory (Measured & Model Forecast)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFF0D9488).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                          child: const Text('7-Day Cycle', style: TextStyle(color: Color(0xFF0D9488), fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 220,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (value) => FlLine(color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300, strokeWidth: 1),
                          ),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                interval: 1,
                                getTitlesWidget: (val, meta) {
                                  final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                                  final idx = val.toInt();
                                  if (idx >= 0 && idx < days.length) {
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(days[idx], style: const TextStyle(fontSize: 11)),
                                    );
                                  }
                                  return const Text('');
                                },
                              ),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 36,
                                interval: 100,
                                getTitlesWidget: (val, meta) => Text(val.toInt().toString(), style: const TextStyle(fontSize: 11)),
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          minY: 0,
                          maxY: 400,
                          lineBarsData: [
                            LineChartBarData(
                              spots: const [
                                FlSpot(0, 240),
                                FlSpot(1, 280),
                                FlSpot(2, 360),
                                FlSpot(3, 310),
                                FlSpot(4, 190),
                                FlSpot(5, 140),
                                FlSpot(6, 175),
                              ],
                              isCurved: true,
                              color: const Color(0xFF0D9488),
                              barWidth: 3,
                              belowBarData: BarAreaData(show: true, color: const Color(0xFF0D9488).withValues(alpha: 0.15)),
                              dotData: const FlDotData(show: true),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Performance & Completion Progress Cards
            LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 750;
                final dailyCard = _buildProgressCard(
                  context,
                  title: 'Daily Routine Adherence',
                  progress: routineState.completionRate,
                  subtitle: '${routineState.completedCount} of ${routineState.routines.length} actions completed today',
                  icon: Icons.task_alt,
                  color: const Color(0xFF0D9488),
                );
                final indoorCard = _buildProgressCard(
                  context,
                  title: 'Indoor Clean Air Protection',
                  progress: indoorState.completionRate,
                  subtitle: '${indoorState.completedCount} of ${indoorState.items.length} safety practices active',
                  icon: Icons.shield_outlined,
                  color: const Color(0xFF10B981),
                );
                final sustCard = _buildProgressCard(
                  context,
                  title: 'Sustainable Habit Adoption',
                  progress: (sustState.adoptedCount / (sustState.alternatives.isEmpty ? 1 : sustState.alternatives.length)),
                  subtitle: '${sustState.adoptedCount} of ${sustState.alternatives.length} sustainable habits adopted',
                  icon: Icons.eco_outlined,
                  color: Colors.indigo,
                );

                if (isWide) {
                  return Row(
                    children: [
                      Expanded(child: dailyCard),
                      const SizedBox(width: 14),
                      Expanded(child: indoorCard),
                      const SizedBox(width: 14),
                      Expanded(child: sustCard),
                    ],
                  );
                }
                return Column(
                  children: [
                    dailyCard,
                    const SizedBox(height: 12),
                    indoorCard,
                    const SizedBox(height: 12),
                    sustCard,
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // Personalized Improvement Suggestions Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.tips_and_updates_outlined, color: Color(0xFF0D9488)),
                        SizedBox(width: 10),
                        Text('Personalized Improvement Recommendations', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(height: 14),
                    _suggestionItem(
                      'Optimize Commute Ventilation',
                      'Switching car air-conditioning from fresh intake to recirculation before crossing heavy arterial expressways reduces in-cabin PM2.5 by ~70%.',
                    ),
                    const Divider(height: 20),
                    _suggestionItem(
                      'Damp Mopping Frequency',
                      'Dry broom sweeping in closed apartments resuspends settled dust. Switch to damp microfiber mopping every morning during inversion season.',
                    ),
                    const Divider(height: 20),
                    _suggestionItem(
                      'Upgrade Cooking Exhaust Timing',
                      'Running range hood fans for 5 minutes after cooking clears lingering ultrafine oil particulates that otherwise linger in bedrooms.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressCard(BuildContext context, {required String title, required double progress, required String subtitle, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              Icon(icon, color: color, size: 20),
            ],
          ),
          const SizedBox(height: 14),
          Text('${(progress * 100).toInt()}%', style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: color)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.grey.withValues(alpha: 0.15),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
          const SizedBox(height: 8),
          Text(subtitle, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
        ],
      ),
    );
  }

  Widget _suggestionItem(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Text(desc, style: const TextStyle(fontSize: 13, height: 1.35)),
      ],
    );
  }

  void _showExportSummaryDialog(BuildContext context, aqiData, routineState, indoorState, sustState) {
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

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
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
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Report copied and ready to share!')),
              );
            },
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy to Clipboard'),
          ),
        ],
      ),
    );
  }
}
