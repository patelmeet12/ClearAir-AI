import 'package:clearair_ai/core/constants/aqi_standards.dart';
import 'package:clearair_ai/data/datasources/local_storage_service.dart';
import 'package:clearair_ai/main.dart';
import 'package:clearair_ai/presentation/providers/app_providers.dart';
import 'package:clearair_ai/presentation/providers/settings_provider.dart';
import 'package:clearair_ai/presentation/screens/home_dashboard_screen.dart';
import 'package:clearair_ai/presentation/screens/live_air_quality_screen.dart';
import 'package:clearair_ai/presentation/screens/settings_screen.dart';
import 'package:clearair_ai/presentation/widgets/add_location_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('End-to-End Application Navigation & State Flow Tests', () {
    testWidgets('Full flow: Home -> Live AQI -> Add Dialog -> Settings -> Home with standard change',
        (WidgetTester tester) async {
      tester.view.physicalSize = const Size(1280, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      SharedPreferences.setMockInitialValues({});
      final storage = await LocalStorageService.init();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(storage),
          ],
          child: const ClearAirApp(),
        ),
      );

      await tester.pumpAndSettle();

      // 1. Verify Home Dashboard is mounted and visible
      expect(find.byType(HomeDashboardScreen), findsOneWidget);
      expect(find.text('Outdoor Activity Guidance'), findsOneWidget);
      expect(find.text('Indoor Air Strategy'), findsOneWidget);

      // 2. Navigate to Live AQI via NavigationRail
      // On desktop NavigationRail, let's find the text 'Live AQI'
      expect(find.text('Live AQI'), findsWidgets);
      await tester.tap(find.text('Live AQI').first);
      await tester.pumpAndSettle();

      // Verify Live AQI screen is mounted
      expect(find.byType(LiveAirQualityScreen), findsOneWidget);
      expect(find.text('Add Saved Location'), findsOneWidget);

      // 3. Open Add Custom Location dialog
      await tester.tap(find.text('Add Saved Location'));
      await tester.pumpAndSettle();

      expect(find.byType(AddLocationDialog), findsOneWidget);
      expect(find.text('Add Saved Location'), findsWidgets);

      // Dismiss dialog by tapping Cancel
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(find.byType(AddLocationDialog), findsNothing);

      // 4. Navigate to Settings screen via NavigationRail
      await tester.tap(find.text('Settings').first);
      await tester.pumpAndSettle();

      expect(find.byType(SettingsScreen), findsOneWidget);
      expect(find.text('Air Quality Scale Standard'), findsOneWidget);

      // 5. Switch AQI standard to India NAQI
      await tester.ensureVisible(find.text('India NAQI'));
      await tester.tap(find.text('India NAQI'));
      await tester.pumpAndSettle();

      // Check state container has updated
      final settingsElement = tester.element(find.byType(SettingsScreen));
      final container = ProviderScope.containerOf(settingsElement);
      expect(container.read(settingsProvider).aqiStandard, equals(AqiStandard.indiaNaqi));

      // 6. Navigate back to Home Dashboard
      await tester.tap(find.text('Home').first);
      await tester.pumpAndSettle();

      expect(find.byType(HomeDashboardScreen), findsOneWidget);
      // Verify India NAQI is rendered in the AqiGauge standard chip
      expect(find.text('India NAQI'), findsWidgets);
    });
  });
}
