import 'dart:async';
import '../../domain/entities/quest.dart';
import '../../domain/entities/quest_event.dart';
import '../../domain/entities/quest_completion_reward.dart';
import '../../utils/fingo_state.dart';
import '../../../../di/injection_container.dart';
import '../../../../features/expenses/domain/entities/transaction_entity.dart';
import 'quest_catalogue.dart';
import 'quest_firestore_service.dart';
import 'quest_period_manager.dart';
import 'no_spend_streak_service.dart';

class QuestEngineService {
  final QuestFirestoreService _firestoreService;
  final NoSpendStreakService _streakService;
  final StreamController<String> _completionController =
      StreamController<String>.broadcast();

  QuestEngineService({
    QuestFirestoreService? firestoreService,
    NoSpendStreakService? streakService,
  })  : _firestoreService = firestoreService ?? QuestFirestoreService(),
        _streakService = streakService ?? NoSpendStreakService();

  Stream<String> get completionStream => _completionController.stream;

  bool _isExpense(TransactionEntity t) {
    return t.type == TransactionType.expense;
  }

  bool _isIncome(TransactionEntity t) {
    return t.type == TransactionType.income;
  }

  Future<void> ensureQuestsForCurrentPeriods(
    String userId,
    int userLevel,
    double monthlyBudget,
  ) async {
    final allExisting = await _firestoreService.loadAllQuests(userId);
    final activeOrRewardable = allExisting
        .where((q) =>
            q.status == QuestStatus.active ||
            q.status == QuestStatus.completed ||
            q.status == QuestStatus.rewarded ||
            q.status == QuestStatus.expired)
        .toList();

    final now = DateTime.now();
    final (dailyStart, dailyEnd) = QuestPeriodManager.currentDailyPeriod(now);
    final (weeklyStart, weeklyEnd) = QuestPeriodManager.currentWeeklyPeriod(now);
    final (monthlyStart, monthlyEnd) =
        QuestPeriodManager.currentMonthlyPeriod(now);

    final toSave = <Quest>[];
    final toExpireIds = <String>[];
    final currentQuests = <Quest>[];

    // ── Daily Check ──────────────────────────────────────────────────────
    final existingDaily =
        activeOrRewardable.where((q) => q.type == QuestType.daily).toList();
    final isDailyCurrent = existingDaily.isNotEmpty &&
        _isSameDay(existingDaily.first.periodStart, dailyStart);

    if (isDailyCurrent) {
      currentQuests.addAll(existingDaily);
    } else {
      for (final q in existingDaily) {
        if (q.status == QuestStatus.active) {
          toExpireIds.add(q.id);
        }
      }
      final newDaily = QuestCatalogue.generateQuestsForPeriod(
        type: QuestType.daily,
        userLevel: userLevel,
        monthlyBudget: monthlyBudget,
        periodStart: dailyStart,
        periodEnd: dailyEnd,
      );
      toSave.addAll(newDaily);
      currentQuests.addAll(newDaily);
    }

    // ── Weekly Check ─────────────────────────────────────────────────────
    final existingWeekly =
        activeOrRewardable.where((q) => q.type == QuestType.weekly).toList();
    final isWeeklyCurrent = existingWeekly.isNotEmpty &&
        _isSameDay(existingWeekly.first.periodStart, weeklyStart);

    if (isWeeklyCurrent) {
      currentQuests.addAll(existingWeekly);
    } else {
      for (final q in existingWeekly) {
        if (q.status == QuestStatus.active) {
          toExpireIds.add(q.id);
        }
      }
      final newWeekly = QuestCatalogue.generateQuestsForPeriod(
        type: QuestType.weekly,
        userLevel: userLevel,
        monthlyBudget: monthlyBudget,
        periodStart: weeklyStart,
        periodEnd: weeklyEnd,
      );
      toSave.addAll(newWeekly);
      currentQuests.addAll(newWeekly);
    }

    // ── Monthly Check ────────────────────────────────────────────────────
    final existingMonthly =
        activeOrRewardable.where((q) => q.type == QuestType.monthly).toList();
    final isMonthlyCurrent = existingMonthly.isNotEmpty &&
        _isSameDay(existingMonthly.first.periodStart, monthlyStart);

    if (isMonthlyCurrent) {
      currentQuests.addAll(existingMonthly);
    } else {
      for (final q in existingMonthly) {
        if (q.status == QuestStatus.active) {
          toExpireIds.add(q.id);
        }
      }
      final newMonthly = QuestCatalogue.generateQuestsForPeriod(
        type: QuestType.monthly,
        userLevel: userLevel,
        monthlyBudget: monthlyBudget,
        periodStart: monthlyStart,
        periodEnd: monthlyEnd,
      );
      toSave.addAll(newMonthly);
      currentQuests.addAll(newMonthly);
    }

    if (toExpireIds.isNotEmpty) {
      await _firestoreService.expireQuests(userId, toExpireIds);
    }
    if (toSave.isNotEmpty) {
      await _firestoreService.saveQuests(userId, toSave);
    }

    sl<FingoState>().updateActiveQuests(currentQuests);
  }

