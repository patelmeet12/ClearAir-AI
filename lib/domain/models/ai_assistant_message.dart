import 'package:equatable/equatable.dart';

class StructuredAiAdvice extends Equatable {
  final String explanation;
  final List<String> recommendedActions;
  final String whyItMatters;
  final String affordabilityEstimate;
  final String expectedBenefitAndUncertainty;
  final String sourceReference;
  final String whenToSeekMedicalAdvice;
  final bool isGenAiGenerated;

  const StructuredAiAdvice({
    required this.explanation,
    required this.recommendedActions,
    required this.whyItMatters,
    required this.affordabilityEstimate,
    required this.expectedBenefitAndUncertainty,
    required this.sourceReference,
    required this.whenToSeekMedicalAdvice,
    this.isGenAiGenerated = false,
  });

  Map<String, dynamic> toJson() => {
    'explanation': explanation,
    'recommendedActions': recommendedActions,
    'whyItMatters': whyItMatters,
    'affordabilityEstimate': affordabilityEstimate,
    'expectedBenefitAndUncertainty': expectedBenefitAndUncertainty,
    'sourceReference': sourceReference,
    'whenToSeekMedicalAdvice': whenToSeekMedicalAdvice,
    'isGenAiGenerated': isGenAiGenerated,
  };

  factory StructuredAiAdvice.fromJson(Map<String, dynamic> json) => StructuredAiAdvice(
    explanation: json['explanation'] as String,
    recommendedActions: (json['recommendedActions'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
    whyItMatters: json['whyItMatters'] as String,
    affordabilityEstimate: json['affordabilityEstimate'] as String,
    expectedBenefitAndUncertainty: json['expectedBenefitAndUncertainty'] as String,
    sourceReference: json['sourceReference'] as String,
    whenToSeekMedicalAdvice: json['whenToSeekMedicalAdvice'] as String,
    isGenAiGenerated: json['isGenAiGenerated'] as bool? ?? false,
  );

  @override
  List<Object?> get props => [
    explanation,
    recommendedActions,
    whyItMatters,
    affordabilityEstimate,
    expectedBenefitAndUncertainty,
    sourceReference,
    whenToSeekMedicalAdvice,
    isGenAiGenerated,
  ];
}

class AiAssistantMessage extends Equatable {
  final String id;
  final bool isUser;
  final String text;
  final DateTime timestamp;
  final StructuredAiAdvice? structuredAdvice;
  final bool isError;

  const AiAssistantMessage({
    required this.id,
    required this.isUser,
    required this.text,
    required this.timestamp,
    this.structuredAdvice,
    this.isError = false,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'isUser': isUser,
    'text': text,
    'timestamp': timestamp.toIso8601String(),
    'structuredAdvice': structuredAdvice?.toJson(),
    'isError': isError,
  };

  factory AiAssistantMessage.fromJson(Map<String, dynamic> json) => AiAssistantMessage(
    id: json['id'] as String,
    isUser: json['isUser'] as bool,
    text: json['text'] as String,
    timestamp: DateTime.parse(json['timestamp'] as String),
    structuredAdvice: json['structuredAdvice'] != null
        ? StructuredAiAdvice.fromJson(json['structuredAdvice'] as Map<String, dynamic>)
        : null,
    isError: json['isError'] as bool? ?? false,
  );

  @override
  List<Object?> get props => [id, isUser, text, timestamp, structuredAdvice, isError];
}
