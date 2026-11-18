import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/community_challenge.dart';
import 'app_providers.dart';

class CommunityState {
  final List<CommunityChallenge> challenges;
  final Map<String, dynamic> aggregateStats;
  final bool isLoading;
  final String? error;

  const CommunityState({
    this.challenges = const [],
    this.aggregateStats = const {},
    this.isLoading = false,
    this.error,
  });

  CommunityState copyWith({
    List<CommunityChallenge>? challenges,
    Map<String, dynamic>? aggregateStats,
    bool? isLoading,
    String? error,
  }) {
    return CommunityState(
      challenges: challenges ?? this.challenges,
      aggregateStats: aggregateStats ?? this.aggregateStats,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get enrolledCount => challenges.where((c) => c.isEnrolled).length;
}

class CommunityNotifier extends StateNotifier<CommunityState> {
  final Ref _ref;

  CommunityNotifier(this._ref) : super(const CommunityState(isLoading: true)) {
    loadCommunityData();
  }

  Future<void> loadCommunityData() async {
    state = state.copyWith(isLoading: true);
    final repo = _ref.read(communityRepositoryProvider);
    final list = await repo.getChallenges();
    final stats = await repo.getCommunityAggregateStats();
    state = state.copyWith(
      challenges: list,
      aggregateStats: stats,
      isLoading: false,
    );
  }

  Future<void> toggleEnrollment(String challengeId, bool isEnrolled) async {
    final repo = _ref.read(communityRepositoryProvider);
    await repo.toggleChallengeEnrollment(challengeId, isEnrolled);
    final updated = state.challenges.map((c) {
      if (c.id == challengeId) {
        return c.copyWith(
          isEnrolled: isEnrolled,
          participantsCount: isEnrolled ? c.participantsCount + 1 : c.participantsCount - 1,
        );
      }
      return c;
    }).toList();
    state = state.copyWith(challenges: updated);
  }
}

final communityProvider = StateNotifierProvider<CommunityNotifier, CommunityState>((ref) {
  return CommunityNotifier(ref);
});
