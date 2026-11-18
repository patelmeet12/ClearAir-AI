import '../../domain/models/household_profile.dart';
import '../../domain/repositories/household_repository.dart';
import '../datasources/local_storage_service.dart';

class HouseholdRepositoryImpl implements HouseholdRepository {
  final LocalStorageService _storage;
  static const String _householdKey = 'user_household_profile';

  HouseholdRepositoryImpl({required LocalStorageService storage}) : _storage = storage;

  @override
  Future<HouseholdProfile> getProfile() async {
    final json = _storage.getJson(_householdKey);
    if (json == null) {
      const defaultProfile = HouseholdProfile();
      await _storage.setJson(_householdKey, defaultProfile.toJson());
      return defaultProfile;
    }
    return HouseholdProfile.fromJson(json);
  }

  @override
  Future<void> saveProfile(HouseholdProfile profile) async {
    await _storage.setJson(_householdKey, profile.toJson());
  }

  @override
  Future<void> resetProfile() async {
    const defaultProfile = HouseholdProfile();
    await _storage.setJson(_householdKey, defaultProfile.toJson());
  }
}
