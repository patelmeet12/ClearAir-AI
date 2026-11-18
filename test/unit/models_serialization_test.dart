import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:clearair_ai/core/constants/aqi_standards.dart';
import 'package:clearair_ai/domain/models/app_settings.dart';
import 'package:clearair_ai/domain/models/community_challenge.dart';
import 'package:clearair_ai/domain/models/daily_routine.dart';
import 'package:clearair_ai/domain/models/household_profile.dart';
import 'package:clearair_ai/domain/models/indoor_guide.dart';
import 'package:clearair_ai/domain/models/location.dart';
import 'package:clearair_ai/domain/models/sustainable_alternative.dart';

void main() {
  group('Domain Models Serialization Tests', () {
    test('LocationItem round-trip JSON serialization', () {
      const loc = LocationItem(
        id: 'test_123',
        name: 'Test City',
        country: 'Countryland',
        latitude: 12.345,
        longitude: 67.890,
        tag: LocationTag.home,
        isDefault: true,
      );

      final json = loc.toJson();
      final revived = LocationItem.fromJson(json);

      expect(revived, equals(loc));
      expect(revived.name, equals('Test City'));
      expect(revived.isDefault, isTrue);
    });

    test('HouseholdProfile round-trip JSON serialization', () {
      const profile = HouseholdProfile(
        adults: 3,
        children: 2,
        olderAdults: 1,
        budget: HouseholdBudget.flexible,
        activityPreference: ActivityPreference.mostlyIndoor,
        vulnerability: VulnerabilityFlag.respiratory,
        hasSchoolSchedule: true,
        hasWorkCommute: false,
      );

      final json = profile.toJson();
      final revived = HouseholdProfile.fromJson(json);

      expect(revived, equals(profile));
      expect(revived.totalMembers, equals(6));
      expect(revived.hasSensitiveMembers, isTrue);
    });

    test('DailyRoutine round-trip JSON serialization', () {
      const routine = RoutineItem(
        id: 'r_1',
        title: 'Morning Closed Transit',
        timeSlot: RoutineTimeSlot.morning,
        priority: RoutinePriority.high,
        suggestedTime: '8:00 AM',
        reason: 'Avoid smog inversion',
        estimatedCost: '\$2.00',
        convenience: 'High',
        exposureReduction: 'High',
        environmentalBenefit: 'Avoids 1.5kg CO2',
        isCompleted: true,
        co2AvoidedKg: 1.5,
        fuelSavedLiters: 0.6,
        costSavedUsd: 1.0,
      );

      final json = routine.toJson();
      final revived = RoutineItem.fromJson(json);

      expect(revived, equals(routine));
      expect(revived.isCompleted, isTrue);
    });

    test('IndoorChecklistItem round-trip JSON serialization', () {
      const item = IndoorChecklistItem(
        id: 'in_1',
        title: 'Seal Windows During Smog',
        category: IndoorCategory.ventilation,
        costTier: IndoorCostTier.zeroCost,
        actionDescription: 'Close window latches firmly',
        scientificWhy: 'Prevents infiltration',
        budgetAdvice: 'Free',
        isCompleted: true,
      );

      final json = item.toJson();
      final revived = IndoorChecklistItem.fromJson(json);

      expect(revived, equals(item));
      expect(revived.isCompleted, isTrue);
    });

    test('SustainableAlternativeItem round-trip JSON serialization', () {
      const alt = SustainableAlternativeItem(
        id: 'sust_1',
        title: 'Carpooling Routine',
        everydayActivity: 'Solo driving',
        currentBehavior: 'Driving alone',
        recommendedAlternative: 'Share ride',
        emissionImpactKgPerAction: 2.5,
        monthlyCo2BenefitKg: 30.0,
        monthlyCostBenefitUsd: 40.0,
        costImplications: 'Saves money',
        difficulty: PracticalDifficulty.moderate,
        whyItMatters: 'Reduces urban traffic',
        scientificAssumptions: '171 g/km baseline',
        isAdopted: true,
      );

      final json = alt.toJson();
      final revived = SustainableAlternativeItem.fromJson(json);

      expect(revived, equals(alt));
      expect(revived.isAdopted, isTrue);
    });

    test('CommunityChallenge round-trip JSON serialization', () {
      const chal = CommunityChallenge(
        id: 'c_1',
        title: 'Anti-Idling Drive',
        description: 'Turn off engine',
        durationText: '7 Days',
        participantsCount: 500,
        currentCo2SavedKg: 1200.0,
        goalCo2SavedKg: 2000.0,
        isEnrolled: true,
        daysRemaining: 4,
        badgeName: 'Idle Hero',
        practicalTip: 'Key off when stopped',
      );

      final json = chal.toJson();
      final revived = CommunityChallenge.fromJson(json);

      expect(revived, equals(chal));
      expect(revived.progressFraction, closeTo(0.6, 0.01));
    });

    test('AppSettings round-trip JSON serialization', () {
      const settings = AppSettings(
        themeMode: ThemeMode.dark,
        aqiStandard: AqiStandard.indiaNaqi,
        reducedMotion: true,
        isDemoMode: true,
        useRealGenAi: false,
        genAiApiKey: 'secret-key-123',
        genAiEndpoint: 'https://custom-proxy.internal',
        allowGeolocation: true,
      );

      final json = settings.toJson();
      final revived = AppSettings.fromJson(json);

      expect(revived, equals(settings));
      expect(revived.themeMode, equals(ThemeMode.dark));
      expect(revived.aqiStandard, equals(AqiStandard.indiaNaqi));
      expect(revived.reducedMotion, isTrue);
    });
  });
}
