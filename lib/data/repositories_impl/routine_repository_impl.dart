import '../../domain/models/daily_routine.dart';
import '../../domain/models/air_quality.dart';
import '../../domain/models/household_profile.dart';
import '../../domain/repositories/routine_repository.dart';
import '../datasources/local_storage_service.dart';

class RoutineRepositoryImpl implements RoutineRepository {
  final LocalStorageService _storage;
  static const String _routinesKey = 'user_daily_routines';

  RoutineRepositoryImpl({required LocalStorageService storage}) : _storage = storage;

  @override
  Future<List<RoutineItem>> getRoutines() async {
    final list = _storage.getJsonList(_routinesKey);
    if (list == null || list.isEmpty) {
      return [];
    }
    return list.map((e) => RoutineItem.fromJson(e)).toList();
  }

  @override
  Future<List<RoutineItem>> generateDailyRoutines({
    required AirQualityData airQuality,
    required HouseholdProfile profile,
  }) async {
    final isSevere = airQuality.aqi >= 200;
    final isPoor = airQuality.aqi >= 100 && airQuality.aqi < 200;
    final hasKids = profile.children > 0;

    final List<RoutineItem> items = [];

    // --- MORNING ---
    if (isSevere) {
      items.add(
        const RoutineItem(
          id: 'routine_morn_commute',
          title: 'Protected Commute: Closed Metro / Bus with N95',
          timeSlot: RoutineTimeSlot.morning,
          priority: RoutinePriority.high,
          suggestedTime: '7:45 AM',
          reason: 'Surface thermal inversions peak in the morning, concentrating hazardous ground-level PM2.5. Avoid outdoor cycling or walking today.',
          estimatedCost: '\$2 - \$3 (Respirator / Transit)',
          convenience: 'Moderate',
          exposureReduction: 'High (up to 95% particulate filtration)',
          environmentalBenefit: 'Avoids ~1.7 kg CO2e compared to solo driving',
          co2AvoidedKg: 1.7,
          fuelSavedLiters: 0.8,
          costSavedUsd: 1.5,
        ),
      );
    } else if (isPoor) {
      items.add(
        const RoutineItem(
          id: 'routine_morn_commute',
          title: 'Shift Morning Errand or Carpool',
          timeSlot: RoutineTimeSlot.morning,
          priority: RoutinePriority.medium,
          suggestedTime: '8:30 AM',
          reason: 'Air quality is unhealthiest during peak rush hour. Delay departure or ride-share to reduce exposure.',
          estimatedCost: 'Free / Shared fuel',
          convenience: 'High',
          exposureReduction: 'Moderate (~30% lower congestion exposure)',
          environmentalBenefit: 'Avoids ~0.9 kg CO2e via carpooling',
          co2AvoidedKg: 0.9,
          fuelSavedLiters: 0.4,
          costSavedUsd: 0.9,
        ),
      );
    } else {
      items.add(
        const RoutineItem(
          id: 'routine_morn_commute',
          title: 'Active Green Commute (Walk / Cycle)',
          timeSlot: RoutineTimeSlot.morning,
          priority: RoutinePriority.medium,
          suggestedTime: '8:00 AM',
          reason: 'Air quality is clean and favorable. Outdoor physical activity provides cardiovascular benefits with zero tailpipe pollution.',
          estimatedCost: 'Free',
          convenience: 'High',
          exposureReduction: 'Safe baseline exposure',
          environmentalBenefit: 'Zero emissions; saves ~1.5 kg CO2e',
          co2AvoidedKg: 1.5,
          fuelSavedLiters: 0.7,
          costSavedUsd: 1.2,
        ),
      );
    }

    if (hasKids) {
      items.add(
        RoutineItem(
          id: 'routine_morn_school',
          title: isSevere ? 'Confirm Indoor School Recess' : 'Check Morning AQI Before School Run',
          timeSlot: RoutineTimeSlot.morning,
          priority: isSevere ? RoutinePriority.high : RoutinePriority.medium,
          suggestedTime: '8:15 AM',
          reason: isSevere
              ? 'Children breathe significantly more air per pound of body weight. Outdoor running in severe smog triggers respiratory stress.'
              : 'Keep an eye on midday ozone or particulate forecasts for afternoon sports.',
          estimatedCost: 'Free',
          convenience: 'High',
          exposureReduction: isSevere ? 'High (~80% lung dose reduction)' : 'Low-Moderate',
          environmentalBenefit: 'Encourages community health awareness',
          co2AvoidedKg: 0.0,
          fuelSavedLiters: 0.0,
          costSavedUsd: 0.0,
        ),
      );
    }

    // --- AFTERNOON ---
    items.add(
      const RoutineItem(
        id: 'routine_noon_idling',
        title: 'Zero Vehicle Idling at Pick-Up & Drive-Thrus',
        timeSlot: RoutineTimeSlot.afternoon,
        priority: RoutinePriority.high,
        suggestedTime: '1:30 PM',
        reason: 'Idling engines produce concentrated plumes of toxic exhaust directly at child-height around schools and parking bays.',
        estimatedCost: 'Free (Saves money)',
        convenience: 'High',
        exposureReduction: 'High for bystanders & drivers in queue',
        environmentalBenefit: 'Eliminates ~0.4 kg CO2e and 0.1L fuel per 10 min idle',
        co2AvoidedKg: 0.46,
        fuelSavedLiters: 0.2,
        costSavedUsd: 0.35,
      ),
    );

    items.add(
      RoutineItem(
        id: 'routine_noon_ventilation',
        title: isSevere
            ? 'Keep Building Sealed & Check Purifier Filter'
            : 'Brief Window Cross-Ventilation (15-20 min)',
        timeSlot: RoutineTimeSlot.afternoon,
        priority: RoutinePriority.medium,
        suggestedTime: '2:15 PM',
        reason: isSevere
            ? 'Do not open windows; outdoor air is toxic. Keep purifier fan on medium speed.'
            : 'Midday solar heating elevates the boundary layer, making early afternoon the cleanest window for flushing indoor CO2.',
        estimatedCost: 'Free',
        convenience: 'High',
        exposureReduction: isSevere ? 'High' : 'Moderate',
        environmentalBenefit: 'Natural ventilation reduces air conditioning load',
        co2AvoidedKg: 0.2,
        fuelSavedLiters: 0.0,
        costSavedUsd: 0.1,
      ),
    );

    // --- EVENING ---
    items.add(
      const RoutineItem(
        id: 'routine_eve_errands',
        title: 'Combine Evening Errands (Trip Chaining)',
        timeSlot: RoutineTimeSlot.evening,
        priority: RoutinePriority.medium,
        suggestedTime: '5:45 PM',
        reason: 'Cold engines emit twice the pollutants of warm engines. Combining grocery, pharmacy, and bank stops into one loop cuts emissions and driving exposure.',
        estimatedCost: 'Free (Saves fuel)',
        convenience: 'Moderate',
        exposureReduction: 'Moderate (Less time in traffic corridors)',
        environmentalBenefit: 'Saves ~1.0 kg CO2e and reduces cold-start hydrocarbon spikes',
        co2AvoidedKg: 1.0,
        fuelSavedLiters: 0.5,
        costSavedUsd: 0.8,
      ),
    );

    items.add(
      RoutineItem(
        id: 'routine_eve_exercise',
        title: isSevere ? 'Indoor Bodyweight / Yoga Workout' : 'Evening Outdoor Walk in Park',
        timeSlot: RoutineTimeSlot.evening,
        priority: RoutinePriority.medium,
        suggestedTime: '6:30 PM',
        reason: isSevere
            ? 'Deep breathing during outdoor cardio in high smog deposits 4x more PM2.5 in small airways. Stay indoors.'
            : 'Enjoy mild physical activity in urban parks away from roadway congestion.',
        estimatedCost: 'Free',
        convenience: 'High',
        exposureReduction: isSevere ? 'High (~85% respiratory protection)' : 'Baseline',
        environmentalBenefit: 'Promotes active lifestyle and zero carbon usage',
        co2AvoidedKg: 0.0,
        fuelSavedLiters: 0.0,
        costSavedUsd: 0.0,
      ),
    );

    // --- NIGHT ---
    items.add(
      const RoutineItem(
        id: 'routine_night_bedroom',
        title: 'Create a Sealed Clean-Air Bedroom',
        timeSlot: RoutineTimeSlot.night,
        priority: RoutinePriority.high,
        suggestedTime: '9:30 PM',
        reason: 'Humans spend 7-9 hours sleeping in one room. Running a quiet HEPA filter in a closed bedroom ensures unburdened airway recovery overnight.',
        estimatedCost: '\$0.05 / night in electricity',
        convenience: 'High',
        exposureReduction: 'Very High (Maintains indoor PM2.5 < 15 µg/m³)',
        environmentalBenefit: 'Energy efficient bedroom zoning saves HVAC power',
        co2AvoidedKg: 0.3,
        fuelSavedLiters: 0.0,
        costSavedUsd: 0.15,
      ),
    );

    await _storage.setJsonList(_routinesKey, items.map((e) => e.toJson()).toList());
    return items;
  }

  @override
  Future<void> toggleRoutineCompletion(String id, bool isCompleted) async {
    final list = await getRoutines();
    final updated = list.map((e) => e.id == id ? e.copyWith(isCompleted: isCompleted) : e).toList();
    await _storage.setJsonList(_routinesKey, updated.map((e) => e.toJson()).toList());
  }

  @override
  Future<void> resetRoutines() async {
    await _storage.remove(_routinesKey);
  }
}
