import 'package:flutter/material.dart';

class PollutantMetricCard extends StatelessWidget {
  final String label;
  final String formula;
  final String value;
  final String unit;
  final String safetyLimit;
  final bool isSafe;

  const PollutantMetricCard({
    super.key,
    required this.label,
    required this.formula,
    required this.value,
    required this.unit,
    required this.safetyLimit,
    required this.isSafe,
  });

  @override
  Widget build(BuildContext context) {
    final statusColor = isSafe ? const Color(0xFF10B981) : const Color(0xFFEF4444);

    return Semantics(
      label: '$label ($formula): $value $unit, Limit: $safetyLimit. '
          '${isSafe ? "Within healthy guideline" : "Exceeds safe exposure limit"}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSafe
                ? Theme.of(context).dividerTheme.color ?? Colors.grey.shade300
                : statusColor.withValues(alpha: 0.5),
            width: isSafe ? 1.0 : 1.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    formula,
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: statusColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    value,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 3),
                  Text(
                    unit,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                'Limit: $safetyLimit',
                style: TextStyle(
                  fontSize: 9,
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
