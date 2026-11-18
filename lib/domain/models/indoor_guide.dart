import 'package:equatable/equatable.dart';

enum IndoorCostTier {
  zeroCost('Zero Cost', 'Free habit modifications & sealing techniques'),
  lowCost('Low Cost (< \$30)', 'Affordable weatherstripping, N95 masks, DIY MERV filters'),
  mediumCost('Moderate (\$50 - \$200)', 'True HEPA purifier, kitchen range hood upgrades, laser particle monitor'),
  highCost('Comprehensive (> \$200)', 'Multi-room HEPA systems, whole-house ventilation with heat recovery (HRV)');

  final String label;
  final String description;
  const IndoorCostTier(this.label, this.description);
}

enum IndoorCategory {
  ventilation('Ventilation Strategy'),
  filtration('Air Filtration & HEPA'),
  combustion('Combustion & Smoke Control'),
  kitchen('Kitchen & Cooking Practices'),
  dustCleaning('Dust & Particle Cleaning'),
  monitoring('Indoor Monitoring & Maintenance');

  final String label;
  const IndoorCategory(this.label);
}

class IndoorChecklistItem extends Equatable {
  final String id;
  final String title;
  final IndoorCategory category;
  final IndoorCostTier costTier;
  final String actionDescription;
  final String scientificWhy;
  final String budgetAdvice;
  final bool isCompleted;
  final String? plantMythClarification;

  const IndoorChecklistItem({
    required this.id,
    required this.title,
    required this.category,
    required this.costTier,
    required this.actionDescription,
    required this.scientificWhy,
    required this.budgetAdvice,
    this.isCompleted = false,
    this.plantMythClarification,
  });

  IndoorChecklistItem copyWith({
    String? id,
    String? title,
    IndoorCategory? category,
    IndoorCostTier? costTier,
    String? actionDescription,
    String? scientificWhy,
    String? budgetAdvice,
    bool? isCompleted,
    String? plantMythClarification,
  }) {
    return IndoorChecklistItem(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      costTier: costTier ?? this.costTier,
      actionDescription: actionDescription ?? this.actionDescription,
      scientificWhy: scientificWhy ?? this.scientificWhy,
      budgetAdvice: budgetAdvice ?? this.budgetAdvice,
      isCompleted: isCompleted ?? this.isCompleted,
      plantMythClarification: plantMythClarification ?? this.plantMythClarification,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'category': category.name,
    'costTier': costTier.name,
    'actionDescription': actionDescription,
    'scientificWhy': scientificWhy,
    'budgetAdvice': budgetAdvice,
    'isCompleted': isCompleted,
    'plantMythClarification': plantMythClarification,
  };

  factory IndoorChecklistItem.fromJson(Map<String, dynamic> json) => IndoorChecklistItem(
    id: json['id'] as String,
    title: json['title'] as String,
    category: IndoorCategory.values.firstWhere(
      (c) => c.name == json['category'],
      orElse: () => IndoorCategory.ventilation,
    ),
    costTier: IndoorCostTier.values.firstWhere(
      (c) => c.name == json['costTier'],
      orElse: () => IndoorCostTier.zeroCost,
    ),
    actionDescription: json['actionDescription'] as String,
    scientificWhy: json['scientificWhy'] as String,
    budgetAdvice: json['budgetAdvice'] as String,
    isCompleted: json['isCompleted'] as bool? ?? false,
    plantMythClarification: json['plantMythClarification'] as String?,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    category,
    costTier,
    actionDescription,
    scientificWhy,
    budgetAdvice,
    isCompleted,
    plantMythClarification,
  ];
}
