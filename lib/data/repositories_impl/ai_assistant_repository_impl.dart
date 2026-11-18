import 'package:uuid/uuid.dart';
import '../../domain/models/ai_assistant_message.dart';
import '../../domain/models/air_quality.dart';
import '../../domain/models/household_profile.dart';
import '../../domain/models/ai_impact_explanation.dart';
import '../../domain/repositories/ai_assistant_repository.dart';
import '../datasources/gemini_ai_client.dart';
import '../datasources/local_storage_service.dart';

class AiAssistantRepositoryImpl implements AiAssistantRepository {
  final GeminiAiClient _client;
  final LocalStorageService _storage;
  static const String _historyKey = 'ai_chat_history_list';

  AiAssistantRepositoryImpl({
    required GeminiAiClient client,
    required LocalStorageService storage,
  })  : _client = client,
        _storage = storage;

  @override
  Future<List<AiAssistantMessage>> getConversationHistory() async {
    final list = _storage.getJsonList(_historyKey);
    if (list == null || list.isEmpty) {
      // Seed with initial welcoming message
      final welcome = AiAssistantMessage(
        id: 'msg_welcome',
        isUser: false,
        text: 'Hello! I am ClearAir AI, your environmental protection and smog safety assistant. How can I help protect your home and routine today?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
        structuredAdvice: const StructuredAiAdvice(
          explanation: 'ClearAir AI transforms local atmospheric sensor readings into prioritized, evidence-based family protection and emission-reduction choices.',
          recommendedActions: [
            'Ask: "How can my family stay safe during today\'s smog?"',
            'Ask: "Is it a good idea to take my children outdoors?"',
            'Ask: "How can I improve indoor air quality without spending too much?"',
            'Ask: "What should I change in my daily commute?"',
          ],
          whyItMatters: 'Winter temperature inversions trap microparticulates at street level. Early preventative planning reduces cumulative respiratory and vascular inflammation.',
          affordabilityEstimate: 'Free environmental guidance.',
          expectedBenefitAndUncertainty: 'Guides safe decisions while clearly explaining environmental factors.',
          sourceReference: 'WHO Global Air Quality Guidelines 2021; US EPA Clean Air Guidelines.',
          whenToSeekMedicalAdvice: 'ClearAir AI provides environmental health coaching, NOT clinical medical advice. Seek a medical professional for personal diagnosis or emergency symptom care.',
          isGenAiGenerated: false,
        ),
      );
      await _storage.setJsonList(_historyKey, [welcome.toJson()]);
      return [welcome];
    }
    return list.map((e) => AiAssistantMessage.fromJson(e)).toList();
  }

  @override
  Future<AiAssistantMessage> askAssistant({
    required String prompt,
    required AirQualityData? airQuality,
    required HouseholdProfile profile,
    required bool useRealGenAi,
    required String genAiApiKey,
    required String genAiEndpoint,
  }) async {
    const uuid = Uuid();
    final userMsg = AiAssistantMessage(
      id: 'usr_${uuid.v4()}',
      isUser: true,
      text: prompt,
      timestamp: DateTime.now(),
    );

    final history = await getConversationHistory();
    final updated = List<AiAssistantMessage>.from(history)..add(userMsg);

    final advice = await _client.ask(
      prompt: prompt,
      airQuality: airQuality,
      profile: profile,
      useRealGenAi: useRealGenAi,
      apiKey: genAiApiKey,
      endpoint: genAiEndpoint,
    );

    final assistantMsg = AiAssistantMessage(
      id: 'ai_${uuid.v4()}',
      isUser: false,
      text: advice.explanation,
      timestamp: DateTime.now(),
      structuredAdvice: advice,
    );

    updated.add(assistantMsg);
    // Keep last 30 messages
    final trimmed = updated.length > 30 ? updated.sublist(updated.length - 30) : updated;
    await _storage.setJsonList(_historyKey, trimmed.map((e) => e.toJson()).toList());

    return assistantMsg;
  }

  @override
  Future<AiImpactExplanation> explainImpact({
    required String actionTitle,
    required double co2AvoidedKg,
    required double fuelSavedLiters,
    required double pm25PreventedGrams,
    required String userContext,
    required bool useRealGenAi,
    required String genAiApiKey,
    required String genAiEndpoint,
  }) async {
    return _client.explainImpact(
      actionTitle: actionTitle,
      co2AvoidedKg: co2AvoidedKg,
      fuelSavedLiters: fuelSavedLiters,
      pm25PreventedGrams: pm25PreventedGrams,
      userContext: userContext,
      useRealGenAi: useRealGenAi,
      apiKey: genAiApiKey,
      endpoint: genAiEndpoint,
    );
  }

  @override
  Future<void> clearHistory() async {
    await _storage.remove(_historyKey);
  }
}
