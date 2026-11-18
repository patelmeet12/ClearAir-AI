import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/indoor_guide.dart';
import 'air_quality_provider.dart';
import 'app_providers.dart';

class IndoorState {
  final List<IndoorChecklistItem> items;
  final DateTime? lastFilterDate;
  final bool isLoading;
  final String? error;

  const IndoorState({
    this.items = const [],
    this.lastFilterDate,
    this.isLoading = false,
    this.error,
  });

  IndoorState copyWith({
    List<IndoorChecklistItem>? items,
    DateTime? lastFilterDate,
    bool? isLoading,
    String? error,
  }) {
    return IndoorState(
      items: items ?? this.items,
      lastFilterDate: lastFilterDate ?? this.lastFilterDate,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  int get completedCount => items.where((i) => i.isCompleted).length;
  double get completionRate => items.isEmpty ? 0.0 : completedCount / items.length;

  int get daysSinceFilterReplacement {
    if (lastFilterDate == null) return 75; // Default ~2.5 months ago
    return DateTime.now().difference(lastFilterDate!).inDays;
  }

  bool get isFilterReplacementDue => daysSinceFilterReplacement >= 90; // Standard 3-month replacement cycle
}

class IndoorNotifier extends StateNotifier<IndoorState> {
  final Ref _ref;

  IndoorNotifier(this._ref) : super(const IndoorState(isLoading: true)) {
    loadChecklist();
  }

  Future<void> loadChecklist() async {
    state = state.copyWith(isLoading: true);
    final repo = _ref.read(indoorRepositoryProvider);
    final currentAqi = _ref.read(airQualityProvider).data;
    final items = await repo.getIndoorChecklist(currentAqi);
    final filterDate = await repo.getLastFilterReplacementDate();
    state = state.copyWith(
      items: items,
      lastFilterDate: filterDate ?? DateTime.now().subtract(const Duration(days: 42)),
      isLoading: false,
    );
  }

  Future<void> toggleItem(String id, bool isCompleted) async {
    final repo = _ref.read(indoorRepositoryProvider);
    await repo.toggleItem(id, isCompleted);
    final updated = state.items.map((i) => i.id == id ? i.copyWith(isCompleted: isCompleted) : i).toList();
    state = state.copyWith(items: updated);
  }

  Future<void> recordFilterReplacementNow() async {
    final now = DateTime.now();
    final repo = _ref.read(indoorRepositoryProvider);
    await repo.updateFilterReplacementDate(now);
    state = state.copyWith(lastFilterDate: now);
  }

  Future<void> resetChecklist() async {
    final repo = _ref.read(indoorRepositoryProvider);
    await repo.resetChecklist();
    await loadChecklist();
  }
}

final indoorProvider = StateNotifierProvider<IndoorNotifier, IndoorState>((ref) {
  return IndoorNotifier(ref);
});
