import 'package:equatable/equatable.dart';

enum HouseholdBudget {
  minimal('Low Budget / Free', 'Prioritize zero-cost measures: window sealing, timing commutes, low-energy habits'),
  moderate('Moderate Budget', 'Affordable investments: box-fan MERV filters, N95 masks, smart scheduling'),
  flexible('Comprehensive Budget', 'Dedicated HEPA purifiers, real-time indoor air monitors, HVAC upgrades');

  final String label;
  final String description;
  const HouseholdBudget(this.label, this.description);
}

enum ActivityPreference {
  mostlyIndoor('Mostly Indoor', 'Prefers home/indoor pursuits; prioritize clean indoor air quality'),
  balanced('Balanced', 'Daily routine involves regular commutes and moderate outdoor activities'),
  activeOutdoor('Active Outdoor', 'Frequent sports/outdoor work; requires precise timing to avoid smog peaks');

  final String label;
  final String description;
  const ActivityPreference(this.label, this.description);
}

enum VulnerabilityFlag {
  none('Standard Sensitivity', 'General public advisory levels apply'),
  respiratory('Respiratory Vulnerability (Asthma, Allergies)', 'Heightened sensitivity to PM2.5 and ozone; keep relief inhalers accessible as advised by doctor'),
  cardiovascular('Cardiovascular Sensitivity', 'Caution against exertion during high particulate spikes'),
  childOrElderly('Young Children or Seniors Present', 'Airways are more susceptible to deep particulate penetration');

  final String label;
  final String advisory;
  const VulnerabilityFlag(this.label, this.advisory);
}

class HouseholdProfile extends Equatable {
  final int adults;
  final int children;
  final int olderAdults;
  final HouseholdBudget budget;
  final ActivityPreference activityPreference;
  final VulnerabilityFlag vulnerability;
  final bool hasSchoolSchedule;
  final bool hasWorkCommute;

  const HouseholdProfile({
    this.adults = 2,
    this.children = 1,
    this.olderAdults = 0,
    this.budget = HouseholdBudget.moderate,
    this.activityPreference = ActivityPreference.balanced,
    this.vulnerability = VulnerabilityFlag.none,
    this.hasSchoolSchedule = true,
    this.hasWorkCommute = true,
  });

  bool get hasSensitiveMembers => children > 0 || olderAdults > 0 || vulnerability != VulnerabilityFlag.none;

  int get totalMembers => adults + children + olderAdults;

  HouseholdProfile copyWith({
    int? adults,
    int? children,
    int? olderAdults,
    HouseholdBudget? budget,
    ActivityPreference? activityPreference,
    VulnerabilityFlag? vulnerability,
    bool? hasSchoolSchedule,
    bool? hasWorkCommute,
  }) {
    return HouseholdProfile(
      adults: adults ?? this.adults,
      children: children ?? this.children,
      olderAdults: olderAdults ?? this.olderAdults,
      budget: budget ?? this.budget,
      activityPreference: activityPreference ?? this.activityPreference,
      vulnerability: vulnerability ?? this.vulnerability,
      hasSchoolSchedule: hasSchoolSchedule ?? this.hasSchoolSchedule,
      hasWorkCommute: hasWorkCommute ?? this.hasWorkCommute,
    );
  }

  Map<String, dynamic> toJson() => {
    'adults': adults,
    'children': children,
    'olderAdults': olderAdults,
    'budget': budget.name,
    'activityPreference': activityPreference.name,
    'vulnerability': vulnerability.name,
    'hasSchoolSchedule': hasSchoolSchedule,
    'hasWorkCommute': hasWorkCommute,
  };

  factory HouseholdProfile.fromJson(Map<String, dynamic> json) => HouseholdProfile(
    adults: json['adults'] as int? ?? 2,
    children: json['children'] as int? ?? 1,
    olderAdults: json['olderAdults'] as int? ?? 0,
    budget: HouseholdBudget.values.firstWhere(
      (b) => b.name == json['budget'],
      orElse: () => HouseholdBudget.moderate,
    ),
    activityPreference: ActivityPreference.values.firstWhere(
      (a) => a.name == json['activityPreference'],
      orElse: () => ActivityPreference.balanced,
    ),
    vulnerability: VulnerabilityFlag.values.firstWhere(
      (v) => v.name == json['vulnerability'],
      orElse: () => VulnerabilityFlag.none,
    ),
    hasSchoolSchedule: json['hasSchoolSchedule'] as bool? ?? true,
    hasWorkCommute: json['hasWorkCommute'] as bool? ?? true,
  );

  @override
  List<Object?> get props => [
    adults,
    children,
    olderAdults,
    budget,
    activityPreference,
    vulnerability,
    hasSchoolSchedule,
    hasWorkCommute,
  ];
}
