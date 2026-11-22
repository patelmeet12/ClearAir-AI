import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/pollutant_standards.dart';
import '../providers/ai_assistant_provider.dart';
import '../providers/air_quality_provider.dart';
import '../providers/household_provider.dart';
import '../providers/indoor_provider.dart';
import '../providers/location_provider.dart';
import '../providers/routine_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/aqi_gauge.dart';
import '../widgets/atmospheric_conditions_bar.dart';
import '../widgets/data_status_indicator.dart';
import '../widgets/family_safety_banner.dart';
import '../widgets/guidance_card.dart';
import '../widgets/impact_summary_card.dart';
import '../widgets/pollutant_chip.dart';
import '../widgets/why_this_matters_dialog.dart';

class HomeDashboardScreen extends ConsumerWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final aqiState = ref.watch(airQualityProvider);
    final locationState = ref.watch(locationProvider);
    final householdProfile = ref.watch(householdProvider);
    final routineState = ref.watch(routineProvider);
    final indoorState = ref.watch(indoorProvider);
    final settings = ref.watch(settingsProvider);

    if (aqiState.isLoading && aqiState.data == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Gathering atmospheric air measurements...'),
          ],
        ),
      );
    }

    final data = aqiState.data;
    if (data == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 48, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No air quality data available'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => ref.read(airQualityProvider.notifier).refresh(),
              child: const Text('Retry Connection'),
            ),
          ],
        ),
      );
    }

    final impact = routineState.completedImpact;
    final aqiStandard = settings.aqiStandard;
    final category = data.getCategory(aqiStandard);

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(airQualityProvider.notifier).refresh();
          await ref.read(routineProvider.notifier).generateRoutines();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Status Strip
              DataStatusIndicator(
                dataSourceType: data.dataSourceType,
                sourceName: data.dataSourceName,
                lastUpdated: data.lastUpdated,
                hasLocationPermission: locationState.selectedLocation != null,
                onRefresh: () => ref.read(airQualityProvider.notifier).refresh(),
              ),
              const SizedBox(height: 16),

              // Main AQI Gauge & Exposure Hero with standard adaptability
              AqiGauge(
                airQuality: data,
                standard: aqiStandard,
              ),
              const SizedBox(height: 20),

              // Weather & Key Atmospheric Conditions
              AtmosphericConditionsBar(airQuality: data),
              const SizedBox(height: 20),

              // Outdoor Activity & Indoor Protection Guidance Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  final outdoorCard = GuidanceCard(
                    title: 'Outdoor Activity Guidance',
                    content: category.outdoorGuidance(),
                    icon: Icons.directions_walk,
                    iconColor: category.color,
                  );
                  final indoorCard = GuidanceCard(
                    title: 'Indoor Air Strategy',
                    content: category.indoorGuidance(),
                    icon: Icons.home_work_outlined,
                    iconColor: const Color(0xFF0D9488),
                  );

                  if (isWide) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(child: outdoorCard),
                        const SizedBox(width: 16),
                        Expanded(child: indoorCard),
                      ],
                    );
                  }
                  return Column(
                    children: [
                      outdoorCard,
                      const SizedBox(height: 14),
                      indoorCard,
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),

              // Family Vulnerability Alert (if sensitive members present)
              if (householdProfile.hasSensitiveMembers)
                FamilySafetyBanner(householdProfile: householdProfile),

              const SizedBox(height: 24),

              // Today's Recommended Actions (Personal Routine)
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 12,
                runSpacing: 8,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'TODAY\'S PRIORITIZED ACTIONS',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0D9488),
                            ),
                      ),
                      Text(
                        'Smart Daily Protection & Emissions',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  TextButton.icon(
                    onPressed: () => context.go('/routines'),
                    icon: const Icon(Icons.arrow_forward, size: 16),
                    label: const Text('View All Routines'),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Routine items preview (top 3)
              if (routineState.routines.isEmpty)
                Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Icon(Icons.auto_awesome, color: Color(0xFF0D9488)),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Text(
                            'Generate tailored morning, afternoon, and commute routines for today’s air quality.',
                            style: TextStyle(fontSize: 13),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () => ref.read(routineProvider.notifier).generateRoutines(),
                          child: const Text('Generate Routines'),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...routineState.routines.take(3).map((routine) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            label: 'Mark routine "${routine.title}" as ${routine.isCompleted ? "incomplete" : "completed"}',
                            child: Checkbox(
                              value: routine.isCompleted,
                              onChanged: (val) async {
                                final completed = val ?? false;
                                await ref.read(routineProvider.notifier).toggleCompletion(routine.id, completed);
                                if (completed && context.mounted) {
                                  final explainer = await ref.read(aiAssistantProvider.notifier).getImpactExplanation(
                                        actionTitle: routine.title,
                                        co2AvoidedKg: routine.co2AvoidedKg,
                                        fuelSavedLiters: routine.fuelSavedLiters,
                                        pm25PreventedGrams: (routine.co2AvoidedKg * 0.012),
                                      );
                                  if (context.mounted) {
                                    WhyThisMattersDialog.show(context, explainer);
                                  }
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        routine.timeSlot.label,
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).colorScheme.primary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      routine.suggestedTime,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  routine.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    decoration: routine.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  routine.reason,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                                      ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              const SizedBox(height: 20),

              // Environmental Impact of Completed Actions
              ImpactSummaryCard(impact: impact, count: routineState.completedCount),
              const SizedBox(height: 24),

              // Indoor Filter Maintenance Alert
              if (indoorState.isFilterReplacementDue)
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.amber.shade700),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800, size: 28),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HEPA Filter Replacement Recommended',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Your primary filter has been running for ${indoorState.daysSinceFilterReplacement} days. Saturated filters decrease clean air delivery rate (CADR).',
                              style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
                            ),
                          ],
                        ),
                      ),
                      OutlinedButton(
                        onPressed: () => context.go('/indoor'),
                        child: const Text('Review Filter'),
                      ),
                    ],
                  ),
                ),

              // Detailed Pollutant Grid using domain standard utilities
              Text(
                'SPECIFIC POLLUTANT CONCENTRATIONS (${aqiStandard.label})',
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final int crossAxisCount = constraints.maxWidth > 900
                      ? 6
                      : constraints.maxWidth > 550
                          ? 3
                          : 2;
                  return GridView.count(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: constraints.maxWidth > 900 ? 1.15 : 1.45,
                    children: [
                      PollutantMetricCard(
                        label: PollutantType.pm25.label,
                        formula: PollutantType.pm25.formula,
                        value: data.pm25.toStringAsFixed(1),
                        unit: PollutantType.pm25.unit,
                        safetyLimit: PollutantStandards.getLimitDescription(PollutantType.pm25, aqiStandard),
                        isSafe: PollutantStandards.isWithinLimit(PollutantType.pm25, data.pm25, aqiStandard),
                      ),
                      PollutantMetricCard(
                        label: PollutantType.pm10.label,
                        formula: PollutantType.pm10.formula,
                        value: data.pm10.toStringAsFixed(1),
                        unit: PollutantType.pm10.unit,
                        safetyLimit: PollutantStandards.getLimitDescription(PollutantType.pm10, aqiStandard),
                        isSafe: PollutantStandards.isWithinLimit(PollutantType.pm10, data.pm10, aqiStandard),
                      ),
                      PollutantMetricCard(
                        label: PollutantType.no2.label,
                        formula: PollutantType.no2.formula,
                        value: data.no2.toStringAsFixed(1),
                        unit: PollutantType.no2.unit,
                        safetyLimit: PollutantStandards.getLimitDescription(PollutantType.no2, aqiStandard),
                        isSafe: PollutantStandards.isWithinLimit(PollutantType.no2, data.no2, aqiStandard),
                      ),
                      PollutantMetricCard(
                        label: PollutantType.o3.label,
                        formula: PollutantType.o3.formula,
                        value: data.o3.toStringAsFixed(1),
                        unit: PollutantType.o3.unit,
                        safetyLimit: PollutantStandards.getLimitDescription(PollutantType.o3, aqiStandard),
                        isSafe: PollutantStandards.isWithinLimit(PollutantType.o3, data.o3, aqiStandard),
                      ),
                      PollutantMetricCard(
                        label: PollutantType.so2.label,
                        formula: PollutantType.so2.formula,
                        value: data.so2.toStringAsFixed(1),
                        unit: PollutantType.so2.unit,
                        safetyLimit: PollutantStandards.getLimitDescription(PollutantType.so2, aqiStandard),
                        isSafe: PollutantStandards.isWithinLimit(PollutantType.so2, data.so2, aqiStandard),
                      ),
                      PollutantMetricCard(
                        label: PollutantType.co.label,
                        formula: PollutantType.co.formula,
                        value: data.co.toStringAsFixed(0),
                        unit: PollutantType.co.unit,
                        safetyLimit: PollutantStandards.getLimitDescription(PollutantType.co, aqiStandard),
                        isSafe: PollutantStandards.isWithinLimit(PollutantType.co, data.co, aqiStandard),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
