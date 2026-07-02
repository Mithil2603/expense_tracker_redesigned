import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import '../../features/expenses/domain/entities/transaction_entity.dart';
import '../../features/community/domain/entities/social_post_entity.dart';

// ─── Reward System Constants (tunable in one place) ──────────────────────────
const int kDailyStreakRewardDiamonds  = 10;
const int kWeeklyRewardDiamonds       = 50;
const int kMonthlyRewardDiamonds      = 200;

/// Which reward tier just fired.
enum RewardType { daily, weekly, monthly }

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
  int diamonds = 0;
  final int targetXp = 50;
  int health = 25;
  final int maxHealth = 25;
  int level = 1;
  double monthlyBudget = 20000.0;
  double totalSpent = 0.0;

  /// Rewards that have been earned but not yet shown to the user.
  /// Persisted across app kills so the celebration screen re-shows on next open.
  List<RewardType> pendingRewards = [];

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
    feedItems = [];
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

  /// Add Diamonds
  void awardDiamonds(int amount) {
    diamonds += amount;
    _saveStats();
    notifyListeners();
  }

  /// Deduct Diamonds
  void deductDiamonds(int amount) {
    diamonds -= amount;
    if (diamonds < 0) diamonds = 0;
    _saveStats();
    notifyListeners();
  }

  /// Refill user health
  void refillHealth(int amount) {
    health += amount;
    if (health > maxHealth) health = maxHealth;
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

  /// Increment streak counter directly
  void incrementStreak() {
    streak++;
    _saveStats();
    notifyListeners();
  }

  // ─── Persistence Keys ─────────────────────────────────────────────────────

  static const String _keyCompletedQuests      = 'fingo_completed_quests';
  static const String _keyQuestsLastReset       = 'fingo_quests_last_reset';
  static const String _keyHealthLastReset       = 'fingo_health_last_reset';
  static const String _keyLastStreakRewardDate  = 'fingo_last_streak_reward_date';
  static const String _keyWeeklyRewardWeek      = 'fingo_weekly_reward_week';
  static const String _keyMonthlyRewardMonth    = 'fingo_monthly_reward_month';
  static const String _keyPendingRewards        = 'fingo_pending_rewards';

  // ─── Storage helpers ──────────────────────────────────────────────────────

  FlutterSecureStorage get _storage => GetIt.instance<FlutterSecureStorage>();

  Future<void> _saveStats() async {
    try {
      await _storage.write(key: 'fingo_streak',         value: streak.toString());
      await _storage.write(key: 'fingo_xp',             value: xp.toString());
      await _storage.write(key: 'fingo_diamonds',       value: diamonds.toString());
      await _storage.write(key: 'fingo_level',          value: level.toString());
      await _storage.write(key: 'fingo_health',         value: health.toString());
      await _storage.write(key: 'fingo_monthly_budget', value: monthlyBudget.toString());
    } catch (_) {}
  }

  Future<void> _markQuestCompleted(String questId) async {
    try {
      final completedStr = await _storage.read(key: _keyCompletedQuests) ?? '';
      final completedIds = completedStr.split(',').where((id) => id.isNotEmpty).toList();
      if (!completedIds.contains(questId)) {
        completedIds.add(questId);
        await _storage.write(key: _keyCompletedQuests, value: completedIds.join(','));
      }
    } catch (_) {}
  }

  Future<void> _savePendingRewards() async {
    try {
      final value = pendingRewards.map((r) => r.name).join(',');
      await _storage.write(key: _keyPendingRewards, value: value);
    } catch (_) {}
  }

  // ─── loadStats ────────────────────────────────────────────────────────────

  Future<void> loadStats() async {
    try {
      final sStr  = await _storage.read(key: 'fingo_streak');
      final xStr  = await _storage.read(key: 'fingo_xp');
      final dStr  = await _storage.read(key: 'fingo_diamonds');
      final lStr  = await _storage.read(key: 'fingo_level');
      final hStr  = await _storage.read(key: 'fingo_health');
      final bStr  = await _storage.read(key: 'fingo_monthly_budget');

      if (sStr != null) streak         = int.tryParse(sStr) ?? streak;
      if (xStr != null) xp             = int.tryParse(xStr) ?? xp;
      if (dStr != null) diamonds       = int.tryParse(dStr) ?? diamonds;
      if (lStr != null) level          = int.tryParse(lStr) ?? level;
      if (hStr != null) health         = int.tryParse(hStr) ?? health;
      if (bStr != null) monthlyBudget  = double.tryParse(bStr) ?? monthlyBudget;

      final todayStr = _todayStr();

      // Daily Health Reset
      final hResetStr = await _storage.read(key: _keyHealthLastReset);
      if (hResetStr != todayStr) {
        health = maxHealth;
        await _storage.write(key: _keyHealthLastReset, value: todayStr);
        await _saveStats();
      }

      // Quest Reset / Restoration
      final resetStr = await _storage.read(key: _keyQuestsLastReset);
      if (resetStr != todayStr) {
        await _storage.write(key: _keyQuestsLastReset, value: todayStr);
        await _storage.write(key: _keyCompletedQuests, value: '');
      } else {
        final completedStr = await _storage.read(key: _keyCompletedQuests) ?? '';
        final completedIds = completedStr.split(',').where((id) => id.isNotEmpty).toList();
        for (final id in completedIds) {
          final q = quests.firstWhere((quest) => quest.id == id, orElse: () => quests.first);
          q.completed = true;
          q.progress = q.target;
        }
      }

      // Restore pending rewards (survive app kill)
      final pendingStr = await _storage.read(key: _keyPendingRewards) ?? '';
      pendingRewards = pendingStr
          .split(',')
          .where((s) => s.isNotEmpty)
          .map((s) {
            try { return RewardType.values.byName(s); } catch (_) { return null; }
          })
          .whereType<RewardType>()
          .toList();

      // Daily check-in reward (app open = streak check-in)
      await _checkDailyCheckIn();

      notifyListeners();
    } catch (_) {}
  }

  // ─── Daily Check-in Reward ───────────────────────────────────────────────

  /// Called once per app open (inside loadStats). 
  /// Awards [kDailyStreakRewardDiamonds] the FIRST time the user opens the app
  /// on any calendar day. Uses a persisted date flag — never fires twice the same day.
  Future<void> _checkDailyCheckIn() async {
    try {
      final todayStr = _todayStr();
      final lastRewardDate = await _storage.read(key: _keyLastStreakRewardDate);
      if (lastRewardDate == todayStr) return; // Already rewarded today

      // Award immediately (survives app kill — diamonds are credited before screen shows)
      diamonds += kDailyStreakRewardDiamonds;
      await _saveStats();
      await _storage.write(key: _keyLastStreakRewardDate, value: todayStr);

      // Queue celebration screen
      if (!pendingRewards.contains(RewardType.daily)) {
        pendingRewards.add(RewardType.daily);
        await _savePendingRewards();
      }
    } catch (_) {}
  }

  // ─── Budget Adherence Rewards (Weekly / Monthly) ─────────────────────────

  /// Called from syncWithTransactions. Evaluates end-of-period budget adherence.
  /// Weekly: evaluated on first app open of a new ISO week (checks the just-completed week).
  /// Monthly: evaluated on first app open of a new calendar month (checks last month).
  Future<void> _checkBudgetRewards(List<TransactionEntity> txs) async {
    await _checkWeeklyBudget(txs);
    await _checkMonthlyBudget(txs);
  }

  Future<void> _checkWeeklyBudget(List<TransactionEntity> txs) async {
    try {
      final now = DateTime.now();
      final thisMonday = _mondayOfWeek(now);
      // Only evaluate at the start of a new week (i.e. we can now look at last week)
      final lastMonday = thisMonday.subtract(const Duration(days: 7));
      final lastWeekKey = _dateStr(lastMonday);

      final lastRewarded = await _storage.read(key: _keyWeeklyRewardWeek);
      if (lastRewarded == lastWeekKey) return; // Already checked this past week

      // Compute last week's spending
      final weeklyBudget = monthlyBudget / 4.33;
      final lastWeekSpend = _spendInRange(txs, lastMonday,
          lastMonday.add(const Duration(days: 6)));

      await _storage.write(key: _keyWeeklyRewardWeek, value: lastWeekKey);

      if (lastWeekSpend <= weeklyBudget) {
        // Under budget — award!
        diamonds += kWeeklyRewardDiamonds;
        await _saveStats();
        if (!pendingRewards.contains(RewardType.weekly)) {
          pendingRewards.add(RewardType.weekly);
          await _savePendingRewards();
        }
      }
    } catch (_) {}
  }

  Future<void> _checkMonthlyBudget(List<TransactionEntity> txs) async {
    try {
      final now = DateTime.now();
      // Only check on day 1+ of a new month — look at the previous month
      final prevMonth      = now.month == 1 ? 12 : now.month - 1;
      final prevMonthYear  = now.month == 1 ? now.year - 1 : now.year;
      final lastMonthKey   = '$prevMonthYear-${prevMonth.toString().padLeft(2, '0')}';

      final lastRewarded = await _storage.read(key: _keyMonthlyRewardMonth);
      if (lastRewarded == lastMonthKey) return; // Already checked last month

      // Only evaluate if we've actually crossed into a new month
      final lastEvaluatedMonth = await _storage.read(key: '_fingo_month_eval_guard');
      final thisMonthKey = '${now.year}-${now.month.toString().padLeft(2, '0')}';
      if (lastEvaluatedMonth == thisMonthKey && lastRewarded != lastMonthKey) {
        // We've already run this month's evaluation, no new month yet
      }
      // Guard: only run when current month != last month we evaluated
      if (lastEvaluatedMonth == thisMonthKey) return;
      await _storage.write(key: '_fingo_month_eval_guard', value: thisMonthKey);

      final monthSpend = _spendInMonth(txs, prevMonthYear, prevMonth);
      await _storage.write(key: _keyMonthlyRewardMonth, value: lastMonthKey);

      if (monthSpend <= monthlyBudget) {
        diamonds += kMonthlyRewardDiamonds;
        await _saveStats();
        if (!pendingRewards.contains(RewardType.monthly)) {
          pendingRewards.add(RewardType.monthly);
          await _savePendingRewards();
        }
      }
    } catch (_) {}
  }

  /// Dismiss a reward screen and remove the reward from the pending queue.
  void clearPendingReward(RewardType type) {
    pendingRewards.remove(type);
    _savePendingRewards();
    notifyListeners();
  }

  // ─── Date/spending utilities ──────────────────────────────────────────────

  String _todayStr() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  String _dateStr(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DateTime _mondayOfWeek(DateTime date) =>
      date.subtract(Duration(days: date.weekday - 1));

  double _spendInRange(List<TransactionEntity> txs, DateTime from, DateTime to) {
    final fromDay = DateTime(from.year, from.month, from.day);
    final toDay   = DateTime(to.year, to.month, to.day, 23, 59, 59);
    return txs
        .where((t) =>
            t.type == TransactionType.expense &&
            !t.date.isBefore(fromDay) &&
            !t.date.isAfter(toDay))
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  double _spendInMonth(List<TransactionEntity> txs, int year, int month) {
    return txs
        .where((t) =>
            t.type == TransactionType.expense &&
            t.date.year == year &&
            t.date.month == month)
        .fold(0.0, (sum, t) => sum + t.amount);
  }

  // ─── syncWithTransactions ────────────────────────────────────────────────

  void syncWithTransactions(List<TransactionEntity> newList) {
    transactions = List.from(newList);

    totalSpent = transactions
        .where((t) => t.type == TransactionType.expense)
        .fold(0.0, (sum, t) => sum + t.amount);

    _calculateStreakFromTransactions();
    _generateMilestoneFeed();

    final today = DateTime.now();

    // Quest 1: First Save
    final q1 = quests.firstWhere((q) => q.id == 'q1');
    if (!q1.completed && transactions.isNotEmpty) {
      q1.completed = true;
      q1.progress = 1;
      _markQuestCompleted('q1');
      awardXP(q1.xpReward);
      awardDiamonds(q1.xpReward);
    }

    // Quest 2: Budget Guardian
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
      q2.completed = true;
      _markQuestCompleted('q2');
      if (health > 0) {
        health = (health - 5).clamp(0, maxHealth);
        _saveStats();
      }
    }

    // Quest 3: Consistent Tracker
    final q3 = quests.firstWhere((q) => q.id == 'q3');
    if (!q3.completed) {
      final thisWeekCount = transactions.where((t) {
        final diff = today.difference(t.date).inDays;
        return diff >= 0 && diff < 7;
      }).length;
      q3.progress = thisWeekCount;
      if (q3.progress >= q3.target) {
        q3.completed = true;
        _markQuestCompleted('q3');
        awardXP(q3.xpReward);
        awardDiamonds(q3.xpReward);
      }
    }

    // Budget adherence rewards (weekly/monthly end-of-period checks)
    _checkBudgetRewards(transactions);

    notifyListeners();
  }

  void _calculateStreakFromTransactions() {
    if (transactions.isEmpty) {
      streak = 0;
      return;
    }

    final activeDates = transactions.map((t) {
      return DateTime(t.date.year, t.date.month, t.date.day);
    }).toSet().toList();

    activeDates.sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayDate     = DateTime(today.year, today.month, today.day);
    final yesterdayDate = todayDate.subtract(const Duration(days: 1));

    if (!activeDates.contains(todayDate) && !activeDates.contains(yesterdayDate)) {
      streak = 0;
      return;
    }

    int currentStreak = 0;
    DateTime checkDate = activeDates.contains(todayDate) ? todayDate : yesterdayDate;

    for (final date in activeDates) {
      if (date.isAtSameMomentAs(checkDate)) {
        currentStreak++;
        checkDate = checkDate.subtract(const Duration(days: 1));
      } else if (date.isBefore(checkDate)) {
        break;
      }
    }

    streak = currentStreak;
    _saveStats();
  }

  void _generateMilestoneFeed() {
    final List<SocialPostEntity> newFeed = [];

    if (transactions.isNotEmpty) {
      newFeed.add(SocialPostEntity(
        userName: 'Mithil (You)',
        avatar: '🎉',
        content: 'Logged my first transaction and started my financial journey!',
        timeAgo: 'First Step',
        isAchievement: true,
        likes: 1,
      ));
    }

    if (streak >= 3) {
      newFeed.insert(0, SocialPostEntity(
        userName: 'Mithil (You)',
        avatar: '🔥',
        content: 'Hit a $streak day tracking streak! Consistency is key.',
        timeAgo: 'Recently',
        isAchievement: true,
        likes: 3,
      ));
    }

    if (level >= 2) {
      newFeed.insert(0, SocialPostEntity(
        userName: 'Mithil (You)',
        avatar: '⭐',
        content: 'Reached Level $level! Levelling up my money habits.',
        timeAgo: 'Recently',
        isAchievement: true,
        likes: 5,
      ));
    }

    final manualPosts = feedItems
        .where((post) => !post.isAchievement && post.userName == 'Mithil (You)')
        .toList();
    feedItems = [...manualPosts, ...newFeed];
  }

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

  void reset() {
    streak = 0;
    xp = 0;
    health = 25;
    level = 1;
    monthlyBudget = 20000.0;
    totalSpent = 0.0;
    pendingRewards = [];
    _initializeDefaults();
    _saveStats();
    notifyListeners();
  }
}
