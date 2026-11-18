import 'package:equatable/equatable.dart';

enum PracticalDifficulty {
  easy('Easy', 'Requires minimal planning or lifestyle alteration'),
  moderate('Moderate', 'Requires some route adjustment or brief habit change'),
  advanced('Significant', 'Requires scheduling coordination or modest equipment');

  final String label;
  final String description;
  const PracticalDifficulty(this.label, this.description);
}

class SustainableAlternativeItem extends Equatable {
  final String id;
  final String title;
  final String everydayActivity;
  final String currentBehavior;
  final String recommendedAlternative;
  final double emissionImpactKgPerAction;
  final double monthlyCo2BenefitKg;
  final double monthlyCostBenefitUsd;
  final String costImplications;
  final PracticalDifficulty difficulty;
  final String whyItMatters;
  final String scientificAssumptions;
  final bool isAdopted;

  const SustainableAlternativeItem({
    required this.id,
    required this.title,
    required this.everydayActivity,
    required this.currentBehavior,
    required this.recommendedAlternative,
    required this.emissionImpactKgPerAction,
    required this.monthlyCo2BenefitKg,
    required this.monthlyCostBenefitUsd,
    required this.costImplications,
    required this.difficulty,
    required this.whyItMatters,
    required this.scientificAssumptions,
    this.isAdopted = false,
  });

  SustainableAlternativeItem copyWith({
    String? id,
    String? title,
    String? everydayActivity,
    String? currentBehavior,
    String? recommendedAlternative,
    double? emissionImpactKgPerAction,
    double? monthlyCo2BenefitKg,
    double? monthlyCostBenefitUsd,
    String? costImplications,
    PracticalDifficulty? difficulty,
    String? whyItMatters,
    String? scientificAssumptions,
    bool? isAdopted,
  }) {
    return SustainableAlternativeItem(
      id: id ?? this.id,
      title: title ?? this.title,
      everydayActivity: everydayActivity ?? this.everydayActivity,
      currentBehavior: currentBehavior ?? this.currentBehavior,
      recommendedAlternative: recommendedAlternative ?? this.recommendedAlternative,
      emissionImpactKgPerAction: emissionImpactKgPerAction ?? this.emissionImpactKgPerAction,
      monthlyCo2BenefitKg: monthlyCo2BenefitKg ?? this.monthlyCo2BenefitKg,
      monthlyCostBenefitUsd: monthlyCostBenefitUsd ?? this.monthlyCostBenefitUsd,
      costImplications: costImplications ?? this.costImplications,
      difficulty: difficulty ?? this.difficulty,
      whyItMatters: whyItMatters ?? this.whyItMatters,
      scientificAssumptions: scientificAssumptions ?? this.scientificAssumptions,
      isAdopted: isAdopted ?? this.isAdopted,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'everydayActivity': everydayActivity,
    'currentBehavior': currentBehavior,
    'recommendedAlternative': recommendedAlternative,
    'emissionImpactKgPerAction': emissionImpactKgPerAction,
    'monthlyCo2BenefitKg': monthlyCo2BenefitKg,
    'monthlyCostBenefitUsd': monthlyCostBenefitUsd,
    'costImplications': costImplications,
    'difficulty': difficulty.name,
    'whyItMatters': whyItMatters,
    'scientificAssumptions': scientificAssumptions,
    'isAdopted': isAdopted,
  };

  factory SustainableAlternativeItem.fromJson(Map<String, dynamic> json) => SustainableAlternativeItem(
    id: json['id'] as String,
    title: json['title'] as String,
    everydayActivity: json['everydayActivity'] as String,
    currentBehavior: json['currentBehavior'] as String,
    recommendedAlternative: json['recommendedAlternative'] as String,
    emissionImpactKgPerAction: (json['emissionImpactKgPerAction'] as num).toDouble(),
    monthlyCo2BenefitKg: (json['monthlyCo2BenefitKg'] as num).toDouble(),
    monthlyCostBenefitUsd: (json['monthlyCostBenefitUsd'] as num).toDouble(),
    costImplications: json['costImplications'] as String,
    difficulty: PracticalDifficulty.values.firstWhere(
      (d) => d.name == json['difficulty'],
      orElse: () => PracticalDifficulty.easy,
    ),
    whyItMatters: json['whyItMatters'] as String,
    scientificAssumptions: json['scientificAssumptions'] as String,
    isAdopted: json['isAdopted'] as bool? ?? false,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    everydayActivity,
    currentBehavior,
    recommendedAlternative,
    emissionImpactKgPerAction,
    monthlyCo2BenefitKg,
    monthlyCostBenefitUsd,
    costImplications,
    difficulty,
    whyItMatters,
    scientificAssumptions,
    isAdopted,
  ];
}
