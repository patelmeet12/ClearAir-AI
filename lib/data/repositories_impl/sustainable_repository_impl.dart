import '../../domain/models/sustainable_alternative.dart';
import '../../domain/repositories/sustainable_repository.dart';
import '../../core/utils/impact_calculator.dart';
import '../datasources/local_storage_service.dart';

class SustainableRepositoryImpl implements SustainableRepository {
  final LocalStorageService _storage;
  static const String _adoptedIdsKey = 'sustainable_adopted_ids';

  SustainableRepositoryImpl({required LocalStorageService storage}) : _storage = storage;

  @override
  Future<List<SustainableAlternativeItem>> getAlternatives() async {
    final adoptedIds = _storage.getStringList(_adoptedIdsKey) ?? [];

    final List<SustainableAlternativeItem> items = [
      SustainableAlternativeItem(
        id: 'sust_solo_car_commute',
        title: 'Solo Car Commute Shift',
        everydayActivity: 'Individual car commute',
        currentBehavior: 'Driving alone 15 km each way to work in a gasoline sedan',
        recommendedAlternative: 'Take the electric metro, commuter rail, or carpool with a coworker 3 days per week',
        emissionImpactKgPerAction: 3.42,
        monthlyCo2BenefitKg: 41.0,
        monthlyCostBenefitUsd: 55.0,
        costImplications: 'Saves \$40-\$80 monthly in gasoline and parking fees; modest public transit fare',
        difficulty: PracticalDifficulty.moderate,
        whyItMatters: 'Removes a private vehicle from urban congestion corridors, reducing street-level NO2 and secondary particulate formation.',
        scientificAssumptions: 'Assumes 30 km round trip; 171 g CO2e/km solo car baseline vs 28 g CO2e/km electric rail. Fuel price: \$1.35/L.',
        isAdopted: adoptedIds.contains('sust_solo_car_commute'),
      ),
      SustainableAlternativeItem(
        id: 'sust_short_vehicle_trips',
        title: 'Short Errand Transit Mode',
        everydayActivity: 'Short vehicle trips (< 3 km)',
        currentBehavior: 'Turning on the car for 1-2 km grocery or post office visits',
        recommendedAlternative: 'Walk or bicycle when outdoor AQI is Good/Moderate; use electric transit or micro-mobility when AQI > 100',
        emissionImpactKgPerAction: 0.85,
        monthlyCo2BenefitKg: 10.2,
        monthlyCostBenefitUsd: 18.0,
        costImplications: 'Free (walking/cycling) or small transit fare; eliminates expensive cold-start engine wear',
        difficulty: PracticalDifficulty.easy,
        whyItMatters: 'Engines run in fuel-rich "cold-start" mode for the first 3 km, emitting up to 5x higher VOCs and CO per kilometer.',
        scientificAssumptions: 'Assumes four 2 km short trips per week. Note: When outdoor smog is severe (AQI > 200), prioritize lung safety over cycling.',
        isAdopted: adoptedIds.contains('sust_short_vehicle_trips'),
      ),
      SustainableAlternativeItem(
        id: 'sust_trip_chaining',
        title: 'Trip Chaining & Errand Bundling',
        everydayActivity: 'Repeated dispersed errands',
        currentBehavior: 'Making separate round trips for groceries, banking, dry cleaning, and pharmacy',
        recommendedAlternative: 'Consolidate multiple destination stops into a single continuous loop during non-peak hours',
        emissionImpactKgPerAction: 1.02,
        monthlyCo2BenefitKg: 12.5,
        monthlyCostBenefitUsd: 22.0,
        costImplications: 'Direct fuel cost reduction; saves 1.5 - 2.5 hours of personal driving time per month',
        difficulty: PracticalDifficulty.easy,
        whyItMatters: 'A single warm-engine loop produces 40% fewer total emissions than three separate cold starts.',
        scientificAssumptions: 'Assumes saving 6 km of redundant driving per week across 3 chained errands.',
        isAdopted: adoptedIds.contains('sust_trip_chaining'),
      ),
      SustainableAlternativeItem(
        id: 'sust_anti_idling',
        title: 'Vehicle Anti-Idling Practice',
        everydayActivity: 'Vehicle idling',
        currentBehavior: 'Leaving the car engine running while waiting in school pick-up queues, parking lots, or train crossings',
        recommendedAlternative: 'Turn off ignition whenever stopped for more than 20 seconds outside traffic lanes',
        emissionImpactKgPerAction: 0.46,
        monthlyCo2BenefitKg: 9.2,
        monthlyCostBenefitUsd: 15.0,
        costImplications: 'Instant fuel savings; modern fuel-injected starters consume less fuel than 10 seconds of idling',
        difficulty: PracticalDifficulty.easy,
        whyItMatters: 'Idling produces concentrated ground-level exhaust directly at breathing height of children walking on sidewalks.',
        scientificAssumptions: 'Baseline: 1.2 L gasoline consumed per hour of idle; 2.31 kg CO2/L. 10 minutes idle avoided 4 days a week.',
        isAdopted: adoptedIds.contains('sust_anti_idling'),
      ),
      SustainableAlternativeItem(
        id: 'sust_energy_appliances',
        title: 'Smart Appliance Scheduling & Efficiency',
        everydayActivity: 'High-energy appliances',
        currentBehavior: 'Running dishwashers, clothes dryers, and water heaters during peak afternoon grid hours',
        recommendedAlternative: 'Run heavy appliances in eco-mode and schedule during off-peak or solar-abundant hours',
        emissionImpactKgPerAction: 1.18,
        monthlyCo2BenefitKg: 14.2,
        monthlyCostBenefitUsd: 12.0,
        costImplications: 'Lower monthly electricity utility bill with zero upfront capital expenditure',
        difficulty: PracticalDifficulty.easy,
        whyItMatters: 'Peak hours force electrical utilities to fire up high-polluting fossil peaker plants that emit sulfur and nitrogen oxides.',
        scientificAssumptions: 'Grid emissions: 0.475 kg CO2e/kWh. 2.5 kWh shifted or saved per action.',
        isAdopted: adoptedIds.contains('sust_energy_appliances'),
      ),
      SustainableAlternativeItem(
        id: 'sust_reusable_products',
        title: 'Reusable Protection & Low-Waste Living',
        everydayActivity: 'Disposable household products',
        currentBehavior: 'Using single-use paper towels, plastic wipes, and disposing paper filters prematurely',
        recommendedAlternative: 'Use washable microfiber dust cloths and wash pre-filters monthly to extend HEPA lifespan',
        emissionImpactKgPerAction: 0.35,
        monthlyCo2BenefitKg: 4.5,
        monthlyCostBenefitUsd: 10.0,
        costImplications: 'Reduces recurring purchases of wipes and extends main HEPA filter life by 3-6 months',
        difficulty: PracticalDifficulty.easy,
        whyItMatters: 'Vacuuming coarse dust off pre-filters maintains airflow efficiency and prevents early landfill waste.',
        scientificAssumptions: 'Life cycle analysis: Washable microfiber prevents ~0.35 kg CO2e in manufacturing and packaging per week.',
        isAdopted: adoptedIds.contains('sust_reusable_products'),
      ),
    ];

    return items;
  }

