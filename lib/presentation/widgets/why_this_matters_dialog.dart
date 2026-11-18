import 'package:flutter/material.dart';
import '../../domain/models/ai_impact_explanation.dart';

class WhyThisMattersDialog extends StatelessWidget {
  final AiImpactExplanation explanation;

  const WhyThisMattersDialog({super.key, required this.explanation});

  static Future<void> show(BuildContext context, AiImpactExplanation explanation) {
    return showDialog(
      context: context,
      builder: (context) => WhyThisMattersDialog(explanation: explanation),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.auto_awesome, color: Color(0xFF0D9488), size: 24),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'WHY THIS MATTERS',
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  letterSpacing: 1.2,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFF0D9488),
                                ),
                          ),
                          Text(
                            explanation.actionTitle,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                const Divider(),
                const SizedBox(height: 12),
                _buildSection(
                  context,
                  title: 'What Changed?',
                  content: explanation.whatChanged,
                  icon: Icons.swap_horiz,
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context,
                  title: 'How It Reduces Personal Exposure',
                  content: explanation.exposureReduction,
                  icon: Icons.shield_outlined,
                  color: const Color(0xFF0D9488),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context,
                  title: 'How It Reduces Environmental Emissions',
                  content: explanation.emissionReduction,
                  icon: Icons.eco_outlined,
                  color: const Color(0xFF10B981),
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context,
                  title: 'Who Benefits?',
                  content: explanation.whoBenefits,
                  icon: Icons.people_outline,
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context,
                  title: 'Model Assumptions Used',
                  content: explanation.assumptionsUsed,
                  icon: Icons.analytics_outlined,
                ),
                const SizedBox(height: 16),
                _buildSection(
                  context,
                  title: 'Limitations of This Estimate',
                  content: explanation.limitationsOfEstimate,
                  icon: Icons.info_outline,
                  color: Colors.amber.shade700,
                ),
                const SizedBox(height: 24),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Understood'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required String content,
    required IconData icon,
    Color? color,
  }) {
    final themeColor = color ?? Theme.of(context).colorScheme.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: themeColor),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: themeColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                content,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      height: 1.4,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
