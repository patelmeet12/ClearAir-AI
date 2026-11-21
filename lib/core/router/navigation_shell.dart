import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/providers/air_quality_provider.dart';
import '../../presentation/providers/location_provider.dart';
import '../../presentation/providers/settings_provider.dart';
import '../../presentation/widgets/aqi_badge.dart';

class NavigationShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;

  const NavigationShell({
    super.key,
    required this.navigationShell,
  });

  static const List<NavigationDestinationItem> _destinations = [
    NavigationDestinationItem(label: 'Home', icon: Icons.dashboard_outlined, activeIcon: Icons.dashboard, route: '/'),
    NavigationDestinationItem(label: 'Live AQI', icon: Icons.sensors_outlined, activeIcon: Icons.sensors, route: '/live-aqi'),
    NavigationDestinationItem(label: 'AI Assistant', icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome, route: '/ai-assistant'),
    NavigationDestinationItem(label: 'Family Safety', icon: Icons.family_restroom_outlined, activeIcon: Icons.family_restroom, route: '/family'),
    NavigationDestinationItem(label: 'Indoor Air', icon: Icons.home_work_outlined, activeIcon: Icons.home_work, route: '/indoor'),
    NavigationDestinationItem(label: 'Daily Routines', icon: Icons.today_outlined, activeIcon: Icons.today, route: '/routines'),
    NavigationDestinationItem(label: 'Sustainable', icon: Icons.eco_outlined, activeIcon: Icons.eco, route: '/sustainable'),
    NavigationDestinationItem(label: 'Community', icon: Icons.groups_outlined, activeIcon: Icons.groups, route: '/community'),
    NavigationDestinationItem(label: 'Insights', icon: Icons.analytics_outlined, activeIcon: Icons.analytics, route: '/insights'),
    NavigationDestinationItem(label: 'Settings', icon: Icons.settings_outlined, activeIcon: Icons.settings, route: '/settings'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width >= 1100;
    final isMobile = width < 700;

    final locationState = ref.watch(locationProvider);
    final aqiData = ref.watch(airQualityProvider).data;
    final settings = ref.watch(settingsProvider);
    final category = aqiData?.getCategory(settings.aqiStandard);
    final currentIndex = navigationShell.currentIndex;

    if (isMobile) {
      return Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0D9488),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.air, color: Colors.white, size: 18),
              ),
              const SizedBox(width: 8),
              const Text('ClearAir AI', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              const Spacer(),
              if (category != null)
                AqiBadge(category: category),
            ],
          ),
        ),
        drawer: Drawer(
          child: Column(
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF0D9488), Color(0xFF0F766E)],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.air, color: Colors.white, size: 36),
                    const SizedBox(height: 8),
                    const Text('ClearAir AI', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    Text(
                      'Breathe smarter. Live healthier.',
                      style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: _destinations.length,
                  itemBuilder: (context, index) {
                    final d = _destinations[index];
                    final isSelected = index == currentIndex;
                    return ListTile(
                      leading: Icon(isSelected ? d.activeIcon : d.icon, color: isSelected ? const Color(0xFF0D9488) : null),
                      title: Text(
                        d.label,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          color: isSelected ? const Color(0xFF0D9488) : null,
                        ),
                      ),
                      selected: isSelected,
                      onTap: () {
                        Navigator.of(context).pop();
                        navigationShell.goBranch(index);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        body: navigationShell,
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex < 5 ? currentIndex : 0,
          onDestinationSelected: (idx) {
            navigationShell.goBranch(idx);
          },
          destinations: _destinations.take(5).map((d) {
            return NavigationDestination(
              icon: Icon(d.icon),
              selectedIcon: Icon(d.activeIcon),
              label: d.label,
            );
          }).toList(),
        ),
      );
    }

    // Tablet & Desktop NavigationRail
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            extended: isDesktop,
            selectedIndex: currentIndex,
            onDestinationSelected: (idx) => navigationShell.goBranch(idx),
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: isDesktop
                  ? Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0D9488),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.air, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 10),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'ClearAir AI',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            Text(
                              'Pollution Protection',
                              style: TextStyle(fontSize: 11, color: Colors.grey),
                            ),
                          ],
                        ),
                      ],
                    )
                  : Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0D9488),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.air, color: Colors.white, size: 22),
                    ),
            ),
            trailing: isDesktop && aqiData != null && category != null
                ? Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: category.color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: category.color.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.location_on, size: 16, color: category.color),
                          const SizedBox(width: 6),
                          Text(
                            '${locationState.selectedLocation?.name ?? "Location"}: ${aqiData.aqi} AQI',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: category.color),
                          ),
                        ],
                      ),
                    ),
                  )
                : null,
            destinations: _destinations.map((d) {
              return NavigationRailDestination(
                icon: Icon(d.icon),
                selectedIcon: Icon(d.activeIcon),
                label: Text(d.label),
              );
            }).toList(),
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: navigationShell),
        ],
      ),
    );
  }
}

class NavigationDestinationItem {
  final String label;
  final IconData icon;
  final IconData activeIcon;
  final String route;

  const NavigationDestinationItem({
    required this.label,
    required this.icon,
    required this.activeIcon,
    required this.route,
  });
}
