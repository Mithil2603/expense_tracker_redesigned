enum InsightPriority { critical, important, positive, achievement }

class FinancialInsight {
  final String id;
  final InsightPriority priority;
  final String category;
  final String title;
  final String message;
  final String finnyMessage;
  final int scoreImpact;

  const FinancialInsight({
    required this.id,
    required this.priority,
    required this.category,
    required this.title,
    required this.message,
    required this.finnyMessage,
    required this.scoreImpact,
  });
}
