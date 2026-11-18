import '../models/community_challenge.dart';

abstract class CommunityRepository {
  Future<List<CommunityChallenge>> getChallenges();
  Future<void> toggleChallengeEnrollment(String challengeId, bool isEnrolled);
  Future<Map<String, dynamic>> getCommunityAggregateStats();
}
