import '../models/air_quality.dart';
import '../models/daily_routine.dart';
import '../models/household_profile.dart';

abstract class RoutineRepository {
  Future<List<RoutineItem>> getRoutines();
  Future<List<RoutineItem>> generateDailyRoutines({
    required AirQualityData airQuality,
    required HouseholdProfile profile,
  });
  Future<void> toggleRoutineCompletion(String id, bool isCompleted);
  Future<void> resetRoutines();
}
