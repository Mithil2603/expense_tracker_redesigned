class HealthScore {
  final int score;
  final int previousScore;
  final int delta;
  final String explanation;
  final List<String> positiveReasons;
  final List<String> negativeReasons;

  const HealthScore({
    required this.score,
    required this.previousScore,
    required this.delta,
    required this.explanation,
    required this.positiveReasons,
    required this.negativeReasons,
  });
}

class MoneyLeak {
  final String category;
  final double monthlyAmount;
  final double projectedYearlyCost;
  final String actionableTip;
  final double potentialMonthlySavings;
  final double potentialAnnualSavings;
  final String confidenceLevel;
  final String leakReason;

  const MoneyLeak({
    required this.category,
    required this.monthlyAmount,
    required this.projectedYearlyCost,
    required this.actionableTip,
    required this.potentialMonthlySavings,
    required this.potentialAnnualSavings,
    required this.confidenceLevel,
    required this.leakReason,
  });
}

class FinancialPersonality {
  final String name;
  final String description;
  final String finnyCoachMessage;

  const FinancialPersonality({
    required this.name,
    required this.description,
    required this.finnyCoachMessage,
  });
}

class WeeklyReview {
  final double income;
  final double expenses;
  final double savings;
  final String highestCategory;
  final String lowestCategory;
  final int healthScoreDelta;
  final String narrativeSummary;
  final List<String> majorEvents;

  const WeeklyReview({
    required this.income,
    required this.expenses,
    required this.savings,
    required this.highestCategory,
    required this.lowestCategory,
    required this.healthScoreDelta,
    required this.narrativeSummary,
    required this.majorEvents,
  });
}

class GoalPrediction {
  final double goalProgress; // 0.0 to 100.0
  final DateTime? estimatedCompletionDate;
  final String pace;
  final double recommendedContribution;
  final String earlyCompletionSuggestion;

  const GoalPrediction({
    required this.goalProgress,
    this.estimatedCompletionDate,
    required this.pace,
    required this.recommendedContribution,
    required this.earlyCompletionSuggestion,
  });
}

class FinancialIntelligence {
  final HealthScore healthScore;
  final List<MoneyLeak> moneyLeaks;
  final FinancialPersonality personality;
  final WeeklyReview weeklyReview;
  final List<String> timelineEvents;
  final GoalPrediction goalPrediction;

  const FinancialIntelligence({
    required this.healthScore,
    required this.moneyLeaks,
    required this.personality,
    required this.weeklyReview,
    required this.timelineEvents,
    required this.goalPrediction,
  });
}
