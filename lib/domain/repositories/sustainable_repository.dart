import '../models/sustainable_alternative.dart';
import '../../core/utils/impact_calculator.dart';

abstract class SustainableRepository {
  Future<List<SustainableAlternativeItem>> getAlternatives();
  Future<void> toggleAdopted(String id, bool isAdopted);
  Future<ImpactCalculationResult> getCumulativePersonalImpact();
}
