import 'package:equatable/equatable.dart';

class AiImpactExplanation extends Equatable {
  final String actionTitle;
  final String whatChanged;
  final String exposureReduction;
  final String emissionReduction;
  final String whoBenefits;
  final String assumptionsUsed;
  final String limitationsOfEstimate;

  const AiImpactExplanation({
    required this.actionTitle,
    required this.whatChanged,
    required this.exposureReduction,
    required this.emissionReduction,
    required this.whoBenefits,
    required this.assumptionsUsed,
    required this.limitationsOfEstimate,
  });

  Map<String, dynamic> toJson() => {
    'actionTitle': actionTitle,
    'whatChanged': whatChanged,
    'exposureReduction': exposureReduction,
    'emissionReduction': emissionReduction,
    'whoBenefits': whoBenefits,
    'assumptionsUsed': assumptionsUsed,
    'limitationsOfEstimate': limitationsOfEstimate,
  };

  factory AiImpactExplanation.fromJson(Map<String, dynamic> json) => AiImpactExplanation(
    actionTitle: json['actionTitle'] as String,
    whatChanged: json['whatChanged'] as String,
    exposureReduction: json['exposureReduction'] as String,
    emissionReduction: json['emissionReduction'] as String,
    whoBenefits: json['whoBenefits'] as String,
    assumptionsUsed: json['assumptionsUsed'] as String,
    limitationsOfEstimate: json['limitationsOfEstimate'] as String,
  );

  @override
  List<Object?> get props => [
    actionTitle,
    whatChanged,
    exposureReduction,
    emissionReduction,
    whoBenefits,
    assumptionsUsed,
    limitationsOfEstimate,
  ];
}
