import 'package:flutter/material.dart';
import '../../features/expenses/domain/entities/transaction_entity.dart';

/// QuestItem — represents a gamified daily quest task.
class QuestItem {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  int progress;
  final int target;
  bool completed;

  QuestItem({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.progress,
    required this.target,
    required this.completed,
  });
}

/// FingoState — reactive state container managing all gamified stats and logs.
class FingoState extends ChangeNotifier {
  // Singleton pattern
  static final FingoState instance = FingoState._();
  FingoState._() {
    _initializeDefaults();
  }

  // User stats (Baseline clean state)
  int streak = 0;
  int xp = 0;
  final int targetXp = 50;
  int hearts = 5;
  final int maxHearts = 5;
  int level = 1;
  double monthlyBudget = 20000.0;
  double totalSpent = 0.0;

  late List<QuestItem> quests;
  late List<TransactionEntity> transactions;

  void _initializeDefaults() {
    quests = [
      QuestItem(
        id: 'q1',
        title: 'First Save',
        description: 'Log your first transaction of the week',
        xpReward: 10,
        progress: 0,
        target: 1,
        completed: false,
      ),
      QuestItem(
        id: 'q2',
        title: 'Budget Guardian',
        description: 'Keep daily expenses under ₹1,000',
        xpReward: 15,
        progress: 0,
        target: 1000,
        completed: false,
      ),
      QuestItem(
        id: 'q3',
        title: 'Consistent Tracker',
        description: 'Log 3 transactions this week',
        xpReward: 20,
        progress: 0,
        target: 3,
        completed: false,
      ),
    ];
    transactions = [];
  }

  /// Add XP and handle leveling up
  void awardXP(int amount) {
    xp += amount;
    if (xp >= targetXp) {
      xp -= targetXp;
      level++;
    }
    notifyListeners();
  }

  /// Refill user lives/hearts
  void refillHearts() {
    hearts = maxHearts;
    notifyListeners();
  }

  /// Increment streak counter
  void incrementStreak() {
    streak++;
    notifyListeners();
  }

  /// Add transaction and update daily quests
  void addTransaction({
    required String title,
    required double amount,
    required TransactionType type,
    ExpenseCategory? expenseCategory,
    IncomeCategory? incomeCategory,
    required DateTime date,
    PaymentMethod paymentMethod = PaymentMethod.cash,
    String notes = '',
  }) {
    final newTx = TransactionEntity(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      type: type,
      expenseCategory: expenseCategory,
      incomeCategory: incomeCategory,
      date: date,
      paymentMethod: paymentMethod,
      notes: notes,
    );
    transactions.insert(0, newTx);

    if (type == TransactionType.expense) {
      totalSpent += amount;

      // Update Budget Guardian Quest Progress (q2)
      final q2 = quests.firstWhere((q) => q.id == 'q2');
      final todaySpent = transactions
          .where((t) =>
              t.type == TransactionType.expense &&
              t.date.year == DateTime.now().year &&
              t.date.month == DateTime.now().month &&
              t.date.day == DateTime.now().day)
          .fold(0.0, (sum, t) => sum + t.amount);
      q2.progress = todaySpent.toInt();
      if (q2.progress > q2.target && !q2.completed) {
        if (hearts > 0) hearts--;
      }

      // Update Scholar/Consistent Tracker Quest Progress (q3)
      final q3 = quests.firstWhere((q) => q.id == 'q3');
      if (!q3.completed) {
        q3.progress++;
        if (q3.progress >= q3.target) {
          q3.completed = true;
          awardXP(q3.xpReward);
        }
      }
    }

    // Update First Save Quest (q1)
    final q1 = quests.firstWhere((q) => q.id == 'q1');
    if (!q1.completed) {
      q1.completed = true;
      awardXP(q1.xpReward);
    }

    // Basic logging award
    awardXP(5);
    notifyListeners();
  }
}
