import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/screens/ai_assistant_screen.dart';
import '../../presentation/screens/community_impact_screen.dart';
import '../../presentation/screens/daily_routines_screen.dart';
import '../../presentation/screens/family_safety_screen.dart';
import '../../presentation/screens/home_dashboard_screen.dart';
import '../../presentation/screens/indoor_air_screen.dart';
import '../../presentation/screens/insights_reports_screen.dart';
import '../../presentation/screens/live_air_quality_screen.dart';
import '../../presentation/screens/settings_screen.dart';
import '../../presentation/screens/sustainable_alternatives_screen.dart';
import 'navigation_shell.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return NavigationShell(navigationShell: navigationShell);
      },
      branches: [
        // 1. Home Dashboard
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const HomeDashboardScreen(),
            ),
          ],
        ),
        // 2. Live Air Quality
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/live-aqi',
              builder: (context, state) => const LiveAirQualityScreen(),
            ),
          ],
        ),
        // 3. AI Assistant
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/ai-assistant',
              builder: (context, state) => const AiAssistantScreen(),
            ),
          ],
        ),
        // 4. Family Safety Planner
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/family',
              builder: (context, state) => const FamilySafetyScreen(),
            ),
          ],
        ),
        // 5. Indoor Air Quality
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/indoor',
              builder: (context, state) => const IndoorAirScreen(),
            ),
          ],
        ),
        // 6. Smart Daily Routines
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/routines',
              builder: (context, state) => const DailyRoutinesScreen(),
            ),
          ],
        ),
        // 7. Sustainable Alternatives
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/sustainable',
              builder: (context, state) => const SustainableAlternativesScreen(),
            ),
          ],
        ),
        // 8. Community Impact
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/community',
              builder: (context, state) => const CommunityImpactScreen(),
            ),
          ],
        ),
        // 9. Insights & Reports
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/insights',
              builder: (context, state) => const InsightsReportsScreen(),
            ),
          ],
        ),
        // 10. Settings
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/settings',
              builder: (context, state) => const SettingsScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
