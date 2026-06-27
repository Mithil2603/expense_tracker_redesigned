import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../../features/expenses/domain/entities/transaction_entity.dart';
import '../../features/community/domain/entities/social_post_entity.dart';

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
  int health = 25;
  final int maxHealth = 25;
  int level = 1;
  double monthlyBudget = 20000.0;
  double totalSpent = 0.0;

  late List<QuestItem> quests;
  late List<TransactionEntity> transactions;
  late List<SocialPostEntity> feedItems;

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
    feedItems = [
      SocialPostEntity(
        userName: 'Sarah Jones',
        avatar: '🥑',
        content:
            'Kept my daily food budget under ₹150 for 4 consecutive days! 🔥',
        timeAgo: '15 mins ago',
        isAchievement: true,
        likes: 12,
      ),
      SocialPostEntity(
        userName: 'Rahul Verma',
        avatar: '💻',
        content:
            'Any tips to reduce high electricity utilities this summer? My bills are shooting up.',
        timeAgo: '1 hr ago',
        likes: 5,
      ),
      SocialPostEntity(
        userName: 'Jessica Miller',
        avatar: '🌟',
        content: 'Levelled up to Level 2! Fingo rules! ⭐',
        timeAgo: '3 hrs ago',
        isAchievement: true,
        likes: 24,
      ),
      SocialPostEntity(
        userName: 'David Miller',
        avatar: '🚗',
        content: 'Saved ₹2,500 on transportation this week by carpooling! 💰🚘',
        timeAgo: '5 hrs ago',
        isAchievement: true,
        likes: 18,
      ),
    ];
  }

  /// Add XP and handle leveling up
  void awardXP(int amount) {
    xp += amount;
    if (xp >= targetXp) {
      xp -= targetXp;
      level++;
    }
    _saveStats();
    notifyListeners();
  }

  /// Refill user health
  void refillHealth() {
    health = maxHealth;
    _saveStats();
    notifyListeners();
  }

  /// Deduct health
  void deductHealth(int amount) {
    health -= amount;
    if (health < 0) health = 0;
    _saveStats();
    notifyListeners();
  }

  /// Increment streak counter
  void incrementStreak() {
    streak++;
    _saveStats();
    notifyListeners();
  }

  /// Helper to write user stats to secure storage
  Future<void> _saveStats() async {
    try {
      final storage = GetIt.instance<FlutterSecureStorage>();
      await storage.write(key: 'fingo_streak', value: streak.toString());
      await storage.write(key: 'fingo_xp', value: xp.toString());
      await storage.write(key: 'fingo_level', value: level.toString());
      await storage.write(key: 'fingo_health', value: health.toString());
      await storage.write(key: 'fingo_monthly_budget', value: monthlyBudget.toString());
    } catch (_) {}
  }

  /// Helper to record completed quest ID to prevent repeated rewards
  Future<void> _markQuestCompleted(String questId) async {
    try {
      final storage = GetIt.instance<FlutterSecureStorage>();
      final completedStr = await storage.read(key: _keyCompletedQuests) ?? '';
      final completedIds = completedStr.split(',').where((id) => id.isNotEmpty).toList();
      if (!completedIds.contains(questId)) {
        completedIds.add(questId);
        await storage.write(key: _keyCompletedQuests, value: completedIds.join(','));
      }
    } catch (_) {}
  }

  static const String _keyCompletedQuests = 'fingo_completed_quests';
  static const String _keyQuestsLastReset = 'fingo_quests_last_reset';

  /// Asynchronously load stats from secure storage on startup
  Future<void> loadStats() async {
    try {
      final storage = GetIt.instance<FlutterSecureStorage>();
      final sStr = await storage.read(key: 'fingo_streak');
      final xStr = await storage.read(key: 'fingo_xp');
      final lStr = await storage.read(key: 'fingo_level');
      final hStr = await storage.read(key: 'fingo_health');
      final bStr = await storage.read(key: 'fingo_monthly_budget');

      if (sStr != null) streak = int.tryParse(sStr) ?? streak;
      if (xStr != null) xp = int.tryParse(xStr) ?? xp;
      if (lStr != null) level = int.tryParse(lStr) ?? level;
      if (hStr != null) health = int.tryParse(hStr) ?? health;
      if (bStr != null) monthlyBudget = double.tryParse(bStr) ?? monthlyBudget;

      // Quest Reset / Restoration Logic
      final resetStr = await storage.read(key: _keyQuestsLastReset);
      final todayStr = DateTime.now().toIso8601String().substring(0, 10);
      if (resetStr != todayStr) {
        await storage.write(key: _keyQuestsLastReset, value: todayStr);
        await storage.write(key: _keyCompletedQuests, value: '');
      } else {
        final completedStr = await storage.read(key: _keyCompletedQuests) ?? '';
        final completedIds = completedStr.split(',').where((id) => id.isNotEmpty).toList();
        for (final id in completedIds) {
          final q = quests.firstWhere((quest) => quest.id == id, orElse: () => quests.first);
          q.completed = true;
          q.progress = q.target;
        }
      }

      notifyListeners();
    } catch (_) {}
  }

  /// Syncs in-memory data and quests with the list of transactions fetched from Firestore.
  void syncWithTransactions(List<TransactionEntity> newList) {
    transactions = List.from(newList);

    // 1. Calculate totalSpent dynamically based on current transactions
    totalSpent = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    // 2. Update quests progress based on current transactions
    final today = DateTime.now();

    // Quest 1: First Save (Log your first transaction of the week)
    final q1 = quests.firstWhere((q) => q.id == 'q1');
    if (!q1.completed && transactions.isNotEmpty) {
      q1.completed = true;
      q1.progress = 1;
      _markQuestCompleted('q1');
      awardXP(q1.xpReward);
    }

    // Quest 2: Budget Guardian (Keep daily expenses under ₹1,000)
    final q2 = quests.firstWhere((q) => q.id == 'q2');
    final todaySpent = transactions
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.year == today.year &&
            t.date.month == today.month &&
            t.date.day == today.day)
        .fold(0.0, (sum, t) => sum + t.amount);
    q2.progress = todaySpent.toInt();
    if (q2.progress > q2.target && !q2.completed) {
      // Deduct health once if over daily budget limit
      q2.completed = true; // Mark as completed for the day to prevent repeated deduction
      _markQuestCompleted('q2');
      if (health > 0) {
        health = (health - 5).clamp(0, maxHealth);
        _saveStats();
      }
    }

    // Quest 3: Consistent Tracker (Log 3 transactions this week)
    final q3 = quests.firstWhere((q) => q.id == 'q3');
    if (!q3.completed) {
      // Find transactions from the last 7 days
      final thisWeekCount = transactions.where((t) {
        final diff = today.difference(t.date).inDays;
        return diff >= 0 && diff < 7;
      }).length;
      q3.progress = thisWeekCount;
      if (q3.progress >= q3.target) {
        q3.completed = true;
        _markQuestCompleted('q3');
        awardXP(q3.xpReward);
      }
    }

    notifyListeners();
  }

  /// Add transaction locally (maintained for backward compatibility if needed)
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
      userId: 'test-user-id',
      title: title,
      amount: amount,
      type: type,
      expenseCategory: expenseCategory,
      incomeCategory: incomeCategory,
      date: date,
      paymentMethod: paymentMethod,
      notes: notes,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isRecurring: false,
      recurringId: null,
      processedForXp: false,
    );
    transactions.insert(0, newTx);
    syncWithTransactions(transactions);
  }

  /// Complete or progress a quest and award XP
  void completeQuest(String questId) {
    final quest = quests.firstWhere((q) => q.id == questId);
    if (quest.completed) return;

    if (quest.id == 'q3') {
      quest.progress++;
      if (quest.progress >= quest.target) {
        quest.completed = true;
        _markQuestCompleted('q3');
        awardXP(quest.xpReward);
      }
    } else {
      quest.completed = true;
      _markQuestCompleted(questId);
      awardXP(quest.xpReward);
    }
    notifyListeners();
  }

  /// Add a social post
  void addSocialPost(String content) {
    feedItems.insert(
      0,
      SocialPostEntity(
        userName: 'Mithil (You)',
        avatar: '🪙',
        content: content,
        timeAgo: 'Just now',
        likes: 0,
      ),
    );
    notifyListeners();
  }

  /// Toggle like state of a social post
  void toggleLikePost(SocialPostEntity post) {
    if (post.isLiked) {
      post.likes--;
      post.isLiked = false;
    } else {
      post.likes++;
      post.isLiked = true;
    }
    notifyListeners();
  }

  /// Reset user stats and logs to baseline values
  void reset() {
    streak = 0;
    xp = 0;
    health = 25;
    level = 1;
    monthlyBudget = 20000.0;
    totalSpent = 0.0;
    _initializeDefaults();
    _saveStats();
    notifyListeners();
  }
}

