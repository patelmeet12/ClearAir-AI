import 'package:flutter/material.dart';
import '../../core/utils/impact_calculator.dart';

class ImpactSummaryCard extends StatelessWidget {
  final ImpactCalculationResult impact;
  final int count;

  const ImpactSummaryCard({
    super.key,
    required this.impact,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
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
