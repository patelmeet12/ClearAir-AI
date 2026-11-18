import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/household_profile.dart';
import '../providers/household_provider.dart';
import '../providers/air_quality_provider.dart';

class FamilySafetyScreen extends ConsumerWidget {
  const FamilySafetyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(householdProvider);
    final aqiData = ref.watch(airQualityProvider).data;
    final isSevere = (aqiData?.aqi ?? 150) >= 200;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'FAMILY SAFETY & HOUSEHOLD PLANNER',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D9488),
                  ),
            ),
            Text(
              'Personalized Household Protection Matrix',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Configure your family demographics and sensitivity profile. ClearAir AI adjusts all outdoor recommendations, routine timings, and indoor filter priorities accordingly.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 20),

            // Household Composition Editor Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Household Composition (No PII Required)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildCounter(
                            context,
                            title: 'Adults',
                            count: profile.adults,
                            onChanged: (val) => ref.read(householdProvider.notifier).updateProfile(profile.copyWith(adults: val)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildCounter(
                            context,
                            title: 'Children (< 14)',
                            count: profile.children,
                            onChanged: (val) => ref.read(householdProvider.notifier).updateProfile(profile.copyWith(children: val)),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildCounter(
                            context,
                            title: 'Older Adults (65+)',
                            count: profile.olderAdults,
                            onChanged: (val) => ref.read(householdProvider.notifier).updateProfile(profile.copyWith(olderAdults: val)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 16),

                    // Health Vulnerability Category
                    const Text(
                      'Sensitivity & Vulnerability Profile',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<VulnerabilityFlag>(
                      initialValue: profile.vulnerability,
                      decoration: const InputDecoration(labelText: 'Sensitivity Factor'),
                      items: VulnerabilityFlag.values.map((v) {
                        return DropdownMenuItem(value: v, child: Text(v.label));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(householdProvider.notifier).updateProfile(profile.copyWith(vulnerability: val));
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Budget Preference
                    const Text(
                      'Household Clean-Air Budget Preference',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<HouseholdBudget>(
                      initialValue: profile.budget,
                      decoration: const InputDecoration(labelText: 'Budget Tier'),
                      items: HouseholdBudget.values.map((b) {
                        return DropdownMenuItem(value: b, child: Text(b.label));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          ref.read(householdProvider.notifier).updateProfile(profile.copyWith(budget: val));
                        }
                      },
                    ),
                    const SizedBox(height: 16),

                    // Schedule Switches
                    SwitchListTile(
                      title: const Text('Daily Work / Commute Routine Active'),
                      subtitle: const Text('Generates transit & commute-specific exposure guidance'),
                      value: profile.hasWorkCommute,
                      onChanged: (val) => ref.read(householdProvider.notifier).updateProfile(profile.copyWith(hasWorkCommute: val)),
                    ),
                    SwitchListTile(
                      title: const Text('School Attendance Routine Active'),
                      subtitle: const Text('Includes morning drop-off and outdoor recess advisories'),
                      value: profile.hasSchoolSchedule,
                      onChanged: (val) => ref.read(householdProvider.notifier).updateProfile(profile.copyWith(hasSchoolSchedule: val)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Tailored Family Protection Checklist for Current Conditions
            Text(
              'TAILORED FAMILY PROTECTION CHECKLIST',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D9488),
                  ),
            ),
            const SizedBox(height: 12),

            _buildFamilyProtectionChecklist(context, profile, isSevere),
          ],
        ),
      ),
    );
  }

  Widget _buildCounter(
    BuildContext context, {
    required String title,
    required int count,
    required ValueChanged<int> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300),
      ),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.remove_circle_outline),
                onPressed: count > 0 ? () => onChanged(count - 1) : null,
              ),
              Text('$count', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => onChanged(count + 1),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFamilyProtectionChecklist(BuildContext context, HouseholdProfile profile, bool isSevere) {
    final List<Map<String, dynamic>> items = [
      if (profile.children > 0)
        {
          'title': isSevere ? 'Equip Children with Pediatric-Sized N95/KF94 Masks' : 'Monitor Afternoon Playground Conditions',
          'description': isSevere
              ? 'Adult masks do not seal on small children\'s faces. A loose mask allows unfiltered PM2.5 to bypass through cheek gaps.'
              : 'Children breathe more air relative to body mass. Check midday AQI before permitting vigorous sports.',
          'icon': Icons.child_care,
        },
      if (profile.olderAdults > 0)
        {
          'title': 'Shift Senior Walk Routines Indoors',
          'description': 'Encourage indoor walking in temperature-controlled spaces during winter morning inversion hours.',
          'icon': Icons.elderly,
        },
      if (profile.vulnerability == VulnerabilityFlag.respiratory)
        {
          'title': 'Asthma / Respiratory Action Plan Ready',
          'description': 'Ensure doctor-prescribed rescue inhalers are kept within immediate reach at home, school, and work.',
          'icon': Icons.air,
        },
      {
        'title': 'Establish a Designated "Clean Air Haven" Room',
        'description': 'Select one bedroom with the fewest windows. Run your highest-capacity HEPA filter continuously with door closed.',
        'icon': Icons.meeting_room_outlined,
      },
      {
        'title': 'Hydration & Saline Nasal Rinse Support',
        'description': 'Keep family well hydrated to preserve airway mucous membranes. Sterile saline sprays help soothe particulate nasal irritation.',
        'icon': Icons.water_drop_outlined,
      },
    ];

    return Column(
      children: items.map((item) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(item['icon'] as IconData, color: const Color(0xFF0D9488), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 4),
                      Text(item['description'] as String, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
