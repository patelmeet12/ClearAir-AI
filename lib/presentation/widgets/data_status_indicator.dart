import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../domain/models/air_quality.dart';

class DataStatusIndicator extends StatelessWidget {
  final DataSourceType dataSourceType;
  final String sourceName;
  final DateTime lastUpdated;
  final bool hasLocationPermission;
  final VoidCallback? onRefresh;

  const DataStatusIndicator({
    super.key,
    required this.dataSourceType,
    required this.sourceName,
    required this.lastUpdated,
    required this.hasLocationPermission,
    this.onRefresh,
  });

  Color _badgeColor() {
    switch (dataSourceType) {
      case DataSourceType.live:
        return AppColors.statusLive;
      case DataSourceType.cached:
        return AppColors.statusCached;
      case DataSourceType.estimated:
        return AppColors.statusEstimated;
      case DataSourceType.demo:
        return AppColors.statusDemo;
    }
  }

  IconData _badgeIcon() {
    switch (dataSourceType) {
      case DataSourceType.live:
        return Icons.sensors;
      case DataSourceType.cached:
        return Icons.history;
      case DataSourceType.estimated:
        return Icons.auto_graph;
      case DataSourceType.demo:
        return Icons.science_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('MMM d, h:mm a').format(lastUpdated.toLocal());
    final badgeColor = _badgeColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(_badgeIcon(), size: 16, color: badgeColor),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: badgeColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              dataSourceType.label.toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 10,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$sourceName • Updated $timeStr',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.75),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (onRefresh != null)
            IconButton(
              icon: const Icon(Icons.refresh, size: 16),
              tooltip: 'Refresh live measurements',
              onPressed: onRefresh,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
        ],
      ),
    );
  }
}
