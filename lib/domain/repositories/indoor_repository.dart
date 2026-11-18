import '../models/indoor_guide.dart';
import '../models/air_quality.dart';

abstract class IndoorRepository {
  Future<List<IndoorChecklistItem>> getIndoorChecklist(AirQualityData? currentAqi);
  Future<void> toggleItem(String id, bool isCompleted);
  Future<void> resetChecklist();
  Future<DateTime?> getLastFilterReplacementDate();
  Future<void> updateFilterReplacementDate(DateTime date);
}
