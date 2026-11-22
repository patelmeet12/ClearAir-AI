import 'package:clearair_ai/core/constants/aqi_standards.dart';
import 'package:clearair_ai/data/datasources/local_storage_service.dart';
import 'package:clearair_ai/presentation/providers/app_providers.dart';
import 'package:clearair_ai/presentation/providers/settings_provider.dart';
import 'package:clearair_ai/presentation/screens/settings_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Settings & AQI Standards Widget Integration Tests', () {
    testWidgets('Settings screen renders standard selection and responds to user interaction', (tester) async {
      tester.view.physicalSize = const Size(1280, 1000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      SharedPreferences.setMockInitialValues({});
      final storage = LocalStorageService(await SharedPreferences.getInstance());

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            localStorageServiceProvider.overrideWithValue(storage),
          ],
          child: const MaterialApp(
            home: SettingsScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Air Quality Scale Standard'), findsOneWidget);
      expect(find.text('US EPA AQI'), findsOneWidget);
      expect(find.text('India NAQI'), findsOneWidget);

      // Verify Reduced Motion toggle is present
      expect(find.text('Reduced Motion'), findsOneWidget);

      // Scroll and tap India NAQI
      await tester.ensureVisible(find.text('India NAQI'));
      await tester.tap(find.text('India NAQI'));
      await tester.pumpAndSettle();

      // Verify setting updated in container
      final element = tester.element(find.byType(SettingsScreen));
      final container = ProviderScope.containerOf(element);
      expect(container.read(settingsProvider).aqiStandard, equals(AqiStandard.indiaNaqi));
    });
  });
}
