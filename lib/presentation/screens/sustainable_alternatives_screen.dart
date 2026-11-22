import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/ai_assistant_provider.dart';
import '../providers/sustainable_provider.dart';
import '../widgets/why_this_matters_dialog.dart';

class SustainableAlternativesScreen extends ConsumerWidget {
  const SustainableAlternativesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sustState = ref.watch(sustainableProvider);
    final impact = sustState.personalImpact;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'SUSTAINABLE ALTERNATIVES & CARBON IMPACT',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0D9488),
                  ),
            ),
            Text(
              'Everyday Activity Replacements',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Adopt low-emission alternatives to daily activities without compromising personal air-pollution exposure. All calculations use documented scientific factors.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
            ),
            const SizedBox(height: 20),

            // Cumulative Monthly Savings Hero Card
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0D9488), Color(0xFF059669)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF0D9488).withValues(alpha: 0.25), blurRadius: 12, offset: const Offset(0, 4)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'YOUR ESTIMATED MONTHLY BENEFIT',
                        style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(12)),
                        child: Text(
                          '${sustState.adoptedCount} Alternatives Adopted',
                          style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _heroMetric('${impact.co2AvoidedKg.toStringAsFixed(1)} kg', 'CO2e / Month', Icons.cloud_outlined),
                      _heroMetric('${impact.fuelSavedLiters.toStringAsFixed(1)} L', 'Fuel Saved', Icons.local_gas_station_outlined),
                      _heroMetric('\$${impact.costSavedUsd.toStringAsFixed(0)}', 'Est. Money Saved', Icons.savings_outlined),
                    ],
                  ),
                  const SizedBox(height: 14),
                  const Divider(color: Colors.white24),
                  const SizedBox(height: 4),
                  const Text(
                    'Important distinction: Reduced greenhouse-gas emissions (CO2) mitigate long-term planetary warming, while reducing vehicle idling and cold starts immediately lowers street-level toxic PM2.5 and NO2 exposure for your family.',
                    style: TextStyle(color: Colors.white, fontSize: 11, height: 1.35),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Sustainable Alternatives Cards
            ...sustState.alternatives.map((alt) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  alt.everydayActivity.toUpperCase(),
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0D9488),
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(alt.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                              ],
                            ),
                          ),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: alt.isAdopted ? Colors.green.shade700 : const Color(0xFF0D9488),
                            ),
                            onPressed: () {
                              ref.read(sustainableProvider.notifier).toggleAdopted(alt.id, !alt.isAdopted);
                            },
                            icon: Icon(alt.isAdopted ? Icons.check : Icons.add, size: 16),
                            label: Text(alt.isAdopted ? 'Adopted' : 'Adopt Routine'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Before vs After comparison
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Theme.of(context).scaffoldBackgroundColor,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('CURRENT BEHAVIOR', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                                  const SizedBox(height: 4),
                                  Text(alt.currentBehavior, style: const TextStyle(fontSize: 12, height: 1.3)),
                                ],
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 12),
                              child: Icon(Icons.arrow_forward, color: Color(0xFF0D9488), size: 20),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('RECOMMENDED ALTERNATIVE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF0D9488))),
                                  const SizedBox(height: 4),
                                  Text(alt.recommendedAlternative, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.3)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Metrics strip
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _statItem(context, 'Emissions Impact', '-${alt.emissionImpactKgPerAction} kg CO2/action'),
                          _statItem(context, 'Monthly Benefit', '+${alt.monthlyCo2BenefitKg} kg CO2e'),
                          _statItem(context, 'Difficulty', alt.difficulty.label),
                          _statItem(context, 'Cost Impact', alt.costImplications),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 8),

                      // Why It Matters Explainer
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.psychology_outlined, size: 16, color: Color(0xFF0D9488)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Why It Matters: ${alt.whyItMatters}', style: const TextStyle(fontSize: 12, height: 1.35)),
                                const SizedBox(height: 4),
                                Text('Transparent Assumptions: ${alt.scientificAssumptions}',
                                    style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
                              ],
                            ),
                          ),
                          TextButton(
                            onPressed: () async {
                              final explainer = await ref.read(aiAssistantProvider.notifier).getImpactExplanation(
                                    actionTitle: alt.title,
                                    co2AvoidedKg: alt.emissionImpactKgPerAction,
                                    fuelSavedLiters: alt.emissionImpactKgPerAction / 2.31,
                                    pm25PreventedGrams: (alt.emissionImpactKgPerAction * 0.012),
                                  );
                              if (context.mounted) {
                                WhyThisMattersDialog.show(context, explainer);
                              }
                            },
                            child: const Text('Detailed Why', style: TextStyle(fontSize: 12)),
                          ),
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

  Widget _heroMetric(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 11, color: Colors.white70)),
      ],
    );
  }

  Widget _statItem(BuildContext context, String title, String val) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5))),
          const SizedBox(height: 2),
          Text(val, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}