  @override
  Future<void> toggleAdopted(String id, bool isAdopted) async {
    final list = _storage.getStringList(_adoptedIdsKey) ?? [];
    final set = Set<String>.from(list);
    if (isAdopted) {
      set.add(id);
    } else {
      set.remove(id);
    }
    await _storage.setStringList(_adoptedIdsKey, set.toList());
  }

  @override
  Future<ImpactCalculationResult> getCumulativePersonalImpact() async {
    final items = await getAlternatives();
    final adopted = items.where((e) => e.isAdopted).toList();

    double totalCo2 = 0.0;
    double totalCost = 0.0;
    double totalFuel = 0.0;
    double totalPm25 = 0.0;

    for (final a in adopted) {
      totalCo2 += a.monthlyCo2BenefitKg;
      totalCost += a.monthlyCostBenefitUsd;
      totalFuel += a.monthlyCo2BenefitKg / 2.31; // L saved
      totalPm25 += (a.monthlyCo2BenefitKg * 0.015); // grams PM avoided
    }

    return ImpactCalculationResult(
      co2AvoidedKg: totalCo2,
      fuelSavedLiters: totalFuel,
      costSavedUsd: totalCost,
      pm25PreventedGrams: totalPm25,
      assumptionNotes: 'Cumulative monthly savings calculated from your ${adopted.length} adopted sustainable routines.',
    );
  }
}
