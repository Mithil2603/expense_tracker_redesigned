import 'dart:math';
import '../../domain/entities/quest.dart';
import 'quest_period_manager.dart';

class QuestDefinition {
  final QuestCategory category;
  final QuestType type;
  final String title;
  final String description;
  final int targetValue;
  final int xpReward;
  final int diamondReward;
  final int minLevel;
  final bool requiresBudget;

  const QuestDefinition({
    required this.category,
    required this.type,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.xpReward,
    required this.diamondReward,
    required this.minLevel,
    this.requiresBudget = false,
  });
}

class QuestCatalogue {
  static const List<QuestDefinition> _allDefinitions = [
    // ── Daily Quests (8) ──────────────────────────────────────────────────
    QuestDefinition(
      category: QuestCategory.checkin,
      type: QuestType.daily,
      title: 'Daily Check-in',
      description: 'Open the app today',
      targetValue: 1,
      xpReward: 10,
      diamondReward: 2,
      minLevel: 1,
    ),
    QuestDefinition(
      category: QuestCategory.logManual,
      type: QuestType.daily,
      title: 'Manual Tracker',
      description: 'Manually log a transaction',
      targetValue: 1,
      xpReward: 15,
      diamondReward: 3,
      minLevel: 1,
    ),
    QuestDefinition(
      category: QuestCategory.log3,
      type: QuestType.daily,
      title: 'Active Logger',
      description: 'Log 3 or more transactions today',
      targetValue: 3,
      xpReward: 25,
      diamondReward: 5,
      minLevel: 1,
    ),
    QuestDefinition(
      category: QuestCategory.reviewPending,
      type: QuestType.daily,
      title: 'Inbox Zero',
      description: 'Review a pending auto-detected transaction',
      targetValue: 1,
      xpReward: 20,
      diamondReward: 5,
      minLevel: 4,
    ),
    QuestDefinition(
      category: QuestCategory.checkAnalytics,
      type: QuestType.daily,
      title: 'Number Cruncher',
      description: 'Open the Analytics screen',
      targetValue: 1,
      xpReward: 10,
      diamondReward: 2,
      minLevel: 4,
    ),
    QuestDefinition(
      category: QuestCategory.categorize,
      type: QuestType.daily,
      title: 'Neat & Tidy',
      description: 'Ensure all today\'s transactions have a category',
      targetValue: 1,
      xpReward: 20,
      diamondReward: 5,
      minLevel: 4,
    ),
    QuestDefinition(
      category: QuestCategory.underBudgetDay,
      type: QuestType.daily,
      title: 'Budget Guardian',
      description: 'Keep today\'s spending under your daily budget',
      targetValue: 1,
      xpReward: 25,
      diamondReward: 5,
      minLevel: 7,
      requiresBudget: true,
    ),
    QuestDefinition(
      category: QuestCategory.noSpend,
      type: QuestType.daily,
      title: 'Zero Spend Day',
      description: 'Don\'t log any expense today (income only or zero)',
      targetValue: 1,
      xpReward: 30,
      diamondReward: 8,
      minLevel: 7,
    ),

    // ── Weekly Quests (5) ─────────────────────────────────────────────────
    QuestDefinition(
      category: QuestCategory.checkinStreak,
      type: QuestType.weekly,
      title: 'Weekly Regular',
      description: 'Open the app on 5+ distinct days this week',
      targetValue: 5,
      xpReward: 60,
      diamondReward: 30,
      minLevel: 1,
    ),
    QuestDefinition(
      category: QuestCategory.noSpendDays,
      type: QuestType.weekly,
      title: 'Frugal Week',
      description: 'Have 2+ no-spend days this week',
      targetValue: 2,
      xpReward: 80,
      diamondReward: 40,
      minLevel: 4,
    ),
    QuestDefinition(
      category: QuestCategory.reviewAllPending,
      type: QuestType.weekly,
      title: 'Clear the Decks',
      description: 'Clear all pending transaction reviews',
      targetValue: 1,
      xpReward: 70,
      diamondReward: 35,
      minLevel: 4,
    ),
    QuestDefinition(
      category: QuestCategory.budgetAdherence,
      type: QuestType.weekly,
      title: 'Weekly Master',
      description: 'Stay under total weekly budget',
      targetValue: 1,
      xpReward: 100,
      diamondReward: 50,
      minLevel: 7,
      requiresBudget: true,
    ),
    QuestDefinition(
      category: QuestCategory.savingsPositive,
      type: QuestType.weekly,
      title: 'In the Green',
      description: 'End the week with positive savings (income > expenses)',
      targetValue: 1,
      xpReward: 100,
      diamondReward: 50,
      minLevel: 7,
    ),

    // ── Monthly Quests (4) ────────────────────────────────────────────────
    QuestDefinition(
      category: QuestCategory.checkin20,
      type: QuestType.monthly,
      title: 'Monthly Devotion',
      description: 'Open the app on 20+ distinct days this month',
      targetValue: 20,
      xpReward: 200,
      diamondReward: 100,
      minLevel: 1,
    ),
    QuestDefinition(
      category: QuestCategory.noSpend10,
      type: QuestType.monthly,
      title: 'Savings Champion',
      description: 'Achieve 10+ no-spend days this month',
      targetValue: 10,
      xpReward: 250,
      diamondReward: 150,
      minLevel: 4,
    ),
    QuestDefinition(
      category: QuestCategory.savingsGoal,
      type: QuestType.monthly,
      title: 'Future Focused',
      description: 'Contribute to a savings goal at least once',
      targetValue: 1,
      xpReward: 200,
      diamondReward: 120,
      minLevel: 4,
    ),
    QuestDefinition(
      category: QuestCategory.monthlyBudgetAdherence,
      type: QuestType.monthly,
      title: 'Budget Legend',
      description: 'Stay under total monthly budget',
      targetValue: 1,
      xpReward: 300,
      diamondReward: 200,
      minLevel: 7,
      requiresBudget: true,
    ),
  ];

  static List<Quest> generateQuestsForPeriod({
    required QuestType type,
    required int userLevel,
    required double monthlyBudget,
    required DateTime periodStart,
    required DateTime periodEnd,
  }) {
    // Filter pool by level and budget requirements
    final eligible = _allDefinitions.where((def) {
      if (def.type != type) return false;
      if (def.minLevel > userLevel && userLevel > 0) return false;
      if (def.requiresBudget && monthlyBudget <= 0.0) return false;
      return true;
    }).toList();

    // Determine target count
    int targetCount;
    switch (type) {
      case QuestType.daily:
        targetCount = 5;
        break;
      case QuestType.weekly:
        targetCount = 3;
        break;
      case QuestType.monthly:
        targetCount = 2;
        break;
    }

    // Shuffle deterministically by periodStart so all users/devices get consistent random selection for the period
    final seed = periodStart.year * 10000 + periodStart.month * 100 + periodStart.day + type.index;
    final random = Random(seed);
    eligible.shuffle(random);

    final selected = eligible.take(targetCount).toList();

    return selected.map((def) {
      final id = QuestPeriodManager.generateQuestId(def.category, periodStart);
      return Quest(
        id: id,
        type: def.type,
        category: def.category,
        title: def.title,
        description: def.description,
        targetValue: def.targetValue,
        currentProgress: 0,
        status: QuestStatus.active,
        isRewarded: false,
        xpReward: def.xpReward,
        diamondReward: def.diamondReward,
        periodStart: periodStart,
        periodEnd: periodEnd,
      );
    }).toList();
  }
}
