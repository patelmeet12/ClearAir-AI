import '../../domain/models/air_quality.dart';
import '../../domain/models/indoor_guide.dart';
import '../../domain/repositories/indoor_repository.dart';
import '../datasources/local_storage_service.dart';

class IndoorRepositoryImpl implements IndoorRepository {
  final LocalStorageService _storage;
  static const String _completedIdsKey = 'indoor_completed_item_ids';
  static const String _filterDateKey = 'hepa_filter_last_replacement_date';

  IndoorRepositoryImpl({required LocalStorageService storage}) : _storage = storage;

  @override
  Future<List<IndoorChecklistItem>> getIndoorChecklist(AirQualityData? currentAqi) async {
    final completedIds = _storage.getStringList(_completedIdsKey) ?? [];
    final isSevere = (currentAqi?.aqi ?? 150) >= 200;

    final List<IndoorChecklistItem> baseList = [
      IndoorChecklistItem(
        id: 'indoor_ventilation_strategy',
        title: isSevere ? 'Keep Windows Firmly Closed (Smog Protocol)' : 'Dynamic Air Exchange Timing',
        category: IndoorCategory.ventilation,
        costTier: IndoorCostTier.zeroCost,
        actionDescription: isSevere
            ? 'Seal windows and external doors. Opening windows during severe outdoor smog invites toxic particulates into living spaces.'
            : 'Open windows for 15-20 minutes during midday when boundary-layer heating disperses ground particulates.',
        scientificWhy: 'Air infiltration through cracks can bring 40-70% of ambient PM2.5 indoors unless windows are sealed and internal filtering is active.',
        budgetAdvice: 'Use damp washcloths or \$5 foam tape to seal drafts under doors and leaky windows.',
        isCompleted: completedIds.contains('indoor_ventilation_strategy'),
        plantMythClarification: 'Common indoor houseplants do NOT filter particulate matter (PM2.5). Sealing the room and using physical filtration is the only proven method.',
      ),
      IndoorChecklistItem(
        id: 'indoor_filtration_hepa',
        title: 'Run True HEPA Filter Continuously',
        category: IndoorCategory.filtration,
        costTier: IndoorCostTier.mediumCost,
        actionDescription: 'Position your HEPA purifier in the room where your family spends the most time (living room by day, bedroom by night). Keep it on medium speed.',
        scientificWhy: 'True HEPA filters are tested to trap at least 99.97% of airborne particles as small as 0.3 microns, including fine dust, smoke, and allergens.',
        budgetAdvice: 'Low budget option: Assemble a Corsi-Rosenthal box using a standard 20-inch box fan and a MERV-13 furnace filter (\$30 total).',
        isCompleted: completedIds.contains('indoor_filtration_hepa'),
      ),
      IndoorChecklistItem(
        id: 'indoor_combustion_control',
        title: 'Eliminate Indoor Open Flames, Incense & Smoke',
        category: IndoorCategory.combustion,
        costTier: IndoorCostTier.zeroCost,
        actionDescription: 'Strictly prohibit indoor tobacco smoke, aromatic incense sticks, mosquito coils, and scented candles.',
        scientificWhy: 'Burning a single incense stick releases up to 45 mg of fine particulates and aromatic hydrocarbons, equivalent to multiple cigarettes in a closed room.',
        budgetAdvice: 'Completely free habit change that dramatically lowers indoor particulate spikes.',
        isCompleted: completedIds.contains('indoor_combustion_control'),
      ),
      IndoorChecklistItem(
        id: 'indoor_kitchen_ventilation',
        title: 'Use High-Power Range Hood When Cooking',
        category: IndoorCategory.kitchen,
        costTier: IndoorCostTier.zeroCost,
        actionDescription: 'Turn on kitchen exhaust hoods 2 minutes before cooking and leave running for 5 minutes after. Cover pots and pans with lids while boiling or frying.',
        scientificWhy: 'Cooking with oil and gas burners generates ultra-fine particles, NO2, and acrolein. Dedicated exhaust diverts these outside before dispersing into rooms.',
        budgetAdvice: 'Zero-cost practice. If no range hood exists, close kitchen interior doors and open a dedicated kitchen exhaust window.',
        isCompleted: completedIds.contains('indoor_kitchen_ventilation'),
      ),
      IndoorChecklistItem(
        id: 'indoor_dust_cleaning',
        title: 'Damp Mopping & Microfiber Surface Wiping',
        category: IndoorCategory.dustCleaning,
        costTier: IndoorCostTier.lowCost,
        actionDescription: 'Clean floors with a damp mop instead of dry sweeping with brooms. Wipe bookshelves and sills with microfiber cloths.',
        scientificWhy: 'Dry sweeping creates turbulence that resuspends settled toxic particulates into human breathing zones for hours.',
        budgetAdvice: 'Microfiber cloth (\$2) and tap water provide clinical-grade dust capture without costly vacuum upgrades.',
        isCompleted: completedIds.contains('indoor_dust_cleaning'),
      ),
      IndoorChecklistItem(
        id: 'indoor_aqi_monitoring',
        title: 'Track Indoor PM2.5 with a Laser Sensor',
        category: IndoorCategory.monitoring,
        costTier: IndoorCostTier.mediumCost,
        actionDescription: 'Keep a portable laser particle counter in the main living area to verify whether purifiers are effectively reducing PM2.5 below 15 µg/m³.',
        scientificWhy: 'Visual air clarity is deceptive; PM2.5 is invisible to the human eye. Sensor feedback reveals cooking spikes and leaky seals.',
        budgetAdvice: 'Reliable laser sensor monitors cost around \$45-\$70. High-budget options include integrated HVAC monitors.',
        isCompleted: completedIds.contains('indoor_aqi_monitoring'),
      ),
      IndoorChecklistItem(
        id: 'indoor_plant_myth_awareness',
        title: 'Houseplants vs True HEPA (Scientific Literacy)',
        category: IndoorCategory.filtration,
        costTier: IndoorCostTier.zeroCost,
        actionDescription: 'Do not rely on houseplants as a substitute for mechanical filtration during severe pollution.',
        scientificWhy: 'A 2019 comprehensive Drexel University review concluded that natural air exchange in normal homes ventilates away pollutants 100 to 1000 times faster than potted plants can metabolize them.',
        budgetAdvice: 'Save money: enjoy plants for aesthetics, but invest clean air budgets in certified HEPA filters.',
        isCompleted: completedIds.contains('indoor_plant_myth_awareness'),
        plantMythClarification: 'Scientific Consensus: Potted plants do NOT meaningfully remove dangerous ambient PM2.5 concentrations in realistic living spaces.',
      ),
    ];

    return baseList;
  }

  @override
  Future<void> toggleItem(String id, bool isCompleted) async {
    final list = _storage.getStringList(_completedIdsKey) ?? [];
    final set = Set<String>.from(list);
    if (isCompleted) {
      set.add(id);
    } else {
      set.remove(id);
    }
    await _storage.setStringList(_completedIdsKey, set.toList());
  }

  @override
  Future<void> resetChecklist() async {
    await _storage.remove(_completedIdsKey);
  }

  @override
  Future<DateTime?> getLastFilterReplacementDate() async {
    final str = _storage.getString(_filterDateKey);
    if (str == null) return null;
    return DateTime.tryParse(str);
  }

  @override
  Future<void> updateFilterReplacementDate(DateTime date) async {
    await _storage.setString(_filterDateKey, date.toIso8601String());
  }
}
