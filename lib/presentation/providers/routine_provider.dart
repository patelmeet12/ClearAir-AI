import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/impact_calculator.dart';
import '../../domain/models/daily_routine.dart';
import 'air_quality_provider.dart';
import 'app_providers.dart';
import 'household_provider.dart';

class RoutineState {
  final List<RoutineItem> routines;
  final bool isLoading;
  final String? error;

  const RoutineState({
    this.routines = const [],
    this.isLoading = false,
    this.error,
  });

  RoutineState copyWith({
    List<RoutineItem>? routines,
    bool? isLoading,
    String? error,
  }) {
    return RoutineState(
      routines: routines ?? this.routines,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get completedCount => routines.where((r) => r.isCompleted).length;
  double get completionRate => routines.isEmpty ? 0.0 : completedCount / routines.length;

  ImpactCalculationResult get completedImpact {
    double co2 = 0.0;
    double fuel = 0.0;
    double cost = 0.0;
    for (final r in routines.where((r) => r.isCompleted)) {
      co2 += r.co2AvoidedKg;
      fuel += r.fuelSavedLiters;
      cost += r.costSavedUsd;
    }
    return ImpactCalculationResult(
      co2AvoidedKg: co2,
      fuelSavedLiters: fuel,
      costSavedUsd: cost,
      pm25PreventedGrams: co2 * 0.012,
      assumptionNotes: 'Impact derived from $completedCount completed daily actions.',
    );
  }
}

class RoutineNotifier extends StateNotifier<RoutineState> {
  final Ref _ref;

  RoutineNotifier(this._ref) : super(const RoutineState(isLoading: true)) {
    loadRoutines();
  }

  Future<void> loadRoutines() async {
    state = state.copyWith(isLoading: true);
    final repo = _ref.read(routineRepositoryProvider);
    final existing = await repo.getRoutines();
    if (existing.isNotEmpty) {
      state = state.copyWith(routines: existing, isLoading: false);
    } else {
      await generateRoutines();
    }
  }

  Future<void> generateRoutines() async {
    state = state.copyWith(isLoading: true);
    try {
      final aqiData = _ref.read(airQualityProvider).data;
      final profile = _ref.read(householdProvider);
      if (aqiData == null) {
        state = state.copyWith(isLoading: false);
        return;
      }
      final repo = _ref.read(routineRepositoryProvider);
      final generated = await repo.generateDailyRoutines(
        airQuality: aqiData,
        profile: profile,
      );
      state = state.copyWith(routines: generated, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> toggleCompletion(String id, bool isCompleted) async {
    final repo = _ref.read(routineRepositoryProvider);
    await repo.toggleRoutineCompletion(id, isCompleted);
    final updated = state.routines.map((r) => r.id == id ? r.copyWith(isCompleted: isCompleted) : r).toList();
    state = state.copyWith(routines: updated);
  }

  Future<void> resetRoutines() async {
    final repo = _ref.read(routineRepositoryProvider);
    await repo.resetRoutines();
    await generateRoutines();
  }
}

final routineProvider = StateNotifierProvider<RoutineNotifier, RoutineState>((ref) {
  return RoutineNotifier(ref);
});
