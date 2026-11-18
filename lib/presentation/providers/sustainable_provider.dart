import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/impact_calculator.dart';
import '../../domain/models/sustainable_alternative.dart';
import 'app_providers.dart';

class SustainableState {
  final List<SustainableAlternativeItem> alternatives;
  final ImpactCalculationResult personalImpact;
  final bool isLoading;
  final String? error;

  const SustainableState({
    this.alternatives = const [],
    this.personalImpact = ImpactCalculationResult.zero,
    this.isLoading = false,
    this.error,
  });

  SustainableState copyWith({
    List<SustainableAlternativeItem>? alternatives,
    ImpactCalculationResult? personalImpact,
    bool? isLoading,
    String? error,
  }) {
    return SustainableState(
      alternatives: alternatives ?? this.alternatives,
      personalImpact: personalImpact ?? this.personalImpact,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get adoptedCount => alternatives.where((a) => a.isAdopted).length;
}

class SustainableNotifier extends StateNotifier<SustainableState> {
  final Ref _ref;

  SustainableNotifier(this._ref) : super(const SustainableState(isLoading: true)) {
    loadAlternatives();
  }

  Future<void> loadAlternatives() async {
    state = state.copyWith(isLoading: true);
    final repo = _ref.read(sustainableRepositoryProvider);
    final list = await repo.getAlternatives();
    final impact = await repo.getCumulativePersonalImpact();
    state = state.copyWith(
      alternatives: list,
      personalImpact: impact,
      isLoading: false,
    );
  }

  Future<void> toggleAdopted(String id, bool isAdopted) async {
    final repo = _ref.read(sustainableRepositoryProvider);
    await repo.toggleAdopted(id, isAdopted);
    await loadAlternatives();
  }
}

final sustainableProvider = StateNotifierProvider<SustainableNotifier, SustainableState>((ref) {
  return SustainableNotifier(ref);
});
