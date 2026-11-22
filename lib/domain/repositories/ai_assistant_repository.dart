import '../models/ai_assistant_message.dart';
import '../models/ai_impact_explanation.dart';
import '../models/air_quality.dart';
import '../models/household_profile.dart';

abstract class AiAssistantRepository {
  Future<List<AiAssistantMessage>> getConversationHistory();
  Future<AiAssistantMessage> askAssistant({
    required String prompt,
    required AirQualityData? airQuality,
    required HouseholdProfile profile,
    required bool useRealGenAi,
    required String genAiApiKey,
    required String genAiEndpoint,
  });
  Future<AiImpactExplanation> explainImpact({
    required String actionTitle,
    required double co2AvoidedKg,
    required double fuelSavedLiters,
    required double pm25PreventedGrams,
    required String userContext,
    required bool useRealGenAi,
    required String genAiApiKey,
    required String genAiEndpoint,
  });
  Future<void> clearHistory();
}
