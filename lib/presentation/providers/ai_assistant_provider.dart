import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/ai_assistant_message.dart';
import '../../domain/models/ai_impact_explanation.dart';
import 'air_quality_provider.dart';
import 'app_providers.dart';
import 'household_provider.dart';
import 'settings_provider.dart';

class AiAssistantState {
  final List<AiAssistantMessage> messages;
  final bool isThinking;
  final String? error;

  const AiAssistantState({
    this.messages = const [],
    this.isThinking = false,
    this.error,
  });

  AiAssistantState copyWith({
    List<AiAssistantMessage>? messages,
    bool? isThinking,
    String? error,
  }) {
    return AiAssistantState(
      messages: messages ?? this.messages,
      isThinking: isThinking ?? this.isThinking,
      error: error,
    );
  }
}

class AiAssistantNotifier extends StateNotifier<AiAssistantState> {
  final Ref _ref;

  AiAssistantNotifier(this._ref) : super(const AiAssistantState()) {
    loadHistory();
  }

  Future<void> loadHistory() async {
    final repo = _ref.read(aiAssistantRepositoryProvider);
    final history = await repo.getConversationHistory();
    state = state.copyWith(messages: history);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    state = state.copyWith(isThinking: true, error: null);

    try {
      final repo = _ref.read(aiAssistantRepositoryProvider);
      final aqiData = _ref.read(airQualityProvider).data;
      final profile = _ref.read(householdProvider);
      final settings = _ref.read(settingsProvider);

      await repo.askAssistant(
        prompt: text.trim(),
        airQuality: aqiData,
        profile: profile,
        useRealGenAi: settings.useRealGenAi,
        genAiApiKey: settings.genAiApiKey,
        genAiEndpoint: settings.genAiEndpoint,
      );

      final updatedHistory = await repo.getConversationHistory();
      state = state.copyWith(messages: updatedHistory, isThinking: false);
    } catch (e) {
      state = state.copyWith(isThinking: false, error: e.toString());
    }
  }

  Future<AiImpactExplanation> getImpactExplanation({
    required String actionTitle,
    required double co2AvoidedKg,
    required double fuelSavedLiters,
    required double pm25PreventedGrams,
  }) async {
    final repo = _ref.read(aiAssistantRepositoryProvider);
    final settings = _ref.read(settingsProvider);
    return repo.explainImpact(
      actionTitle: actionTitle,
      co2AvoidedKg: co2AvoidedKg,
      fuelSavedLiters: fuelSavedLiters,
      pm25PreventedGrams: pm25PreventedGrams,
      userContext: 'Daily routine completion in ClearAir AI',
      useRealGenAi: settings.useRealGenAi,
      genAiApiKey: settings.genAiApiKey,
      genAiEndpoint: settings.genAiEndpoint,
    );
  }

  Future<void> clearHistory() async {
    final repo = _ref.read(aiAssistantRepositoryProvider);
    await repo.clearHistory();
    await loadHistory();
  }
}

final aiAssistantProvider = StateNotifierProvider<AiAssistantNotifier, AiAssistantState>((ref) {
  return AiAssistantNotifier(ref);
});
