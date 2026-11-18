import '../../domain/models/community_challenge.dart';
import '../../domain/repositories/community_repository.dart';
import '../datasources/local_storage_service.dart';

class CommunityRepositoryImpl implements CommunityRepository {
  final LocalStorageService _storage;
  static const String _enrolledChallengesKey = 'enrolled_challenge_ids';

  CommunityRepositoryImpl({required LocalStorageService storage}) : _storage = storage;

  @override
  Future<List<CommunityChallenge>> getChallenges() async {
    final enrolled = _storage.getStringList(_enrolledChallengesKey) ?? ['challenge_no_idling'];

    return [
      CommunityChallenge(
        id: 'challenge_no_idling',
        title: 'Zero Vehicle Idling Challenge',
        description: 'Pledge to turn off your vehicle engine during all school drop-offs, railway crossings, and waiting queues > 20 seconds.',
        durationText: '14-Day Challenge',
        participantsCount: 1420,
        currentCo2SavedKg: 3840.0,
        goalCo2SavedKg: 5000.0,
        isEnrolled: enrolled.contains('challenge_no_idling'),
        daysRemaining: 5,
        badgeName: 'Idle-Free Pioneer',
        practicalTip: 'Modern electronic fuel injectors require less than 10 seconds worth of fuel to restart.',
      ),
      CommunityChallenge(
        id: 'challenge_public_transport_week',
        title: 'Public Transport & Transit Week',
        description: 'Replace at least 3 solo private car trips with electric metro, light rail, or commuter bus transit.',
        durationText: '7-Day Sprint',
        participantsCount: 890,
        currentCo2SavedKg: 2150.0,
        goalCo2SavedKg: 3500.0,
        isEnrolled: enrolled.contains('challenge_public_transport_week'),
        daysRemaining: 3,
        badgeName: 'Transit Champion',
        practicalTip: 'Wear an N95 respirator when walking through outdoor transfer plazas during smog alerts.',
      ),
      CommunityChallenge(
        id: 'challenge_clean_indoor_air',
        title: 'Clean Indoor Air Week',
        description: 'Maintain zero indoor smoking/incense, seal window drafts with weatherstripping, and verify HEPA filter cleanliness.',
        durationText: '7-Day Clean Air Drive',
        participantsCount: 2180,
        currentCo2SavedKg: 1450.0,
        goalCo2SavedKg: 2000.0,
        isEnrolled: enrolled.contains('challenge_clean_indoor_air'),
        daysRemaining: 6,
        badgeName: 'Sanctuary Guardian',
        practicalTip: 'Indoor particulate levels often exceed outdoor levels if cooking oil or incense is burned without exhaust.',
      ),
      CommunityChallenge(
        id: 'challenge_sustainable_commute',
        title: 'Sustainable Commute Sprint',
        description: 'Commit to carpooling with a colleague or cycling/walking (only when outdoor AQI is certified Good or Moderate).',
        durationText: '30-Day Campaign',
        participantsCount: 640,
        currentCo2SavedKg: 4900.0,
        goalCo2SavedKg: 10000.0,
        isEnrolled: enrolled.contains('challenge_sustainable_commute'),
        daysRemaining: 18,
        badgeName: 'Clean Miles Leader',
        practicalTip: 'Never cycle or run outside when AQI exceeds 150; switch to transit or carpool.',
      ),
      CommunityChallenge(
        id: 'challenge_community_awareness',
        title: 'Clean Air Awareness Campaign',
        description: 'Share local real-time AQI readings and verified protection tips with neighbors, schools, and family groups.',
        durationText: 'Ongoing Community Initiative',
        participantsCount: 3120,
        currentCo2SavedKg: 6200.0,
        goalCo2SavedKg: 8000.0,
        isEnrolled: enrolled.contains('challenge_community_awareness'),
        daysRemaining: 12,
        badgeName: 'Community Advocate',
        practicalTip: 'Educating one apartment building to stop burning garden debris prevents dense neighborhood smoke.',
      ),
    ];
  }

  @override
  Future<void> toggleChallengeEnrollment(String challengeId, bool isEnrolled) async {
    final list = _storage.getStringList(_enrolledChallengesKey) ?? [];
    final set = Set<String>.from(list);
    if (isEnrolled) {
      set.add(challengeId);
    } else {
      set.remove(challengeId);
    }
    await _storage.setStringList(_enrolledChallengesKey, set.toList());
  }

  @override
  Future<Map<String, dynamic>> getCommunityAggregateStats() async {
    // Transparently simulated community totals with documented mathematical baselines
    return {
      'totalActionsCompleted': 14890,
      'vehicleTripsAvoided': 6420,
      'fuelSavedLiters': 18540.0,
      'emissionsAvoidedKg': 42800.0,
      'pm25PreventedGrams': 3450.0,
      'activeParticipants': 4250,
      'isSimulatedData': true,
      'simulationAssumption': 'Aggregated demo community model assuming 4,250 registered households adopting 3.5 sustainable clean-air practices weekly over a 60-day winter smog period.',
    };
  }
}
