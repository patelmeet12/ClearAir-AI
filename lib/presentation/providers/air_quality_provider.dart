import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/air_quality.dart';
import '../../domain/models/location.dart';
import 'app_providers.dart';
import 'location_provider.dart';
import 'settings_provider.dart';

class AirQualityState {
  final AirQualityData? data;
  final bool isLoading;
  final String? error;
  final List<AirQualityData> comparisonList;
  final bool isComparing;

  const AirQualityState({
    this.data,
    this.isLoading = false,
    this.error,
    this.comparisonList = const [],
    this.isComparing = false,
  });

  AirQualityState copyWith({
    AirQualityData? data,
    bool? isLoading,
    String? error,
    List<AirQualityData>? comparisonList,
    bool? isComparing,
  }) {
    return AirQualityState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      comparisonList: comparisonList ?? this.comparisonList,
      isComparing: isComparing ?? this.isComparing,
    );
  }
}

class AirQualityNotifier extends StateNotifier<AirQualityState> {
  final Ref _ref;

  AirQualityNotifier(this._ref) : super(const AirQualityState(isLoading: true)) {
    // Listen to location changes
    _ref.listen<LocationState>(locationProvider, (previous, next) {
      if (next.selectedLocation != null &&
          (previous?.selectedLocation?.id != next.selectedLocation?.id ||
              state.data == null)) {
        fetchForLocation(next.selectedLocation!);
      }
    });

    final currentLoc = _ref.read(locationProvider).selectedLocation;
    if (currentLoc != null) {
      fetchForLocation(currentLoc);
    }
  }

  Future<void> fetchForLocation(LocationItem location, {bool forceRefresh = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = _ref.read(airQualityRepositoryProvider);
      final isDemoMode = _ref.read(settingsProvider).isDemoMode;
      final data = await repo.getAirQuality(location, forceRefresh: forceRefresh, demoMode: isDemoMode);
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    final currentLoc = _ref.read(locationProvider).selectedLocation;
    if (currentLoc != null) {
      await fetchForLocation(currentLoc, forceRefresh: true);
    }
  }

  Future<void> loadComparison(List<LocationItem> locations) async {
    state = state.copyWith(isComparing: true);
    try {
      final repo = _ref.read(airQualityRepositoryProvider);
      final isDemoMode = _ref.read(settingsProvider).isDemoMode;
      final list = await repo.compareLocations(locations, demoMode: isDemoMode);
      state = state.copyWith(comparisonList: list, isComparing: false);
    } catch (e) {
      state = state.copyWith(isComparing: false);
    }
  }
}

final airQualityProvider = StateNotifierProvider<AirQualityNotifier, AirQualityState>((ref) {
  return AirQualityNotifier(ref);
});
