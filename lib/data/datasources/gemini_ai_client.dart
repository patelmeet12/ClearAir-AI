import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/utils/app_logger.dart';
import '../../domain/models/ai_assistant_message.dart';
import '../../domain/models/ai_impact_explanation.dart';
import '../../domain/models/air_quality.dart';
import '../../domain/models/household_profile.dart';

class GeminiAiClient {
  final http.Client _client;

  GeminiAiClient({http.Client? client}) : _client = client ?? http.Client();

  Future<StructuredAiAdvice> ask({
    required String prompt,
    required AirQualityData? airQuality,
    required HouseholdProfile profile,
    required bool useRealGenAi,
    required String apiKey,
    required String endpoint,
  }) async {
    if (useRealGenAi && apiKey.trim().isNotEmpty) {
      try {
        final realAdvice = await _callGeminiApi(
          prompt: prompt,
          airQuality: airQuality,
          profile: profile,
          apiKey: apiKey.trim(),
          endpoint: endpoint.trim(),
        );
        if (realAdvice != null) return realAdvice;
      } catch (e) {
        AppLogger.warning('Gemini GenAI request failed. Falling back to deterministic assistant engine.', e);
      }
    }

    // Deterministic Local Assistant
    return _generateDeterministicAdvice(
      prompt: prompt,
      airQuality: airQuality,
      profile: profile,
    );
  }

