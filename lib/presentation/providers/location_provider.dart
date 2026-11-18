import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/location.dart';
import 'app_providers.dart';

class LocationState {
  final List<LocationItem> savedLocations;
  final LocationItem? selectedLocation;
  final bool isLoading;
  final String? error;

  const LocationState({
    this.savedLocations = const [],
    this.selectedLocation,
    this.isLoading = false,
    this.error,
  });

  LocationState copyWith({
    List<LocationItem>? savedLocations,
    LocationItem? selectedLocation,
    bool? isLoading,
    String? error,
  }) {
    return LocationState(
      savedLocations: savedLocations ?? this.savedLocations,
      selectedLocation: selectedLocation ?? this.selectedLocation,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

class LocationNotifier extends StateNotifier<LocationState> {
  final Ref _ref;

  LocationNotifier(this._ref) : super(const LocationState(isLoading: true)) {
    loadLocations();
  }

  Future<void> loadLocations() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final repo = _ref.read(locationRepositoryProvider);
      final locations = await repo.getSavedLocations();
      final defaultLoc = await repo.getDefaultLocation();
      state = state.copyWith(
        savedLocations: locations,
        selectedLocation: defaultLoc ?? (locations.isNotEmpty ? locations.first : null),
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  void selectLocation(LocationItem location) {
    state = state.copyWith(selectedLocation: location);
  }

  Future<void> addOrUpdateLocation(LocationItem location) async {
    final repo = _ref.read(locationRepositoryProvider);
    await repo.saveLocation(location);
    await loadLocations();
    selectLocation(location);
  }

  Future<void> removeLocation(String id) async {
    final repo = _ref.read(locationRepositoryProvider);
    await repo.removeLocation(id);
    await loadLocations();
  }

  Future<void> setDefault(String id) async {
    final repo = _ref.read(locationRepositoryProvider);
    await repo.setDefaultLocation(id);
    await loadLocations();
  }
}

final locationProvider = StateNotifierProvider<LocationNotifier, LocationState>((ref) {
  return LocationNotifier(ref);
});
