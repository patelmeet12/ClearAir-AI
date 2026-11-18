import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/community_provider.dart';

class CommunityImpactScreen extends ConsumerWidget {
  const CommunityImpactScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commState = ref.watch(communityProvider);
    final stats = commState.aggregateStats;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'COMMUNITY EMISSION REDUCTION',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D9488),
                  ),
            ),
            Text(
              'Collective Clean Air Action & Challenges',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Air quality is an urban common. When neighborhoods coordinate anti-idling, school-zone protection, and transit shifts, cumulative street-level pollution drops measurably.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 16),

            // Transparency Disclaimer Banner
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withValues(alpha: 0.25)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: Colors.blue, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Community Metrics Transparency: ${stats["simulationAssumption"] ?? "Aggregated community participation model using EPA-standard conversion factors."}',
                      style: const TextStyle(fontSize: 11, color: Colors.blue, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Aggregate Community Statistics Grid
            LayoutBuilder(
              builder: (context, constraints) {
                final int cols = constraints.maxWidth > 900
                    ? 5
                    : constraints.maxWidth > 600
                        ? 3
                        : 2;
                return GridView.count(
                  crossAxisCount: cols,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.4,
                  children: [
                    _communityStatCard(
                      context,
                      title: 'Total Actions',
                      value: '${stats["totalActionsCompleted"] ?? 14890}',
                      icon: Icons.checklist_rtl,
                      color: const Color(0xFF0D9488),
                    ),
                    _communityStatCard(
                      context,
                      title: 'Trips Avoided',
                      value: '${stats["vehicleTripsAvoided"] ?? 6420}',
                      icon: Icons.directions_car_outlined,
                      color: const Color(0xFF10B981),
                    ),
                    _communityStatCard(
                      context,
                      title: 'Fuel Saved',
                      value: '${(stats["fuelSavedLiters"] as num?)?.toInt() ?? 18540} L',
                      icon: Icons.local_gas_station_outlined,
                      color: Colors.amber.shade700,
                    ),
                    _communityStatCard(
                      context,
                      title: 'CO2e Avoided',
                      value: '${((stats["emissionsAvoidedKg"] as num?)?.toDouble() ?? 42800) / 1000} T',
                      icon: Icons.cloud_outlined,
                      color: Colors.indigo,
                    ),
                    _communityStatCard(
                      context,
                      title: 'Active Members',
                      value: '${stats["activeParticipants"] ?? 4250}',
                      icon: Icons.groups_outlined,
                      color: Colors.purple,
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 28),

            // Clean Air Challenges Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ACTIVE CLEAN AIR COMMUNITY CHALLENGES',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF0D9488),
                      ),
                ),
                Text(
                  'Enrolled in ${commState.enrolledCount} Challenges',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                ),
              ],
            ),
            const SizedBox(height: 12),

            ...commState.challenges.map((challenge) {
              return Card(
                margin: const EdgeInsets.only(bottom: 14),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0D9488).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.emoji_events_outlined, color: Color(0xFF0D9488), size: 20),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(challenge.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                  Text(
                                    '${challenge.durationText} • ${challenge.daysRemaining} days remaining',
                                    style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: challenge.isEnrolled ? Colors.green.shade700 : const Color(0xFF0D9488),
                            ),
                            onPressed: () {
                              ref.read(communityProvider.notifier).toggleEnrollment(challenge.id, !challenge.isEnrolled);
                            },
                            child: Text(challenge.isEnrolled ? 'Pledged' : 'Join Challenge'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(challenge.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35)),
                      const SizedBox(height: 14),

                      // Progress Bar
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${challenge.currentCo2SavedKg.toInt()} kg / ${challenge.goalCo2SavedKg.toInt()} kg CO2e Avoided',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                '${(challenge.progressFraction * 100).toInt()}% Goal',
                                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF0D9488)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: challenge.progressFraction,
                              minHeight: 8,
                              backgroundColor: Colors.grey.withValues(alpha: 0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0D9488)),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.people_outline, size: 14, color: Colors.grey),
                              const SizedBox(width: 4),
                              Text('${challenge.participantsCount} community participants', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                            ],
                          ),
                          Text('Badge: ${challenge.badgeName}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
                        ],
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

  Widget _communityStatCard(BuildContext context, {required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerTheme.color ?? Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
              Icon(icon, size: 18, color: color),
            ],
          ),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