  Future<StructuredAiAdvice?> _callGeminiApi({
    required String prompt,
    required AirQualityData? airQuality,
    required HouseholdProfile profile,
    required String apiKey,
    required String endpoint,
  }) async {
    final url = endpoint.contains('key=') ? endpoint : '$endpoint?key=$apiKey';
    final uri = Uri.parse(url);

    final systemInstruction = '''
You are ClearAir AI, an intelligent environmental protection and air quality assistant.
Context:
- Location: ${airQuality?.locationName ?? 'Current area'}
- AQI: ${airQuality?.aqi ?? 150} (${airQuality?.category.title ?? 'Poor'})
- PM2.5: ${airQuality?.pm25 ?? 55} ug/m3, PM10: ${airQuality?.pm10 ?? 90} ug/m3
- Household: ${profile.adults} adults, ${profile.children} children, ${profile.olderAdults} seniors.
- Budget: ${profile.budget.label}
- Health vulnerability: ${profile.vulnerability.label}

CRITICAL RULES:
1. Provide environmental protection guidance only. NEVER diagnose diseases or prescribe medical treatments.
2. Balance emissions reduction with personal exposure safety: DO NOT advise cycling or jogging outside when AQI > 150.
3. Return valid JSON only with keys:
"explanation", "recommendedActions" (array of strings), "whyItMatters", "affordabilityEstimate", "expectedBenefitAndUncertainty", "sourceReference", "whenToSeekMedicalAdvice"
''';

    final body = {
      'contents': [
        {
          'parts': [
            {'text': '$systemInstruction\n\nUser Question: $prompt'}
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.2,
        'responseMimeType': 'application/json',
      }
    };

    final response = await _client.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ).timeout(const Duration(seconds: 12));

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = json['candidates'] as List<dynamic>?;
      if (candidates != null && candidates.isNotEmpty) {
        final text = candidates[0]['content']['parts'][0]['text'] as String;
        final parsed = jsonDecode(text) as Map<String, dynamic>;
        return StructuredAiAdvice(
          explanation: parsed['explanation'] as String? ?? 'Environmental analysis completed.',
          recommendedActions: (parsed['recommendedActions'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
          whyItMatters: parsed['whyItMatters'] as String? ?? 'Reduces particle deposition in lung tissue.',
          affordabilityEstimate: parsed['affordabilityEstimate'] as String? ?? 'Low to moderate cost.',
          expectedBenefitAndUncertainty: parsed['expectedBenefitAndUncertainty'] as String? ?? 'Estimated 40-70% exposure reduction depending on room seal.',
          sourceReference: parsed['sourceReference'] as String? ?? 'WHO Air Quality Guidelines 2021; US EPA Wildfire Guide.',
          whenToSeekMedicalAdvice: parsed['whenToSeekMedicalAdvice'] as String? ?? 'If persistent wheezing, tightness in chest, or shortness of breath occurs.',
          isGenAiGenerated: true,
        );
      }
    }
    return null;
  }

  StructuredAiAdvice _generateDeterministicAdvice({
    required String prompt,
    required AirQualityData? airQuality,
    required HouseholdProfile profile,
  }) {
    final q = prompt.toLowerCase();
    final aqi = airQuality?.aqi ?? 160;
    final pm25 = airQuality?.pm25 ?? 60.0;
    final isSevere = aqi >= 200;
    final hasSeniors = profile.olderAdults > 0;
    final isLowBudget = profile.budget == HouseholdBudget.minimal;

    if (q.contains('child') || q.contains('kid') || q.contains('outdoors') || q.contains('play')) {
      if (isSevere) {
        return StructuredAiAdvice(
          explanation: 'Today\'s outdoor air quality ($aqi AQI, ${pm25.toStringAsFixed(1)} µg/m³ PM2.5) is in the hazardous range. Children breathe 50% more air per kilogram of body weight than adults, and their narrower airways are especially vulnerable to particulate inflammation.',
          recommendedActions: [
            'Cancel outdoor recess, sports, and playground visits today.',
            'Keep children engaged with indoor obstacle courses, crafts, or reading.',
            'Ensure the bedroom where children sleep has a sealed door and running HEPA filtration.',
            if (profile.hasSchoolSchedule) 'Coordinate with school administrators to confirm indoor recess protocols.',
          ],
          whyItMatters: 'Fine PM2.5 penetrates deep into underdeveloped alveolar sacs and can trigger acute bronchial hyperreactivity.',
          affordabilityEstimate: 'Zero direct cost (rescheduling activities indoors).',
          expectedBenefitAndUncertainty: 'Reduces respiratory particulate intake by ~80-90% compared to vigorous outdoor activity. (Actual benefit depends on home sealing).',
          sourceReference: 'American Academy of Pediatrics (AAP) Ambient Air Pollution Guidance; WHO 2021 Global AQ Guidelines.',
          whenToSeekMedicalAdvice: 'Seek immediate pediatric medical attention if the child exhibits flaring nostrils, persistent cough, rapid shallow breathing, or chest retractions.',
          isGenAiGenerated: false,
        );
      } else {
        return StructuredAiAdvice(
          explanation: 'Outdoor air quality is currently moderate ($aqi AQI). Outdoor recreation is generally acceptable for healthy children, though vigorous exertion should be paced.',
          recommendedActions: const [
            'Permit outdoor play during afternoon hours when smog dispersion is optimal.',
            'Ensure regular hydration breaks away from high-traffic roadways.',
            'Monitor for any allergic sneezing or eye irritation.',
          ],
          whyItMatters: 'Physical play is vital for children\'s motor development when pollution levels remain below critical thresholds.',
          affordabilityEstimate: 'Free.',
          expectedBenefitAndUncertainty: 'Maintains healthy physical activity while avoiding peak traffic exposure windows.',
          sourceReference: 'US EPA Air Quality Flag Program for Schools.',
          whenToSeekMedicalAdvice: 'Consult a pediatrician if coughing or wheezing occurs during or after exercise.',
          isGenAiGenerated: false,
        );
      }
    } else if (q.contains('indoor') || q.contains('filter') || q.contains('clean air') || q.contains('purifier') || q.contains('spend') || q.contains('afford')) {
      return StructuredAiAdvice(
        explanation: 'Indoor air quality can be significantly improved even on a modest budget. In winter smog conditions, ambient PM2.5 infiltrates poorly sealed doors and windows, while indoor cooking can double particle concentrations.',
        recommendedActions: [
          isLowBudget
              ? 'Build a DIY Corsi-Rosenthal box or box fan with a MERV-13 filter (\$25-\$35 total cost).'
              : 'Deploy a certified True HEPA air purifier sized appropriately for the primary living space.',
          'Damp-mop hard floors rather than sweeping, which resuspends settled dust particles into breathing height.',
          'Always run the kitchen exhaust hood on maximum when cooking; avoid open-flame frying and incense.',
          'Note on houseplants: NASA clean air chamber studies tested VOCs in hermetic pods; common house plants do NOT remove dangerous PM2.5 particulates.',
        ],
        whyItMatters: 'HEPA and high-MERV filters physically intercept sub-micron particles with over 95% single-pass efficiency, preventing accumulation in living spaces.',
        affordabilityEstimate: isLowBudget ? 'Under \$30 for DIY filter and weatherstripping tape.' : '\$80 - \$180 for a reliable Energy Star HEPA purifier.',
        expectedBenefitAndUncertainty: 'Typically reduces indoor PM2.5 concentrations by 60% to 85% within 45 minutes of closed-room operation.',
        sourceReference: 'EPA Indoor Air Quality Scientific Assessment; CDC NIOSH DIY Air Filtration Engineering Evaluation.',
        whenToSeekMedicalAdvice: 'If family members experience persistent morning headaches or respiratory irritation despite indoor filtering, check for carbon monoxide risks or seek clinical review.',
        isGenAiGenerated: false,
      );
    } else if (q.contains('commute') || q.contains('work') || q.contains('travel') || q.contains('transport')) {
      return StructuredAiAdvice(
        explanation: 'Vehicle cabins and roadside corridors suffer from concentrated spikes of NO2, black carbon, and PM2.5. Safe commuting requires balancing your personal lung exposure against community emissions.',
        recommendedActions: [
          isSevere
              ? 'Avoid walking or cycling during hazardous smog. Use the electric subway or an air-conditioned bus with an N95 respirator.'
              : 'Use electric public transit or bicycle along quiet residential greenways away from arterial truck routes.',
          'If driving is unavoidable, set the car HVAC to \'Recirculate\' mode before entering tunnels and traffic bottlenecks.',
          'Replace your vehicle\'s cabin air filter with a PM2.5/activated carbon filter every 12,000 km.',
          'Never idle the engine in school zones or waiting lines (switches off tailpipe exposure for pedestrians).',
        ],
        whyItMatters: 'In-cabin particulate concentration can be 3 to 5 times lower in recirculation mode with clean filters compared to following tailpipes with open vents.',
        affordabilityEstimate: '\$15 - \$25 for an upgraded activated charcoal cabin filter; regular public transit fare.',
        expectedBenefitAndUncertainty: 'Reduces in-vehicle black carbon inhalation by ~70%; switching from solo car to transit saves ~1.8 kg CO2e per 10 km.',
        sourceReference: 'Atmospheric Environment Journal: In-Cabin Exposure Mitigation; EPA SmartWay Transport.',
        whenToSeekMedicalAdvice: 'If dizziness or shortness of breath occurs during commutes, pull over safely and seek medical evaluation.',
        isGenAiGenerated: false,
      );
    } else if (q.contains('elderly') || q.contains('senior') || hasSeniors) {
      return const StructuredAiAdvice(
        explanation: 'Older adults face elevated cardiovascular risks during particulate pollution events due to pre-existing arterial stiffness and reduced autonomic regulation.',
        recommendedActions: [
          'Stay strictly indoors during morning and evening smog peaks when thermal inversions trap surface smoke.',
          'Shift daily walks to a climate-controlled indoor shopping mall, community center, or hallway.',
          'Ensure all prescribed cardiovascular and pulmonary medications are stocked for at least 14 days.',
          'Keep hydration steady to help the mucosal lining clear inhaled dust.',
        ],
        whyItMatters: 'Fine particles cross into the bloodstream, triggering vascular inflammation that can destabilize arterial plaques.',
        affordabilityEstimate: 'Zero direct cost for scheduling adjustments.',
        expectedBenefitAndUncertainty: 'Avoids sudden hemodynamic stress and acute blood pressure surges triggered by cold smog inhalation.',
        sourceReference: 'American Heart Association (AHA) Scientific Statement on Air Pollution and Cardiovascular Disease.',
        whenToSeekMedicalAdvice: 'Call emergency medical services immediately for any chest pressure, radiation of pain to jaw/arm, or sudden severe breathlessness.',
        isGenAiGenerated: false,
      );
    } else {
      // General comprehensive protection
      return StructuredAiAdvice(
        explanation: 'Current local air quality is ${airQuality?.category.title ?? "challenging"} (AQI $aqi, PM2.5 ${pm25.toStringAsFixed(1)} µg/m³). An effective defense requires minimizing outdoor inhalation volume and sealing your indoor living envelope.',
        recommendedActions: [
          isSevere
              ? 'Wear a genuine, well-sealed N95 or FFP2 respirator for all necessary outdoor transits. Cloth masks do not filter PM2.5.'
              : 'Time essential outdoor tasks between 1:00 PM and 4:00 PM when solar warming disperses surface inversions.',
          'Run indoor air purifiers continuously on auto or medium mode.',
          'Adopt low-emission household habits: avoid burning trash, leaf piles, candles, or idling cars.',
          'Check local air quality before departing for daily routines.',
        ],
        whyItMatters: 'PM2.5 particles are 30 times smaller than a human hair and lodge deep in lung alveoli. Physical barrier filtration is the single most validated intervention.',
        affordabilityEstimate: '\$2-\$3 per reusable N95 mask; free for ventilation scheduling.',
        expectedBenefitAndUncertainty: 'Correctly fitted N95 respirators filter >=95% of fine particles. Poor mask fit reduces real-world efficacy to 50-60%.',
        sourceReference: 'WHO Global Air Quality Guidelines; US EPA Clean Air Guidelines.',
        whenToSeekMedicalAdvice: 'Consult a physician if you experience unresolved throat constriction, persistent wheeze, or sudden exercise intolerance.',
        isGenAiGenerated: false,
      );
    }
  }

  Future<AiImpactExplanation> explainImpact({
    required String actionTitle,
    required double co2AvoidedKg,
    required double fuelSavedLiters,
    required double pm25PreventedGrams,
    required String userContext,
    required bool useRealGenAi,
    required String apiKey,
    required String endpoint,
  }) async {
    // Generate evidence-aware impact explanation with transparent assumptions and limitations
    return AiImpactExplanation(
      actionTitle: actionTitle,
      whatChanged: 'You completed "$actionTitle", modifying daily transportation or energy consumption behavior.',
      exposureReduction: 'By optimizing your location, schedule, or vehicle cabin filtration, you directly lowered your respiratory dose of toxic particulates during peak atmospheric exposure hours.',
      emissionReduction: 'Estimated avoidance of ${co2AvoidedKg.toStringAsFixed(2)} kg CO2e greenhouse gas emissions and ${(pm25PreventedGrams * 1000).toStringAsFixed(1)} mg of fine particulate tailpipe/brake emissions.',
      whoBenefits: 'Immediate benefit to your household (lower direct particulate inhalation) and broader community benefit (reduced ambient street-level pollution for nearby pedestrians and schoolchildren).',
      assumptionsUsed: 'Based on standard EPA and IPCC emission baselines: Average passenger gasoline vehicle (~171 g CO2e/km, 12.5 km/L economy); electric transit grid mix (~28 g CO2e/pass-km); engine idling (~1.2 L fuel/hr).',
      limitationsOfEstimate: 'Actual emissions vary depending on specific vehicle weight, engine displacement, real-world traffic congestion, and local electric grid generation source. This is an engineered model estimate, not a direct tailpipe sensor reading.',
    );
  }
}
