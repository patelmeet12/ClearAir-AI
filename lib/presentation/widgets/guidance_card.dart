import 'package:flutter/material.dart';

class GuidanceCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;
  final Color iconColor;

  const GuidanceCard({
    super.key,
    required this.title,
    required this.content,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    content,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.35),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
