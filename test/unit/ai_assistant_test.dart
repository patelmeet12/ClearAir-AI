import 'package:flutter_test/flutter_test.dart';
import 'package:clearair_ai/core/constants/aqi_standards.dart';
import 'package:clearair_ai/data/datasources/gemini_ai_client.dart';
import 'package:clearair_ai/domain/models/air_quality.dart';
import 'package:clearair_ai/domain/models/household_profile.dart';

void main() {
  group('GeminiAiClient & Deterministic Assistant Tests', () {
    late GeminiAiClient client;

    setUp(() {
      client = GeminiAiClient();
    });

    test('Provides deterministic advice with all required sections when GenAI is unconfigured', () async {
      final aqi = AirQualityData(
        locationName: 'Delhi NCR',
        latitude: 28.61,
        longitude: 77.20,
        aqi: 350,
        category: AqiCategory.severe,
        pm25: 300.0,
        pm10: 450.0,
        no2: 80.0,
        so2: 25.0,
        co: 2400.0,
        o3: 35.0,
        temperatureC: 16.0,
        humidityPercent: 75.0,
        windSpeedKmh: 5.0,
        weatherCode: 45,
        dataSourceType: DataSourceType.demo,
        dataSourceName: 'Test Demo',
        lastUpdated: DateTime.now(),
        hourlyForecast: const [],
      );

      const profile = HouseholdProfile(children: 2, olderAdults: 0);

      final advice = await client.ask(
        prompt: 'Is it a good idea to take my children outdoors today?',
        airQuality: aqi,
        profile: profile,
        useRealGenAi: false,
        apiKey: '',
        endpoint: '',
      );

      // Section 5 acceptance criteria:
      // 1. Short, understandable explanation
      expect(advice.explanation, isNotEmpty);
      expect(advice.explanation.toLowerCase(), contains('hazardous'));

      // 2. Recommended actions
      expect(advice.recommendedActions, isNotEmpty);
      expect(advice.recommendedActions.any((a) => a.contains('Cancel outdoor recess')), isTrue);

      // 3. Why each action matters
      expect(advice.whyItMatters, isNotEmpty);

      // 4. Estimated cost or affordability
      expect(advice.affordabilityEstimate, isNotEmpty);

      // 5. Expected benefit with uncertainty clearly stated
      expect(advice.expectedBenefitAndUncertainty, contains('benefit depends on'));

      // 6. Source or evidence reference
      expect(advice.sourceReference, isNotEmpty);

      // 7. When to seek professional medical advice
      expect(advice.whenToSeekMedicalAdvice, isNotEmpty);

      // Never claims rule-based is an LLM
      expect(advice.isGenAiGenerated, isFalse);
    });

    test('Answers indoor filtration queries with houseplant clarification', () async {
      const profile = HouseholdProfile(budget: HouseholdBudget.minimal);

      final advice = await client.ask(
        prompt: 'How can I improve indoor air quality without spending too much?',
        airQuality: null,
        profile: profile,
        useRealGenAi: false,
        apiKey: '',
        endpoint: '',
      );

      expect(advice.recommendedActions.any((a) => a.contains('houseplants')), isTrue);
      expect(advice.affordabilityEstimate, contains('Under \$30'));
    });

    test('Generates transparent "Why This Matters" impact explanation', () async {
      final explanation = await client.explainImpact(
        actionTitle: 'Avoided Vehicle Idling',
        co2AvoidedKg: 0.46,
        fuelSavedLiters: 0.2,
        pm25PreventedGrams: 0.005,
        userContext: 'Daily routine',
        useRealGenAi: false,
        apiKey: '',
        endpoint: '',
      );

      expect(explanation.actionTitle, equals('Avoided Vehicle Idling'));
      expect(explanation.exposureReduction, isNotEmpty);
      expect(explanation.emissionReduction, contains('0.46 kg CO2e'));
      expect(explanation.assumptionsUsed, contains('EPA'));
      expect(explanation.limitationsOfEstimate, contains('model estimate'));
    });
  });
}
