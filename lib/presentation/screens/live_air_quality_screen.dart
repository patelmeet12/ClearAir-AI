import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../domain/models/air_quality.dart';
import '../../domain/models/location.dart';
import '../providers/air_quality_provider.dart';
import '../providers/app_providers.dart';
import '../providers/location_provider.dart';
import '../providers/settings_provider.dart';
import '../widgets/add_location_dialog.dart';
import '../widgets/aqi_badge.dart';

class LiveAirQualityScreen extends ConsumerStatefulWidget {
  const LiveAirQualityScreen({super.key});

  @override
  ConsumerState<LiveAirQualityScreen> createState() => _LiveAirQualityScreenState();
}

class _LiveAirQualityScreenState extends ConsumerState<LiveAirQualityScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<LocationItem> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final locs = ref.read(locationProvider).savedLocations;
      if (locs.isNotEmpty) {
        ref.read(airQualityProvider.notifier).loadComparison(locs);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }
    setState(() => _isSearching = true);
    final repo = ref.read(airQualityRepositoryProvider);
    final results = await repo.searchLocations(query.trim());
    if (mounted) {
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final locationState = ref.watch(locationProvider);
    final aqiState = ref.watch(airQualityProvider);
    final settings = ref.watch(settingsProvider);
    final currentLoc = locationState.selectedLocation;
    final aqiData = aqiState.data;

    // Reactively refresh comparison list when saved locations change
    ref.listen<LocationState>(locationProvider, (previous, next) {
      if (previous?.savedLocations != next.savedLocations && next.savedLocations.isNotEmpty) {
        ref.read(airQualityProvider.notifier).loadComparison(next.savedLocations);
      }
    });

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Screen Title & Search Row
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'LOCATION-AWARE MONITORING',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0D9488),
                          ),
                    ),
                    Text(
                      'Live Air Quality & Multi-Location Comparison',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => AddLocationDialog.show(context),
                  icon: const Icon(Icons.add_location_alt_outlined),
                  label: const Text('Add Saved Location'),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Search Bar for Any Global City
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search any global city or station (e.g. Delhi, London, Tokyo, Los Angeles)...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: 'Clear search query',
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
              ),
              onChanged: (val) {
                if (val.length >= 2) {
                  _performSearch(val);
                } else if (val.isEmpty) {
                  _performSearch('');
                }
              },
            ),

            if (_isSearching)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
                child: LinearProgressIndicator(),
              ),

            // Search Results Dropdown
            if (_searchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardTheme.color,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300),
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchResults.length,
                  separatorBuilder: (context, index) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final item = _searchResults[index];
                    return ListTile(
                      leading: const Icon(Icons.location_on_outlined, color: Color(0xFF0D9488)),
                      title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${item.country} (${item.latitude.toStringAsFixed(2)}°, ${item.longitude.toStringAsFixed(2)}°)'),
                      trailing: ElevatedButton(
                        onPressed: () {
                          ref.read(locationProvider.notifier).addOrUpdateLocation(item);
                          ref.read(locationProvider.notifier).selectLocation(item);
                          setState(() {
                            _searchResults = [];
                            _searchController.clear();
                          });
                        },
                        child: const Text('Select'),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),

            // Saved Locations Quick Switch Chips
            Text(
              'SAVED MONITORING LOCATIONS',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: locationState.savedLocations.map((loc) {
                final isSelected = loc.id == currentLoc?.id;
                return ChoiceChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        loc.tag == LocationTag.home
                            ? Icons.home
                            : loc.tag == LocationTag.workplace
                                ? Icons.business
                                : Icons.school,
                        size: 14,
                        color: isSelected ? Colors.white : Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 6),
                      Text(loc.name),
                      if (loc.isDefault) ...[
                        const SizedBox(width: 4),
                        const Icon(Icons.star, size: 14, color: Colors.amber),
                      ],
                    ],
                  ),
                  selected: isSelected,
                  onSelected: (val) {
                    ref.read(locationProvider.notifier).selectLocation(loc);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Active Location Detailed Telemetry
            if (aqiData != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    aqiData.locationName,
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(width: 10),
                                  AqiBadge(category: aqiData.getCategory(settings.aqiStandard)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Coordinates: ${aqiData.latitude.toStringAsFixed(3)}°N, ${aqiData.longitude.toStringAsFixed(3)}°E • DataSource: ${aqiData.dataSourceType.label}',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                              ),
                            ],
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                            tooltip: 'Remove saved location',
                            onPressed: () {
                              if (currentLoc != null) {
                                ref.read(locationProvider.notifier).removeLocation(currentLoc.id);
                              }
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // 24-Hour Diurnal Forecast Trend Chart
                      Text(
                        '24-HOUR AIR QUALITY & PM2.5 FORECAST TRAJECTORY',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0D9488),
                            ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 220,
                        child: aqiData.hourlyForecast.isEmpty
                            ? const Center(child: Text('No hourly forecast available'))
                            : Semantics(
                                label: '24-hour diurnal air quality forecast trajectory chart. '
                                    'Peak forecast AQI: ${aqiData.hourlyForecast.map((e) => e.aqi).reduce(math.max)}, '
                                    'Minimum AQI: ${aqiData.hourlyForecast.map((e) => e.aqi).reduce(math.min)}.',
                                child: LineChart(
                                  LineChartData(
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      getDrawingHorizontalLine: (value) => FlLine(
                                        color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300,
                                        strokeWidth: 1,
                                      ),
                                    ),
                                    titlesData: FlTitlesData(
                                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          interval: 4,
                                          getTitlesWidget: (val, meta) {
                                            final idx = val.toInt();
                                            if (idx >= 0 && idx < aqiData.hourlyForecast.length) {
                                              final t = aqiData.hourlyForecast[idx].time;
                                              return Padding(
                                                padding: const EdgeInsets.only(top: 8),
                                                child: Text(
                                                  DateFormat('ha').format(t),
                                                  style: const TextStyle(fontSize: 11),
                                                ),
                                              );
                                            }
                                            return const Text('');
                                          },
                                        ),
                                      ),
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 38,
                                          interval: 100,
                                          getTitlesWidget: (val, meta) => Text(
                                            val.toInt().toString(),
                                            style: const TextStyle(fontSize: 11),
                                          ),
                                        ),
                                      ),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    minY: 0,
                                    maxY: 500,
                                    lineBarsData: [
                                      LineChartBarData(
                                        spots: aqiData.hourlyForecast.asMap().entries.map((e) {
                                          return FlSpot(e.key.toDouble(), e.value.aqi.toDouble());
                                        }).toList(),
                                        isCurved: true,
                                        color: aqiData.getCategory(settings.aqiStandard).color,
                                        barWidth: 3,
                                        belowBarData: BarAreaData(
                                          show: true,
                                          color: aqiData.getCategory(settings.aqiStandard).color.withValues(alpha: 0.15),
                                        ),
                                        dotData: const FlDotData(show: false),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Multi-Location Pollution Comparison Table
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'CROSS-LOCATION POLLUTION COMPARISON',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              letterSpacing: 1.2,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF0D9488),
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Compare air quality between home, office, and school to time travels safely.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                if (aqiState.isComparing)
                  const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    tooltip: 'Refresh comparison data',
                    onPressed: () {
                      ref.read(airQualityProvider.notifier).loadComparison(locationState.savedLocations);
                    },
                  ),
              ],
            ),
            const SizedBox(height: 12),

            Card(
              child: ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: locationState.savedLocations.length,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final loc = locationState.savedLocations[index];
                  final isCurrent = loc.id == currentLoc?.id;

                  // Find data from managed comparison list
                  AirQualityData? itemData;
                  for (final item in aqiState.comparisonList) {
                    if (item.locationName == loc.name ||
                        ((item.latitude - loc.latitude).abs() < 0.05 &&
                            (item.longitude - loc.longitude).abs() < 0.05)) {
                      itemData = item;
                      break;
                    }
                  }

                  // Fallback to active aqiData if this is current location
                  if (itemData == null && isCurrent && aqiData != null) {
                    itemData = aqiData;
                  }

                  final itemCategory = itemData?.getCategory(settings.aqiStandard);

                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: itemCategory != null ? itemCategory.color.withValues(alpha: 0.15) : Colors.grey.shade200,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        loc.tag == LocationTag.home
                            ? Icons.home
                            : loc.tag == LocationTag.workplace
                                ? Icons.business
                                : Icons.school,
                        color: itemCategory?.color ?? Colors.grey,
                        size: 20,
                      ),
                    ),
                    title: Row(
                      children: [
                        Text(loc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(width: 8),
                        if (isCurrent)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('ACTIVE', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                      ],
                    ),
                    subtitle: Text('${loc.tag.label} • ${loc.country}'),
                    trailing: itemData != null && itemCategory != null
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${itemData.aqi} AQI',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: itemCategory.color,
                                    ),
                                  ),
                                  Text(
                                    'PM2.5: ${itemData.pm25.toStringAsFixed(1)} µg/m³',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              AqiBadge(category: itemCategory),
                            ],
                          )
                        : const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                    onTap: () {
                      ref.read(locationProvider.notifier).selectLocation(loc);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
