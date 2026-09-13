import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum QuestType { daily, weekly, monthly }

enum QuestCategory {
  checkin,
  logManual,
  reviewPending,
  underBudgetDay,
  noSpend,
  checkAnalytics,
  categorize,
  log3,
  budgetAdherence,
  noSpendDays,
  checkinStreak,
  reviewAllPending,
  savingsPositive,
  monthlyBudgetAdherence,
  noSpend10,
  savingsGoal,
  checkin20,
}

enum QuestStatus { active, completed, rewarded, expired, unavailable }

class Quest extends Equatable {
  final String id;
  final QuestType type;
  final QuestCategory category;
  final String title;
  final String description;
  final int targetValue;
  final int currentProgress;
  final QuestStatus status;
  final bool isRewarded;
  final int xpReward;
  final int diamondReward;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime? completedAt;

  const Quest({
    required this.id,
    required this.type,
    required this.category,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.currentProgress,
    required this.status,
    required this.isRewarded,
    required this.xpReward,
    required this.diamondReward,
    required this.periodStart,
    required this.periodEnd,
    this.completedAt,
  });

  bool get isCompleted =>
      status == QuestStatus.completed || status == QuestStatus.rewarded || currentProgress >= targetValue;

  Quest copyWith({
    String? id,
    QuestType? type,
    QuestCategory? category,
    String? title,
    String? description,
    int? targetValue,
    int? currentProgress,
    QuestStatus? status,
    bool? isRewarded,
    int? xpReward,
    int? diamondReward,
    DateTime? periodStart,
    DateTime? periodEnd,
    DateTime? completedAt,
  }) {
    return Quest(
      id: id ?? this.id,
      type: type ?? this.type,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      targetValue: targetValue ?? this.targetValue,
      currentProgress: currentProgress ?? this.currentProgress,
      status: status ?? this.status,
      isRewarded: isRewarded ?? this.isRewarded,
      xpReward: xpReward ?? this.xpReward,
      diamondReward: diamondReward ?? this.diamondReward,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type.name,
      'category': category.name,
      'title': title,
      'description': description,
      'targetValue': targetValue,
      'currentProgress': currentProgress,
      'status': status.name,
      'isRewarded': isRewarded,
      'xpReward': xpReward,
      'diamondReward': diamondReward,
      'periodStart': periodStart.toUtc().toIso8601String(),
      'periodEnd': periodEnd.toUtc().toIso8601String(),
      'completedAt': completedAt?.toUtc().toIso8601String(),
    };
  }

  factory Quest.fromJson(Map<String, dynamic> json) {
    return Quest(
      id: json['id'] as String,
      type: QuestType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => QuestType.daily,
      ),
      category: QuestCategory.values.firstWhere(
        (e) => e.name == json['category'],
        orElse: () => QuestCategory.checkin,
      ),
      title: json['title'] as String,
      description: json['description'] as String,
      targetValue: json['targetValue'] as int,
      currentProgress: json['currentProgress'] as int,
      status: QuestStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => QuestStatus.active,
      ),
      isRewarded: json['isRewarded'] as bool? ?? false,
      xpReward: json['xpReward'] as int,
      diamondReward: json['diamondReward'] as int,
      periodStart: DateTime.parse(json['periodStart'] as String).toLocal(),
      periodEnd: DateTime.parse(json['periodEnd'] as String).toLocal(),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String).toLocal()
          : null,
    );
  }

  factory Quest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Quest.fromJson({...data, 'id': doc.id});
  }

  @override
  List<Object?> get props => [
        id,
        type,
        category,
        title,
        description,
        targetValue,
        currentProgress,
        status,
        isRewarded,
        xpReward,
        diamondReward,
        periodStart,
        periodEnd,
        completedAt,
      ];
}
