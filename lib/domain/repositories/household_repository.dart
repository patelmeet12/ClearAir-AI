import '../models/household_profile.dart';

abstract class HouseholdRepository {
  Future<HouseholdProfile> getProfile();
  Future<void> saveProfile(HouseholdProfile profile);
  Future<void> resetProfile();
}
