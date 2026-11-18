import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/household_profile.dart';
import 'app_providers.dart';

class HouseholdNotifier extends StateNotifier<HouseholdProfile> {
  final Ref _ref;

  HouseholdNotifier(this._ref) : super(const HouseholdProfile()) {
    _load();
  }

  Future<void> _load() async {
    final repo = _ref.read(householdRepositoryProvider);
    state = await repo.getProfile();
  }

  Future<void> updateProfile(HouseholdProfile profile) async {
    state = profile;
    await _ref.read(householdRepositoryProvider).saveProfile(profile);
  }

  Future<void> resetProfile() async {
    await _ref.read(householdRepositoryProvider).resetProfile();
    state = const HouseholdProfile();
  }
}

final householdProvider = StateNotifierProvider<HouseholdNotifier, HouseholdProfile>((ref) {
  return HouseholdNotifier(ref);
});
