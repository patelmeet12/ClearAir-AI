import 'package:flutter/material.dart';
import '../../core/constants/aqi_standards.dart';

class AqiBadge extends StatelessWidget {
  final AqiCategory category;
  final bool isLarge;

  const AqiBadge({
    super.key,
    required this.category,
    this.isLarge = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Air Quality Category: ${category.title}',
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: isLarge ? 14 : 10,
          vertical: isLarge ? 6 : 4,
        ),
        decoration: BoxDecoration(
          color: category.color.withValues(alpha: 0.18),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: category.color, width: 1.5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isLarge ? 10 : 8,
              height: isLarge ? 10 : 8,
              decoration: BoxDecoration(
                color: category.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              category.title,
              style: TextStyle(
                color: category.color,
                fontWeight: FontWeight.bold,
                fontSize: isLarge ? 14 : 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
