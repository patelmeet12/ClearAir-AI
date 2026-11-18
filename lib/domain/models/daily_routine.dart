import 'package:equatable/equatable.dart';

enum RoutineTimeSlot {
  morning('Morning', '6:00 AM - 12:00 PM'),
  afternoon('Afternoon', '12:00 PM - 5:00 PM'),
  evening('Evening', '5:00 PM - 9:00 PM'),
  night('Night', '9:00 PM - 6:00 AM');

  final String label;
  final String timeRange;
  const RoutineTimeSlot(this.label, this.timeRange);
}

enum RoutinePriority {
  high('High Priority', 'Immediate protective or emission benefit'),
  medium('Medium Priority', 'Recommended optimization'),
  low('Low Priority', 'Optional improvement');

  final String label;
  final String description;
  const RoutinePriority(this.label, this.description);
}

class RoutineItem extends Equatable {
  final String id;
  final String title;
  final RoutineTimeSlot timeSlot;
  final RoutinePriority priority;
  final String suggestedTime;
  final String reason;
  final String estimatedCost;
  final String convenience;
  final String exposureReduction;
  final String environmentalBenefit;
  final bool isCompleted;
  final double co2AvoidedKg;
  final double fuelSavedLiters;
  final double costSavedUsd;

  const RoutineItem({
    required this.id,
    required this.title,
    required this.timeSlot,
    required this.priority,
    required this.suggestedTime,
    required this.reason,
    required this.estimatedCost,
    required this.convenience,
    required this.exposureReduction,
    required this.environmentalBenefit,
    this.isCompleted = false,
    this.co2AvoidedKg = 0.0,
    this.fuelSavedLiters = 0.0,
    this.costSavedUsd = 0.0,
  });

  RoutineItem copyWith({
    String? id,
    String? title,
    RoutineTimeSlot? timeSlot,
    RoutinePriority? priority,
    String? suggestedTime,
    String? reason,
    String? estimatedCost,
    String? convenience,
    String? exposureReduction,
    String? environmentalBenefit,
    bool? isCompleted,
    double? co2AvoidedKg,
    double? fuelSavedLiters,
    double? costSavedUsd,
  }) {
    return RoutineItem(
      id: id ?? this.id,
      title: title ?? this.title,
      timeSlot: timeSlot ?? this.timeSlot,
      priority: priority ?? this.priority,
      suggestedTime: suggestedTime ?? this.suggestedTime,
      reason: reason ?? this.reason,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      convenience: convenience ?? this.convenience,
      exposureReduction: exposureReduction ?? this.exposureReduction,
      environmentalBenefit: environmentalBenefit ?? this.environmentalBenefit,
      isCompleted: isCompleted ?? this.isCompleted,
      co2AvoidedKg: co2AvoidedKg ?? this.co2AvoidedKg,
      fuelSavedLiters: fuelSavedLiters ?? this.fuelSavedLiters,
      costSavedUsd: costSavedUsd ?? this.costSavedUsd,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'timeSlot': timeSlot.name,
    'priority': priority.name,
    'suggestedTime': suggestedTime,
    'reason': reason,
    'estimatedCost': estimatedCost,
    'convenience': convenience,
    'exposureReduction': exposureReduction,
    'environmentalBenefit': environmentalBenefit,
    'isCompleted': isCompleted,
    'co2AvoidedKg': co2AvoidedKg,
    'fuelSavedLiters': fuelSavedLiters,
    'costSavedUsd': costSavedUsd,
  };

  factory RoutineItem.fromJson(Map<String, dynamic> json) => RoutineItem(
    id: json['id'] as String,
    title: json['title'] as String,
    timeSlot: RoutineTimeSlot.values.firstWhere(
      (t) => t.name == json['timeSlot'],
      orElse: () => RoutineTimeSlot.morning,
    ),
    priority: RoutinePriority.values.firstWhere(
      (p) => p.name == json['priority'],
      orElse: () => RoutinePriority.medium,
    ),
    suggestedTime: json['suggestedTime'] as String,
    reason: json['reason'] as String,
    estimatedCost: json['estimatedCost'] as String,
    convenience: json['convenience'] as String,
    exposureReduction: json['exposureReduction'] as String,
    environmentalBenefit: json['environmentalBenefit'] as String,
    isCompleted: json['isCompleted'] as bool? ?? false,
    co2AvoidedKg: (json['co2AvoidedKg'] as num?)?.toDouble() ?? 0.0,
    fuelSavedLiters: (json['fuelSavedLiters'] as num?)?.toDouble() ?? 0.0,
    costSavedUsd: (json['costSavedUsd'] as num?)?.toDouble() ?? 0.0,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    timeSlot,
    priority,
    suggestedTime,
    reason,
    estimatedCost,
    convenience,
    exposureReduction,
    environmentalBenefit,
    isCompleted,
    co2AvoidedKg,
    fuelSavedLiters,
    costSavedUsd,
  ];
}
