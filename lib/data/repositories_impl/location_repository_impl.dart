import '../../domain/models/location.dart';
import '../../domain/repositories/location_repository.dart';
import '../datasources/demo_data_provider.dart';
import '../datasources/local_storage_service.dart';

class LocationRepositoryImpl implements LocationRepository {
  final LocalStorageService _storage;
  static const String _locationsKey = 'saved_locations_list';
  static const String _defaultIdKey = 'default_location_id';

  LocationRepositoryImpl({required LocalStorageService storage}) : _storage = storage;

  @override
  Future<List<LocationItem>> getSavedLocations() async {
    final list = _storage.getJsonList(_locationsKey);
    if (list == null || list.isEmpty) {
      // Initialize with demo defaults
      final defaults = DemoDataProvider.defaultDemoLocations;
      await _storage.setJsonList(_locationsKey, defaults.map((e) => e.toJson()).toList());
      return defaults;
    }
    return list.map((e) => LocationItem.fromJson(e)).toList();
  }

  @override
  Future<void> saveLocation(LocationItem location) async {
    final locations = await getSavedLocations();
    final updated = List<LocationItem>.from(locations);
    final idx = updated.indexWhere((l) => l.id == location.id);
    if (idx >= 0) {
      updated[idx] = location;
    } else {
      updated.add(location);
    }
    await _storage.setJsonList(_locationsKey, updated.map((e) => e.toJson()).toList());
  }

  @override
  Future<void> removeLocation(String id) async {
    final locations = await getSavedLocations();
    final updated = locations.where((l) => l.id != id).toList();
    await _storage.setJsonList(_locationsKey, updated.map((e) => e.toJson()).toList());
  }

  @override
  Future<LocationItem?> getDefaultLocation() async {
    final locations = await getSavedLocations();
    if (locations.isEmpty) return null;
    final defaultId = _storage.getString(_defaultIdKey);
    if (defaultId != null) {
      final match = locations.where((l) => l.id == defaultId);
      if (match.isNotEmpty) return match.first;
    }
    return locations.firstWhere((l) => l.isDefault, orElse: () => locations.first);
  }

  @override
  Future<void> setDefaultLocation(String id) async {
    await _storage.setString(_defaultIdKey, id);
    final locations = await getSavedLocations();
    final updated = locations.map((l) => l.copyWith(isDefault: l.id == id)).toList();
    await _storage.setJsonList(_locationsKey, updated.map((e) => e.toJson()).toList());
  }
}
