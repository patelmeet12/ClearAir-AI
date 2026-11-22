import 'package:clearair_ai/data/datasources/local_storage_service.dart';
import 'package:clearair_ai/main.dart';
import 'package:clearair_ai/presentation/providers/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('ClearAirApp root bootstrap smoke test on desktop', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1280, 800);
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

    // Verify brand header presence on desktop
    expect(find.text('ClearAir AI'), findsWidgets);
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
