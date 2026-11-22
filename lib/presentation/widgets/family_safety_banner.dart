import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/household_profile.dart';

class FamilySafetyBanner extends StatelessWidget {
  final HouseholdProfile householdProfile;

  const FamilySafetyBanner({
    super.key,
    required this.householdProfile,
  });

  @override
  Widget build(BuildContext context) {
    final childrenText = householdProfile.children == 1 ? '1 child' : '${householdProfile.children} children';
    final adultsText = householdProfile.olderAdults == 1 ? '1 older adult' : '${householdProfile.olderAdults} older adults';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0D9488).withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF0D9488).withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.family_restroom, color: Color(0xFF0D9488), size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Household Vulnerability Advisory Active',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  'Profile includes $childrenText and $adultsText. '
                  '${householdProfile.vulnerability.advisory}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.go('/family'),
            child: const Text('Edit Household'),
          ),
        ],
      ),
    );
  }
}
