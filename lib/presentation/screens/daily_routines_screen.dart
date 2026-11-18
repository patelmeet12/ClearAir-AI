import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/daily_routine.dart';
import '../providers/routine_provider.dart';
import '../providers/ai_assistant_provider.dart';
import '../widgets/why_this_matters_dialog.dart';

class DailyRoutinesScreen extends ConsumerWidget {
  const DailyRoutinesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routineState = ref.watch(routineProvider);

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
                      'DYNAMIC DAILY PLANNER',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF0D9488),
                          ),
                    ),
                    Text(
                      'Smart Daily Routine Generator',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ],
                ),
                ElevatedButton.icon(
                  onPressed: () => ref.read(routineProvider.notifier).resetRoutines(),
                  icon: const Icon(Icons.auto_awesome, size: 16),
                  label: const Text('Re-Generate Plan'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Personalized diurnal schedule balancing personal lung exposure protection against urban emissions reduction. Tailored to local diurnal smog peaks and your household composition.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 20),

            // Progress Summary Strip
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Today\'s Routine Completion: ${routineState.completedCount} of ${routineState.routines.length} Tasks',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: routineState.completionRate,
                            minHeight: 8,
                            backgroundColor: Colors.grey.withValues(alpha: 0.2),
                            valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    '${(routineState.completionRate * 100).toInt()}%',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF0D9488),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Routine Slots: Morning, Afternoon, Evening, Night
            ...RoutineTimeSlot.values.map((slot) {
              final slotItems = routineState.routines.where((r) => r.timeSlot == slot).toList();
              if (slotItems.isEmpty) return const SizedBox.shrink();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        slot == RoutineTimeSlot.morning
                            ? Icons.wb_sunny_outlined
                            : slot == RoutineTimeSlot.afternoon
                                ? Icons.wb_sunny
                                : slot == RoutineTimeSlot.evening
                                    ? Icons.nights_stay_outlined
                                    : Icons.bedtime_outlined,
                        size: 20,
                        color: const Color(0xFF0D9488),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${slot.label.toUpperCase()} (${slot.timeRange})',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.8),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  ...slotItems.map((routine) => _buildRoutineCard(context, ref, routine)),
                  const SizedBox(height: 16),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildRoutineCard(BuildContext context, WidgetRef ref, RoutineItem routine) {
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
                              color: routine.priority == RoutinePriority.high
                                  ? Colors.red.withValues(alpha: 0.12)
                                  : Colors.orange.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              routine.priority.label,
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: routine.priority == RoutinePriority.high ? Colors.red.shade700 : Colors.orange.shade700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            routine.suggestedTime,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                            ),
                          ),
                          const Spacer(),
                          TextButton.icon(
                            style: TextButton.styleFrom(padding: EdgeInsets.zero),
                            onPressed: () async {
                              final explainer = await ref.read(aiAssistantProvider.notifier).getImpactExplanation(
                                    actionTitle: routine.title,
                                    co2AvoidedKg: routine.co2AvoidedKg,
                                    fuelSavedLiters: routine.fuelSavedLiters,
                                    pm25PreventedGrams: (routine.co2AvoidedKg * 0.012),
                                  );
                              if (context.mounted) {
                                WhyThisMattersDialog.show(context, explainer);
                              }
                            },
                            icon: const Icon(Icons.info_outline, size: 14),
                            label: const Text('Why This Matters', style: TextStyle(fontSize: 12)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        routine.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          decoration: routine.isCompleted ? TextDecoration.lineThrough : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        routine.reason,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Theme.of(context).scaffoldBackgroundColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _metaPill(context, 'Cost', routine.estimatedCost),
                  _metaPill(context, 'Convenience', routine.convenience),
                  _metaPill(context, 'Exposure Reduction', routine.exposureReduction),
                  _metaPill(context, 'Eco Impact', routine.environmentalBenefit),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metaPill(BuildContext context, String title, String val) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
        const SizedBox(height: 2),
        Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
