import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/indoor_provider.dart';
import '../providers/air_quality_provider.dart';

class IndoorAirScreen extends ConsumerWidget {
  const IndoorAirScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indoorState = ref.watch(indoorProvider);
    final aqiData = ref.watch(airQualityProvider).data;
    final isSevere = (aqiData?.aqi ?? 150) >= 200;

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
                      'INDOOR PROTECTION & PURIFICATION',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0D9488),
                          ),
                    ),
                    Text(
                      'Indoor Air Quality Optimizer',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () => ref.read(indoorProvider.notifier).resetChecklist(),
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Reset Checklist'),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Filter Replacement Tracker Card
            _buildFilterTrackerCard(context, ref, indoorState),
            const SizedBox(height: 20),

            // Plant Myth Reality Check Alert Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0F766E).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF0F766E).withValues(alpha: 0.3)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.science_outlined, color: Color(0xFF0F766E), size: 26),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Scientific Fact-Check: Houseplants & Dangerous PM2.5',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF0F766E)),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'While potted plants are aesthetically pleasing and metabolize minimal gaseous VOCs under laboratory conditions, scientific consensus confirms that potted plants DO NOT meaningfully remove dangerous ambient PM2.5 or PM10 in residential rooms. Sealed windows and certified mechanical HEPA filtration are essential.',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.4),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Outdoor AQI Dynamic Ventilation Banner
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isSevere ? Colors.red.withValues(alpha: 0.08) : Colors.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: isSevere ? Colors.red.shade300 : Colors.green.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    isSevere ? Icons.window_outlined : Icons.air,
                    color: isSevere ? Colors.red : Colors.green,
                    size: 28,
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isSevere ? 'Ventilation Alert: Keep Windows Sealed' : 'Ventilation Advisory: Safe Air Exchange Window',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: isSevere ? Colors.red.shade800 : Colors.green.shade800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isSevere
                              ? 'Outdoor PM2.5 is hazardous (${aqiData?.pm25.toStringAsFixed(1) ?? "elevated"} µg/m³). Natural ventilation will flood indoor air with smog. Rely strictly on closed-room HEPA purification.'
                              : 'Outdoor air is acceptable. Open opposite windows for 15 minutes to flush indoor CO2 and cooking vapors.',
                          style: TextStyle(
                            fontSize: 12,
                            color: isSevere ? Colors.red.shade900 : Colors.green.shade900,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Interactive Checklist
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'COMPREHENSIVE INDOOR PROTECTION CHECKLIST',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                ),
                Text(
                  '${indoorState.completedCount} of ${indoorState.items.length} Completed (${(indoorState.completionRate * 100).toInt()}%)',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Color(0xFF0D9488)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ...indoorState.items.map((item) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            label: 'Mark "${item.title}" as ${item.isCompleted ? "incomplete" : "completed"}',
                            child: Checkbox(
                              value: item.isCompleted,
                              onChanged: (val) {
                                ref.read(indoorProvider.notifier).toggleItem(item.id, val ?? false);
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
                                        color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item.category.label,
                                        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.grey.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        item.costTier.label,
                                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                    decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  item.actionDescription,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.info_outline, size: 14, color: Color(0xFF0D9488)),
                                const SizedBox(width: 6),
                                Text(
                                  'Scientific Why: ${item.scientificWhy}',
                                  style: const TextStyle(fontSize: 12, height: 1.3),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.savings_outlined, size: 14, color: Color(0xFF10B981)),
                                const SizedBox(width: 6),
                                Text(
                                  'Budget Guidance: ${item.budgetAdvice}',
                                  style: const TextStyle(fontSize: 12, height: 1.3),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterTrackerCard(BuildContext context, WidgetRef ref, indoorState) {
    final dateStr = indoorState.lastFilterDate != null
        ? DateFormat('MMM d, yyyy').format(indoorState.lastFilterDate!)
        : 'Not recorded';
    final days = indoorState.daysSinceFilterReplacement;
    final isDue = indoorState.isFilterReplacementDue;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (isDue ? Colors.red : const Color(0xFF0D9488)).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.filter_alt_outlined,
                color: isDue ? Colors.red : const Color(0xFF0D9488),
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HEPA Filter Lifespan Tracker',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isDue ? Colors.red : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last replaced: $dateStr ($days days ago • ${isDue ? "Replacement Overdue" : "${90 - days} days remaining"})',
                    style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7)),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(indoorProvider.notifier).recordFilterReplacementNow();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Filter replacement date recorded as today! Tracker reset.')),
                );
              },
              child: const Text('Mark Replaced Today'),
            ),
          ],
        ),
      ),
    );
  }
}
