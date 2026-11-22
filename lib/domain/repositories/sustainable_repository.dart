import '../../core/utils/impact_calculator.dart';
import '../models/sustainable_alternative.dart';

abstract class SustainableRepository {
  Future<List<SustainableAlternativeItem>> getAlternatives();
  Future<void> toggleAdopted(String id, bool isAdopted);
  Future<ImpactCalculationResult> getCumulativePersonalImpact();
}
