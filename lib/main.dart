import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'data/datasources/local_storage_service.dart';
import 'presentation/providers/app_providers.dart';
import 'presentation/providers/settings_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await LocalStorageService.init();

  runApp(
    ProviderScope(
      overrides: [
        localStorageServiceProvider.overrideWithValue(storageService),
      ],
      child: const ClearAirApp(),
    ),
  );
}

class ClearAirApp extends ConsumerWidget {
  const ClearAirApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'ClearAir AI — Intelligent Air Quality & Pollution Protection',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      routerConfig: appRouter,
      builder: (context, child) {
        final mq = MediaQuery.of(context);
        return MediaQuery(
          data: mq.copyWith(
            disableAnimations: settings.reducedMotion,
            accessibleNavigation: settings.reducedMotion,
          ),
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