  bool _isSameDay(DateTime a, DateTime b) {
    final aLocal = a.toLocal();
    final bLocal = b.toLocal();
    return aLocal.year == bLocal.year &&
        aLocal.month == bLocal.month &&
        aLocal.day == bLocal.day;
  }

  Future<void> recordEvent(QuestEvent event, String userId) async {
    final fingoState = sl<FingoState>();
    final activeQuests = List<Quest>.from(fingoState.activeQuests);
    final transactions = fingoState.transactions;
    final monthlyBudget = fingoState.monthlyBudget;
    final now = event.timestamp;
    final today = DateTime(now.year, now.month, now.day);

    // Update check-in streak on appOpen
    if (event.type == QuestEventType.appOpen) {
      fingoState.registerDailyCheckIn(now);
    }

    // Recalculate no-spend streak if transaction changed
    if (event.type == QuestEventType.transactionAdded ||
        event.type == QuestEventType.transactionDeleted ||
        event.type == QuestEventType.transactionListUpdated ||
        event.type == QuestEventType.appOpen) {
      final streakData = _streakService.calculateFromTransactions(transactions, now);
      fingoState.updateNoSpendStreak(streakData);
    }

    bool anyChanged = false;
    for (int i = 0; i < activeQuests.length; i++) {
      final q = activeQuests[i];
      if (q.status != QuestStatus.active) continue;

      int newProg = q.currentProgress;

      switch (q.category) {
        case QuestCategory.checkin:
          if (event.type == QuestEventType.appOpen) newProg = 1;
          break;

        case QuestCategory.logManual:
          if (event.type == QuestEventType.transactionAdded &&
              event.transaction != null &&
              event.transaction!.detectionMeta == null) {
            newProg = q.currentProgress + 1;
          }
          break;

        case QuestCategory.log3:
          final todayCount = transactions
              .where((t) => _isSameDay(t.date, today))
              .length;
          newProg = todayCount;
          break;

        case QuestCategory.reviewPending:
          if (event.type == QuestEventType.pendingReviewActioned) {
            newProg = q.currentProgress + 1;
          }
          break;

        case QuestCategory.checkAnalytics:
          if (event.type == QuestEventType.analyticsOpened) newProg = 1;
          break;

        case QuestCategory.categorize:
          final todayTxs =
              transactions.where((t) => _isSameDay(t.date, today)).toList();
          if (todayTxs.isNotEmpty &&
              todayTxs.every((t) =>
                  t.expenseCategory != null || t.incomeCategory != null)) {
            newProg = 1;
          } else {
            newProg = 0;
          }
          break;

        case QuestCategory.underBudgetDay:
          if (monthlyBudget > 0) {
            final dailyBudget = monthlyBudget / 30.0;
            final todaySpent = transactions
                .where((t) => _isExpense(t) && _isSameDay(t.date, today))
                .fold(0.0, (sum, t) => sum + t.amount);
            if (todaySpent <= dailyBudget) newProg = 1;
          }
          break;

        case QuestCategory.noSpend:
          if (_streakService.isTodayNoSpend(transactions, now)) {
            newProg = 1;
          } else {
            newProg = 0;
          }
          break;

        case QuestCategory.checkinStreak:
          newProg = fingoState.checkInStreak;
          break;

        case QuestCategory.noSpendDays:
          final (wStart, wEnd) = QuestPeriodManager.currentWeeklyPeriod(now);
          final expenseDaysThisWeek = transactions
              .where((t) =>
                  _isExpense(t) &&
                  !t.date.isBefore(wStart) &&
                  !t.date.isAfter(wEnd))
              .map((t) => DateTime(t.date.year, t.date.month, t.date.day))
              .toSet();
          int noSpendCount = 0;
          final todayDay = DateTime(now.year, now.month, now.day);
          for (DateTime d = wStart;
              !d.isAfter(todayDay) && !d.isAfter(wEnd);
              d = d.add(const Duration(days: 1))) {
            if (!expenseDaysThisWeek.contains(d)) noSpendCount++;
          }
          newProg = noSpendCount;
          break;

        case QuestCategory.reviewAllPending:
          final pendingCount = transactions.where((t) => t.isPending).length;
          if (transactions.isNotEmpty && pendingCount == 0) {
            newProg = 1;
          }
          break;

        case QuestCategory.budgetAdherence:
          if (monthlyBudget > 0) {
            final weeklyBudget = monthlyBudget / 4.33;
            final (wStart, wEnd) = QuestPeriodManager.currentWeeklyPeriod(now);
            final weeklySpent = transactions
                .where((t) =>
                    _isExpense(t) &&
                    !t.date.isBefore(wStart) &&
                    !t.date.isAfter(wEnd))
                .fold(0.0, (sum, t) => sum + t.amount);
            if (weeklySpent <= weeklyBudget) newProg = 1;
          }
          break;

        case QuestCategory.savingsPositive:
          final (wStart, wEnd) = QuestPeriodManager.currentWeeklyPeriod(now);
          final weeklyIncome = transactions
              .where((t) =>
                  _isIncome(t) &&
                  !t.date.isBefore(wStart) &&
                  !t.date.isAfter(wEnd))
              .fold(0.0, (sum, t) => sum + t.amount);
          final weeklyExpense = transactions
              .where((t) =>
                  _isExpense(t) &&
                  !t.date.isBefore(wStart) &&
                  !t.date.isAfter(wEnd))
              .fold(0.0, (sum, t) => sum + t.amount);
          if (weeklyIncome > weeklyExpense && weeklyIncome > 0) newProg = 1;
          break;

        case QuestCategory.checkin20:
          newProg = fingoState.monthlyCheckInCount;
          break;

        case QuestCategory.noSpend10:
          final streakData = _streakService.calculateFromTransactions(transactions, now);
          newProg = streakData.thisMonthNoSpendDays;
          break;

        case QuestCategory.monthlyBudgetAdherence:
          if (monthlyBudget > 0) {
            final (mStart, mEnd) = QuestPeriodManager.currentMonthlyPeriod(now);
            final monthlySpent = transactions
                .where((t) =>
                    _isExpense(t) &&
                    !t.date.isBefore(mStart) &&
                    !t.date.isAfter(mEnd))
                .fold(0.0, (sum, t) => sum + t.amount);
            if (monthlySpent <= monthlyBudget) newProg = 1;
          }
          break;

        case QuestCategory.savingsGoal:
          // Will be incremented when savings contribution event occurs
          break;
      }

      if (newProg != q.currentProgress) {
        anyChanged = true;
        QuestStatus newStatus = q.status;
        DateTime? completedAt = q.completedAt;

        if (newProg >= q.targetValue) {
          newProg = q.targetValue;
          newStatus = QuestStatus.completed;
          completedAt = now;

          // Auto award XP & diamonds immediately
          fingoState.awardXP(q.xpReward);
          fingoState.awardDiamonds(q.diamondReward);

          // Enqueue reward celebration for UI
          final reward = QuestCompletionReward(
            questId: q.id,
            questTitle: q.title,
            xpAwarded: q.xpReward,
            diamondsAwarded: q.diamondReward,
            questType: q.type,
          );
          fingoState.addPendingQuestReward(reward);
          _completionController.add(q.id);
        }

        final updated = q.copyWith(
          currentProgress: newProg,
          status: newStatus,
          completedAt: completedAt,
        );
        activeQuests[i] = updated;
        _firestoreService.saveQuest(userId, updated);
      }
    }

    if (anyChanged) {
      fingoState.updateActiveQuests(activeQuests);
    }
  }

  Future<void> onTransactionDeleted(
      TransactionEntity deleted, String userId) async {
    await recordEvent(
      QuestEvent(
        type: QuestEventType.transactionDeleted,
        transaction: deleted,
        timestamp: DateTime.now(),
      ),
      userId,
    );
  }

  Future<void> markQuestRewarded(String questId, String userId) async {
    await _firestoreService.markRewarded(userId, questId);
    final fingoState = sl<FingoState>();
    final list = List<Quest>.from(fingoState.activeQuests);
    final idx = list.indexWhere((q) => q.id == questId);
    if (idx != -1) {
      list[idx] = list[idx].copyWith(
        status: QuestStatus.rewarded,
        isRewarded: true,
      );
      fingoState.updateActiveQuests(list);
    }
  }
}
