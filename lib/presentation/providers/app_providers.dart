import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/gemini_ai_client.dart';
import '../../data/datasources/local_storage_service.dart';
import '../../data/datasources/open_meteo_aqi_api.dart';
import '../../data/repositories_impl/air_quality_repository_impl.dart';
import '../../data/repositories_impl/ai_assistant_repository_impl.dart';
import '../../data/repositories_impl/community_repository_impl.dart';
import '../../data/repositories_impl/household_repository_impl.dart';
import '../../data/repositories_impl/indoor_repository_impl.dart';
import '../../data/repositories_impl/location_repository_impl.dart';
import '../../data/repositories_impl/routine_repository_impl.dart';
import '../../data/repositories_impl/settings_repository_impl.dart';
import '../../data/repositories_impl/sustainable_repository_impl.dart';
import '../../domain/repositories/air_quality_repository.dart';
import '../../domain/repositories/ai_assistant_repository.dart';
import '../../domain/repositories/community_repository.dart';
import '../../domain/repositories/household_repository.dart';
import '../../domain/repositories/indoor_repository.dart';
import '../../domain/repositories/location_repository.dart';
import '../../domain/repositories/routine_repository.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../domain/repositories/sustainable_repository.dart';

// Storage service provider (overridden in main after init)
final localStorageServiceProvider = Provider<LocalStorageService>((ref) {
  throw UnimplementedError('localStorageServiceProvider must be initialized');
});

// APIs
final openMeteoAqiApiProvider = Provider<OpenMeteoAqiApi>((ref) => OpenMeteoAqiApi());
final geminiAiClientProvider = Provider<GeminiAiClient>((ref) => GeminiAiClient());

// Repositories
final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl(storage: ref.watch(localStorageServiceProvider));
});

final locationRepositoryProvider = Provider<LocationRepository>((ref) {
  return LocationRepositoryImpl(storage: ref.watch(localStorageServiceProvider));
});

final airQualityRepositoryProvider = Provider<AirQualityRepository>((ref) {
  return AirQualityRepositoryImpl(
    api: ref.watch(openMeteoAqiApiProvider),
    storage: ref.watch(localStorageServiceProvider),
  );
});

final householdRepositoryProvider = Provider<HouseholdRepository>((ref) {
  return HouseholdRepositoryImpl(storage: ref.watch(localStorageServiceProvider));
});

final routineRepositoryProvider = Provider<RoutineRepository>((ref) {
  return RoutineRepositoryImpl(storage: ref.watch(localStorageServiceProvider));
});

final indoorRepositoryProvider = Provider<IndoorRepository>((ref) {
  return IndoorRepositoryImpl(storage: ref.watch(localStorageServiceProvider));
});

final sustainableRepositoryProvider = Provider<SustainableRepository>((ref) {
  return SustainableRepositoryImpl(storage: ref.watch(localStorageServiceProvider));
});

final communityRepositoryProvider = Provider<CommunityRepository>((ref) {
  return CommunityRepositoryImpl(storage: ref.watch(localStorageServiceProvider));
});

final aiAssistantRepositoryProvider = Provider<AiAssistantRepository>((ref) {
  return AiAssistantRepositoryImpl(
    client: ref.watch(geminiAiClientProvider),
    storage: ref.watch(localStorageServiceProvider),
  );
});
