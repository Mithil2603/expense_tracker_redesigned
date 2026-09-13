import 'package:equatable/equatable.dart';
import 'quest.dart';

class QuestCompletionReward extends Equatable {
  final String questId;
  final String questTitle;
  final int xpAwarded;
  final int diamondsAwarded;
  final QuestType questType;

  const QuestCompletionReward({
    required this.questId,
    required this.questTitle,
    required this.xpAwarded,
    required this.diamondsAwarded,
    required this.questType,
  });

  Map<String, dynamic> toJson() {
    return {
      'questId': questId,
      'questTitle': questTitle,
      'xpAwarded': xpAwarded,
      'diamondsAwarded': diamondsAwarded,
      'questType': questType.name,
    };
  }

  factory QuestCompletionReward.fromJson(Map<String, dynamic> json) {
    return QuestCompletionReward(
      questId: json['questId'] as String,
      questTitle: json['questTitle'] as String,
      xpAwarded: json['xpAwarded'] as int,
      diamondsAwarded: json['diamondsAwarded'] as int,
      questType: QuestType.values.firstWhere(
        (e) => e.name == json['questType'],
        orElse: () => QuestType.daily,
      ),
    );
  }

  @override
  List<Object?> get props => [
        questId,
        questTitle,
        xpAwarded,
        diamondsAwarded,
        questType,
      ];
}
