import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/air_quality.dart';
import '../providers/air_quality_provider.dart';
import '../providers/household_provider.dart';
import '../providers/location_provider.dart';
import '../providers/routine_provider.dart';
import '../providers/indoor_provider.dart';
import '../providers/ai_assistant_provider.dart';
import '../widgets/aqi_gauge.dart';
import '../widgets/pollutant_chip.dart';
import '../widgets/data_status_indicator.dart';
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

              // Main AQI Gauge & Exposure Hero
              AqiGauge(airQuality: data),
              const SizedBox(height: 20),

              // Weather & Key Atmospheric Conditions
              _buildAtmosphericBar(context, data),
              const SizedBox(height: 20),

              // Outdoor Activity & Indoor Protection Guidance Cards
              LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 700;
                  final outdoorCard = _buildGuidanceCard(
                    context,
                    title: 'Outdoor Activity Guidance',
                    content: data.category.outdoorGuidance(),
                    icon: Icons.directions_walk,
                    iconColor: data.category.color,
                  );
                  final indoorCard = _buildGuidanceCard(
                    context,
                    title: 'Indoor Air Strategy',
                    content: data.category.indoorGuidance(),
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
                _buildFamilySafetyBanner(context, householdProfile, data),

              const SizedBox(height: 24),

              // Today's Recommended Actions (Personal Routine)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              ...routineState.routines.take(3).map((routine) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
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
              _buildImpactSummaryCard(context, impact, routineState.completedCount),
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

              // Detailed Pollutant Grid
              Text(
                'SPECIFIC POLLUTANT CONCENTRATIONS',
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
                        label: 'Fine Particulates',
                        formula: 'PM2.5',
                        value: data.pm25.toStringAsFixed(1),
                        unit: 'µg/m³',
                        safetyLimit: '15 µg/m³ (WHO)',
                        isSafe: data.pm25 <= 15.0,
                      ),
                      PollutantMetricCard(
                        label: 'Coarse Dust',
                        formula: 'PM10',
                        value: data.pm10.toStringAsFixed(1),
                        unit: 'µg/m³',
                        safetyLimit: '45 µg/m³ (WHO)',
                        isSafe: data.pm10 <= 45.0,
                      ),
                      PollutantMetricCard(
                        label: 'Nitrogen Dioxide',
                        formula: 'NO2',
                        value: data.no2.toStringAsFixed(1),
                        unit: 'µg/m³',
                        safetyLimit: '25 µg/m³',
                        isSafe: data.no2 <= 25.0,
                      ),
                      PollutantMetricCard(
                        label: 'Ozone',
                        formula: 'O3',
                        value: data.o3.toStringAsFixed(1),
                        unit: 'µg/m³',
                        safetyLimit: '100 µg/m³',
                        isSafe: data.o3 <= 100.0,
                      ),
                      PollutantMetricCard(
                        label: 'Sulfur Dioxide',
                        formula: 'SO2',
                        value: data.so2.toStringAsFixed(1),
                        unit: 'µg/m³',
                        safetyLimit: '40 µg/m³',
                        isSafe: data.so2 <= 40.0,
                      ),
                      PollutantMetricCard(
                        label: 'Carbon Monoxide',
                        formula: 'CO',
                        value: data.co.toStringAsFixed(0),
                        unit: 'µg/m³',
                        safetyLimit: '4000 µg/m³',
                        isSafe: data.co <= 4000.0,
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

  Widget _buildAtmosphericBar(BuildContext context, AirQualityData data) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Expanded(child: _weatherItem(context, Icons.thermostat, '${data.temperatureC.toStringAsFixed(1)}°C', 'Temp')),
          Expanded(child: _weatherItem(context, Icons.water_drop_outlined, '${data.humidityPercent.toStringAsFixed(0)}%', 'Humidity')),
          Expanded(child: _weatherItem(context, Icons.air, '${data.windSpeedKmh.toStringAsFixed(1)} km/h', 'Wind')),
          Expanded(
            child: _weatherItem(
              context,
              data.weatherCode == 45 ? Icons.foggy : Icons.wb_sunny_outlined,
              data.weatherCode == 45 ? 'Smog/Fog' : 'Fair',
              'Sky',
            ),
          ),
        ],
      ),
    );
  }

  Widget _weatherItem(BuildContext context, IconData icon, String val, String title) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 20, color: const Color(0xFF0D9488)),
        const SizedBox(height: 4),
        Text(val, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text(title, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
      ],
    );
  }

  Widget _buildGuidanceCard(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    required Color iconColor,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFamilySafetyBanner(BuildContext context, householdProfile, AirQualityData data) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D9488).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.family_restroom, color: Color(0xFF0D9488), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Household Vulnerability Advisory Active',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Profile includes ${householdProfile.children} children and ${householdProfile.olderAdults} older adults. '
                  '${householdProfile.vulnerability.advisory}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.go('/family'),
            child: const Text('Edit Household'),
          ),
        ],
      ),
    );
  }

  Widget _buildImpactSummaryCard(BuildContext context, impact, int count) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0D9488).withValues(alpha: 0.15),
            const Color(0xFF10B981).withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            runSpacing: 4,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.eco, color: Color(0xFF10B981), size: 20),
                  const SizedBox(width: 6),
                  Text(
                    'ESTIMATED IMPACT ($count ACTIONS)',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 0.8),
                  ),
                ],
              ),
              Text(
                'Transparent Model',
                style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _impactMetric(context, '${impact.co2AvoidedKg.toStringAsFixed(2)} kg', 'CO2e Avoided')),
              Expanded(child: _impactMetric(context, '${impact.fuelSavedLiters.toStringAsFixed(2)} L', 'Fuel Saved')),
              Expanded(child: _impactMetric(context, '\$${impact.costSavedUsd.toStringAsFixed(2)}', 'Money Saved')),
              Expanded(child: _impactMetric(context, '${(impact.pm25PreventedGrams * 1000).toStringAsFixed(0)} mg', 'PM2.5 Prevented')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _impactMetric(BuildContext context, String value, String label) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7))),
      ],
    );
  }
}
