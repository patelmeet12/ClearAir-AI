import 'package:equatable/equatable.dart';

class CommunityChallenge extends Equatable {
  final String id;
  final String title;
  final String description;
  final String durationText;
  final int participantsCount;
  final double currentCo2SavedKg;
  final double goalCo2SavedKg;
  final bool isEnrolled;
  final int daysRemaining;
  final String badgeName;
  final String practicalTip;

  const CommunityChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.durationText,
    required this.participantsCount,
    required this.currentCo2SavedKg,
    required this.goalCo2SavedKg,
    this.isEnrolled = false,
    required this.daysRemaining,
    required this.badgeName,
    required this.practicalTip,
  });

  double get progressFraction => (currentCo2SavedKg / goalCo2SavedKg).clamp(0.0, 1.0);

  CommunityChallenge copyWith({
    String? id,
    String? title,
    String? description,
    String? durationText,
    int? participantsCount,
    double? currentCo2SavedKg,
    double? goalCo2SavedKg,
    bool? isEnrolled,
    int? daysRemaining,
    String? badgeName,
    String? practicalTip,
  }) {
    return CommunityChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      durationText: durationText ?? this.durationText,
      participantsCount: participantsCount ?? this.participantsCount,
      currentCo2SavedKg: currentCo2SavedKg ?? this.currentCo2SavedKg,
      goalCo2SavedKg: goalCo2SavedKg ?? this.goalCo2SavedKg,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      daysRemaining: daysRemaining ?? this.daysRemaining,
      badgeName: badgeName ?? this.badgeName,
      practicalTip: practicalTip ?? this.practicalTip,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'durationText': durationText,
    'participantsCount': participantsCount,
    'currentCo2SavedKg': currentCo2SavedKg,
    'goalCo2SavedKg': goalCo2SavedKg,
    'isEnrolled': isEnrolled,
    'daysRemaining': daysRemaining,
    'badgeName': badgeName,
    'practicalTip': practicalTip,
  };

  factory CommunityChallenge.fromJson(Map<String, dynamic> json) => CommunityChallenge(
    id: json['id'] as String,
    title: json['title'] as String,
    description: json['description'] as String,
    durationText: json['durationText'] as String,
    participantsCount: json['participantsCount'] as int,
    currentCo2SavedKg: (json['currentCo2SavedKg'] as num).toDouble(),
    goalCo2SavedKg: (json['goalCo2SavedKg'] as num).toDouble(),
    isEnrolled: json['isEnrolled'] as bool? ?? false,
    daysRemaining: json['daysRemaining'] as int,
    badgeName: json['badgeName'] as String,
    practicalTip: json['practicalTip'] as String,
  );

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    durationText,
    participantsCount,
    currentCo2SavedKg,
    goalCo2SavedKg,
    isEnrolled,
    daysRemaining,
    badgeName,
    practicalTip,
  ];
}
