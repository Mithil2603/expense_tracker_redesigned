import '../../../expenses/domain/entities/transaction_entity.dart';
import '../entities/financial_report.dart';
import '../entities/financial_insight.dart';
import '../entities/financial_intelligence.dart';
import '../../../../core/utils/utils.dart'; // For AppLogger
import '../../../../core/widgets/app_extensions.dart';

class InsightsCache {
  final DateTime startDate;
  final DateTime endDate;
  final double totalExpense;
  final double totalIncome;
  final double monthlyBudget;
  final List<TransactionEntity> transactions;
  final FinancialIntelligence intelligence;
  final List<FinancialInsight> insights;

  InsightsCache({
    required this.startDate,
    required this.endDate,
    required this.totalExpense,
    required this.totalIncome,
    required this.monthlyBudget,
    required this.transactions,
    required this.intelligence,
    required this.insights,
  });
}

class GenerateInsightsResult {
  final FinancialIntelligence intelligence;
  final List<FinancialInsight> insights;

  const GenerateInsightsResult({
    required this.intelligence,
    required this.insights,
  });
}

class GenerateInsights {
  // Static cache to persist calculations across screen reopenings
  static InsightsCache? _cache;

  GenerateInsightsResult call({
    required FinancialReport report,
    required List<TransactionEntity> allTransactions,
    required double monthlyBudget,
  }) {
    // Check if we can reuse the cached calculation
    if (_cache != null &&
        _cache!.startDate == report.startDate &&
        _cache!.endDate == report.endDate &&
        _cache!.totalExpense == report.totalExpense &&
        _cache!.totalIncome == report.totalIncome &&
        _cache!.monthlyBudget == monthlyBudget &&
        _areTransactionsIdentical(_cache!.transactions, allTransactions)) {
      AppLogger.i('⚡ [InsightsEngine] Returning cached financial intelligence and insights.');
      return GenerateInsightsResult(
        intelligence: _cache!.intelligence,
        insights: _cache!.insights,
      );
    }

    AppLogger.i('🧠 [InsightsEngine] Recalculating financial intelligence and insights...');

    // 1. Calculate Financial Health Score (0-100)
    final healthScore = _calculateHealthScore(report, allTransactions, monthlyBudget);

    // 2. Identify Money Leaks
    final leaks = _identifyMoneyLeaks(report, allTransactions);

    // 3. Assign Financial Personality
    final personality = _determinePersonality(report);

    // 4. Generate Weekly Review
    final weeklyReview = _generateWeeklyReview(report, allTransactions);

    // 5. Generate Financial Story Timeline
    final timeline = _generateStoryTimeline(report, allTransactions);

    // 6. Predict Goal Completion (assuming a dynamic savings goal of 5x monthly budget)
    final goalPrediction = _generateGoalPrediction(report, allTransactions, monthlyBudget);

    final intelligence = FinancialIntelligence(
      healthScore: healthScore,
      moneyLeaks: leaks,
      personality: personality,
      weeklyReview: weeklyReview,
      timelineEvents: timeline,
      goalPrediction: goalPrediction,
    );

    // 7. Generate Prioritized Insights List
    final insights = _generatePrioritizedInsights(report, intelligence);

    // Cache the fresh results
    _cache = InsightsCache(
      startDate: report.startDate,
      endDate: report.endDate,
      totalExpense: report.totalExpense,
      totalIncome: report.totalIncome,
      monthlyBudget: monthlyBudget,
      transactions: List<TransactionEntity>.from(allTransactions),
      intelligence: intelligence,
      insights: insights,
    );

    return GenerateInsightsResult(
      intelligence: intelligence,
      insights: insights,
    );
  }

  bool _areTransactionsIdentical(List<TransactionEntity> list1, List<TransactionEntity> list2) {
    if (list1.length != list2.length) {
      return false;
    }
    for (int i = 0; i < list1.length; i++) {
      final t1 = list1[i];
      final t2 = list2[i];
      if (t1.id != t2.id ||
          t1.amount != t2.amount ||
          t1.type != t2.type ||
          t1.date != t2.date ||
          t1.expenseCategory != t2.expenseCategory ||
          t1.incomeCategory != t2.incomeCategory ||
          t1.title != t2.title ||
          t1.updatedAt != t2.updatedAt) {
        return false;
      }
    }
    return true;
  }

  HealthScore _calculateHealthScore(
    FinancialReport report,
    List<TransactionEntity> allTransactions,
    double monthlyBudget,
  ) {
    // 1. Ratio-Based Score Calculations (100 points total)
    // We prioritize efficiency over raw amounts to prevent penalizing larger date ranges.

    // Factor A: Savings Rate (max 40 points) -> Benchmark >= 20% gets full score
    double savingsRateScore = 0.0;
    if (report.savingsRate > 0) {
      savingsRateScore = ((report.savingsRate / 20.0) * 40.0).clamp(0.0, 40.0);
    }

    // Factor B: Expense-to-Income Ratio (max 40 points) -> Benchmark <= 70% gets full score
    double ratioScore = 40.0;
    if (report.totalIncome > 0) {
      final ratio = report.totalExpense / report.totalIncome;
      if (ratio <= 0.70) {
        ratioScore = 40.0;
      } else {
        ratioScore = (40.0 - ((ratio - 0.70) / 0.30 * 40.0)).clamp(0.0, 40.0);
      }
    } else if (report.totalExpense > 0) {
      ratioScore = 0.0; // Expenses but no income = 0 points
    } else {
      ratioScore = 20.0; // Neutral fallback
    }

    // Factor C: Consistency of Savings (max 20 points)
    // Reward users simply for having net positive savings in the current period.
    double savingsConsistencyScore = report.netSavings > 0 ? 20.0 : 0.0;

    int score = (savingsRateScore + ratioScore + savingsConsistencyScore).round().clamp(0, 100);

    // 2. Normalized Score for Previous Period
    final prevStart = report.startDate.subtract(report.endDate.difference(report.startDate));
    final prevEnd = report.startDate.subtract(const Duration(microseconds: 1));

    final prevTransactions = allTransactions.where((t) =>
        t.date.isAfter(prevStart.subtract(const Duration(microseconds: 1))) &&
        t.date.isBefore(prevEnd.add(const Duration(microseconds: 1)))).toList();

    double prevIncome = 0;
    double prevExpense = 0;
    for (final tx in prevTransactions) {
      if (tx.type == TransactionType.income) {
        prevIncome += tx.amount;
      } else {
        prevExpense += tx.amount;
      }
    }
    double prevSavings = prevIncome - prevExpense;
    double prevSavingsRate = prevIncome > 0 ? ((prevSavings / prevIncome) * 100.0).clamp(0.0, 100.0) : 0.0;

    double prevSavingsRateScore = 0.0;
    if (prevSavingsRate > 0) {
      prevSavingsRateScore = ((prevSavingsRate / 20.0) * 40.0).clamp(0.0, 40.0);
    }

    double prevRatioScore = 40.0;
    if (prevIncome > 0) {
      final ratio = prevExpense / prevIncome;
      if (ratio <= 0.70) {
        prevRatioScore = 40.0;
      } else {
        prevRatioScore = (40.0 - ((ratio - 0.70) / 0.30 * 40.0)).clamp(0.0, 40.0);
      }
    } else if (prevExpense > 0) {
      prevRatioScore = 0.0;
    } else {
      prevRatioScore = 20.0;
    }

    double prevSavingsConsistencyScore = prevSavings > 0 ? 20.0 : 0.0;
    int previousScore = (prevSavingsRateScore + prevRatioScore + prevSavingsConsistencyScore).round().clamp(0, 100);

    if (prevTransactions.isEmpty) {
      previousScore = 70; // Reasonable fallback default
    }

    final delta = score - previousScore;
    String explanation;
    if (delta > 0) {
      explanation = 'Your financial health score improved by $delta points due to better savings rate and keeping category expenses under control.';
    } else if (delta < 0) {
      explanation = 'Your score dropped by ${delta.abs()} points. Dining out and impulse shopping exceeded budget thresholds.';
    } else {
      explanation = 'Your financial discipline remains steady compared to the last period. Good work keeping your metrics stable!';
    }

    // 4. Generate Explainability Reasons
    final List<String> positiveReasons = [];
    final List<String> negativeReasons = [];

    if (report.savingsRate >= 20.0) {
      positiveReasons.add('Strong savings rate of ${report.savingsRate.toStringAsFixed(0)}% (above 20% target)');
    } else if (report.savingsRate >= 10.0) {
      positiveReasons.add('Healthy savings rate of ${report.savingsRate.toStringAsFixed(0)}%');
    } else {
      negativeReasons.add('Low savings rate of ${report.savingsRate.toStringAsFixed(0)}% (aim for 20%+)');
    }

    if (report.totalIncome > report.totalExpense) {
      positiveReasons.add('Inflow exceeded outflows, generating a net savings surplus of ${report.netSavings.toCurrency()}');
    } else if (report.totalExpense > report.totalIncome) {
      negativeReasons.add('Outflow exceeded inflows, generating a net deficit of ${report.netSavings.abs().toCurrency()}');
    }

    // Category growth checks for explainability
    final Map<ExpenseCategory, double> prevCategoryExpenses = {};
    for (final tx in prevTransactions) {
      if (tx.type == TransactionType.expense && tx.expenseCategory != null) {
        prevCategoryExpenses[tx.expenseCategory!] = (prevCategoryExpenses[tx.expenseCategory!] ?? 0.0) + tx.amount;
      }
    }
    report.categoryExpenses.forEach((cat, amt) {
      final prevAmt = prevCategoryExpenses[cat] ?? 0.0;
      if (prevAmt > 0 && amt > prevAmt * 1.25 && amt > (report.totalIncome * 0.03)) {
        final pctGrowth = ((amt - prevAmt) / prevAmt * 100).toStringAsFixed(0);
        negativeReasons.add('${cat.displayName} spending surged by $pctGrowth% compared to last period');
      }
    });

    return HealthScore(
      score: score,
      previousScore: previousScore,
      delta: delta,
      explanation: explanation,
      positiveReasons: positiveReasons,
      negativeReasons: negativeReasons,
    );
  }

  List<MoneyLeak> _identifyMoneyLeaks(
    FinancialReport report,
    List<TransactionEntity> allTransactions,
  ) {
    final List<MoneyLeak> leaks = [];
    final durationInDays = report.endDate.difference(report.startDate).inDays.clamp(1, 365);
    final double months = durationInDays / 30.437;

    final prevStart = report.startDate.subtract(report.endDate.difference(report.startDate));
    final prevEnd = report.startDate.subtract(const Duration(microseconds: 1));

    final prevTransactions = allTransactions.where((t) =>
        t.date.isAfter(prevStart.subtract(const Duration(microseconds: 1))) &&
        t.date.isBefore(prevEnd.add(const Duration(microseconds: 1)))).toList();

    final Map<ExpenseCategory, double> prevCategoryExpenses = {};
    for (final tx in prevTransactions) {
      if (tx.type == TransactionType.expense && tx.expenseCategory != null) {
        prevCategoryExpenses[tx.expenseCategory!] = (prevCategoryExpenses[tx.expenseCategory!] ?? 0.0) + tx.amount;
      }
    }

    final now = DateTime.now();
    final currentMonthIncome = allTransactions
        .where((tx) => tx.type == TransactionType.income && tx.date.year == now.year && tx.date.month == now.month)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    final currentMonthExpense = allTransactions
        .where((tx) => tx.type == TransactionType.expense && tx.date.year == now.year && tx.date.month == now.month)
        .fold(0.0, (sum, tx) => sum + tx.amount);
    
    final realMonthlySavings = currentMonthIncome - currentMonthExpense;

    report.categoryExpenses.forEach((category, currentAmount) {
      final prevAmount = prevCategoryExpenses[category] ?? 0.0;
      final monthlyAmount = currentAmount / months;

      // 1. Evaluate Growth (Growth Rate) & Spending Acceleration
      double growthRate = 0.0;
      bool isUnusualGrowth = false;
      if (prevAmount > 0.0) {
        growthRate = (currentAmount - prevAmount) / prevAmount;
        if (growthRate >= 0.10) {
          isUnusualGrowth = true;
        }
      }

      // 2. Evaluate Dominance
      final dominanceRatio = report.totalExpense > 0 ? (currentAmount / report.totalExpense) : 0.0;
      final isDominant = dominanceRatio >= 0.20;

      // 3. Evaluated relative to Income (Income Context Awareness & Affordability)
      final incomeRatio = report.totalIncome > 0 ? (currentAmount / report.totalIncome) : 0.0;
      String impactLevel = 'Low';
      if (incomeRatio >= 0.10) {
        impactLevel = 'High';
      } else if (incomeRatio >= 0.03) {
        impactLevel = 'Medium';
      }

      bool isLeak = false;
      String reason = '';
      String confidence = 'Medium';

      if (prevAmount > 0.0) {
        if (isUnusualGrowth) {
          isLeak = true;
          final pct = (growthRate * 100).toStringAsFixed(0);
          reason = '${category.displayName} spending increased $pct% compared to the previous period.';
          confidence = growthRate >= 0.25 ? 'High' : 'Medium';
        }
      } else {
        if (isDominant && (impactLevel == 'High' || impactLevel == 'Medium')) {
          isLeak = true;
          final pct = (dominanceRatio * 100).toStringAsFixed(0);
          reason = '${category.displayName} dominates your budget, representing $pct% of your total expenses.';
          confidence = 'Medium';
        } else if (category == ExpenseCategory.subscriptions ||
            category == ExpenseCategory.gamingAndDigital ||
            category == ExpenseCategory.entertainmentAndLeisure) {
          if (currentAmount > 0.0 && (report.totalIncome == 0 || incomeRatio > 0.01)) {
            isLeak = true;
            reason = 'Detected recurring subscription or digital/entertainment spending in ${category.displayName}.';
            confidence = 'Low';
          }
        }
      }

      if (isLeak) {
        double potentialMonthly = realMonthlySavings > 0 
            ? (monthlyAmount * 0.25).clamp(0.0, realMonthlySavings).toDouble()
            : monthlyAmount * 0.25;
        final potentialAnnual = potentialMonthly * 12;
        final projectedYearly = currentAmount * (12.0 / months);

        String tip = '';
        switch (category) {
          case ExpenseCategory.foodAndDining:
            tip = 'Try meal prepping on weekends or cooking at home twice more per week.';
            break;
          case ExpenseCategory.shoppingAndFashion:
            tip = 'Apply the 24-hour rule before checking out. Add items to a wishlist first.';
            break;
          case ExpenseCategory.subscriptions:
            tip = 'Review app store subscriptions and cancel any platforms you haven\'t used this week.';
            break;
          case ExpenseCategory.entertainmentAndLeisure:
          case ExpenseCategory.gamingAndDigital:
            tip = 'Look for free or community events, or set a hard cap on digital purchases.';
            break;
          case ExpenseCategory.travelAndVacation:
            tip = 'Book travel in advance, travel off-season, or plan local staycations.';
            break;
          default:
            tip = 'Track these category payments closely and set a category budget.';
        }

        reason += ' At ${(incomeRatio * 100).toStringAsFixed(0)}% of your income, this is a $impactLevel impact expense.';

        leaks.add(MoneyLeak(
          category: category.displayName,
          monthlyAmount: monthlyAmount,
          projectedYearlyCost: projectedYearly,
          actionableTip: tip,
          potentialMonthlySavings: potentialMonthly,
          potentialAnnualSavings: potentialAnnual,
          confidenceLevel: confidence,
          leakReason: reason,
        ));
      }
    });

    return leaks;
  }

  FinancialPersonality _determinePersonality(FinancialReport report) {
    if (report.filteredTransactions.isEmpty) {
      return const FinancialPersonality(
        name: 'The Starter',
        description: 'You are just beginning your financial journey on Fingo!',
        finnyCoachMessage: 'Welcome! Log more transactions to reveal your detailed financial personality traits.',
      );
    }

    final foodSpent = report.categoryExpenses[ExpenseCategory.foodAndDining] ?? 0.0;
    final travelSpent = (report.categoryExpenses[ExpenseCategory.travelAndVacation] ?? 0.0) +
                       (report.categoryExpenses[ExpenseCategory.transportation] ?? 0.0);
    final shoppingSpent = report.categoryExpenses[ExpenseCategory.shoppingAndFashion] ?? 0.0;

    if (report.savingsRate >= 40.0) {
      return const FinancialPersonality(
        name: 'The Super Saver',
        description: 'You prioritize saving money above everything else, consistently keeping expenses minimal.',
        finnyCoachMessage: 'Amazing savings rate! You manage to stash away a significant chunk of your earnings.',
      );
    } else if (shoppingSpent > report.totalExpense * 0.25) {
      return const FinancialPersonality(
        name: 'The Impulse Shopper',
        description: 'Shopping and retail therapy account for a dominant portion of your monthly expenses.',
        finnyCoachMessage: 'Let\'s try to put items in a wishlist for 48 hours to curb shopping impulses.',
      );
    } else if (foodSpent > report.totalExpense * 0.3) {
      return const FinancialPersonality(
        name: 'The Culinary Foodie',
        description: 'You love dining out, order deliveries, and enjoy culinary experiences above other items.',
        finnyCoachMessage: 'Food is life! But saving on kitchen orders can boost your level progress fast.',
      );
    } else if (travelSpent > report.totalExpense * 0.25) {
      return const FinancialPersonality(
        name: 'The Explorer',
        description: 'You spend a large percentage of your budget on commuting, rides, and travel vacations.',
        finnyCoachMessage: 'Carpooling or travel booking in advance will keep your streaks blazing!',
      );
    } else if (report.savingsRate >= 20.0 && report.savingsRate < 40.0) {
      return const FinancialPersonality(
        name: 'The Master Planner',
        description: 'You maintain a balanced savings habit while spending predictably on necessities.',
        finnyCoachMessage: 'Excellent balance! You budget with high precision and maintain constant savings.',
      );
    } else {
      return const FinancialPersonality(
        name: 'The Casual Tracker',
        description: 'You log your transactions regularly but still have room to optimize savings rates.',
        finnyCoachMessage: 'Consistency is key. Keeping your logging streak alive will help you spot savings opportunities.',
      );
    }
  }

  WeeklyReview _generateWeeklyReview(
    FinancialReport report,
    List<TransactionEntity> allTransactions,
  ) {
    final now = DateTime.now();
    final oneWeekAgo = now.subtract(const Duration(days: 7));

    final weeklyTxs = allTransactions.where((t) =>
        t.date.isAfter(oneWeekAgo.subtract(const Duration(microseconds: 1))) &&
        t.date.isBefore(now.add(const Duration(microseconds: 1)))).toList();

    double income = 0;
    double expenses = 0;
    final Map<String, double> categorySums = {};

    for (final tx in weeklyTxs) {
      if (tx.type == TransactionType.income) {
        income += tx.amount;
      } else {
        expenses += tx.amount;
        final catName = tx.expenseCategory?.displayName ?? 'Other';
        categorySums[catName] = (categorySums[catName] ?? 0.0) + tx.amount;
      }
    }

    String highestCat = 'None';
    double maxSpent = 0;
    String lowestCat = 'None';
    double minSpent = double.infinity;

    categorySums.forEach((cat, amt) {
      if (amt > maxSpent) {
        maxSpent = amt;
        highestCat = cat;
      }
      if (amt < minSpent) {
        minSpent = amt;
        lowestCat = cat;
      }
    });

    if (lowestCat == 'None' || minSpent == double.infinity) {
      lowestCat = 'None';
    }

    final savings = income - expenses;
    final majorEvents = weeklyTxs
        .where((t) => t.type == TransactionType.expense && t.amount >= 2000.0)
        .map((t) => '₹${t.amount.toStringAsFixed(0)} on ${t.title}')
        .toList();

    final delta = report.netSavings > 0 ? 5 : -2;

    String narrativeSummary;
    if (savings > 0) {
      narrativeSummary = 'This week you saved ₹${savings.toStringAsFixed(0)}! Spending was kept under control, especially on $lowestCat.';
    } else if (expenses > 0) {
      narrativeSummary = 'Your expenses exceeded income by ₹${savings.abs().toStringAsFixed(0)} this week. High spending was detected in $highestCat.';
    } else {
      narrativeSummary = 'No transactions recorded this week. Ready to log your first save?';
    }

    return WeeklyReview(
      income: income,
      expenses: expenses,
      savings: savings,
      highestCategory: highestCat,
      lowestCategory: lowestCat,
      healthScoreDelta: delta,
      narrativeSummary: narrativeSummary,
      majorEvents: majorEvents,
    );
  }

  List<String> _generateStoryTimeline(
    FinancialReport report,
    List<TransactionEntity> allTransactions,
  ) {
    if (report.filteredTransactions.isEmpty) {
      return ['Start of your logging timeline! Log your first transaction to compile your story.'];
    }

    final List<String> timeline = [];

    // Filter transactions
    final expenses = report.filteredTransactions
        .where((t) => t.type == TransactionType.expense)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    final incomes = report.filteredTransactions
        .where((t) => t.type == TransactionType.income)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    // Get previous period data for comparisons if possible
    final prevStart = report.startDate.subtract(report.endDate.difference(report.startDate));
    final prevEnd = report.startDate.subtract(const Duration(microseconds: 1));
    final prevTransactions = allTransactions.where((t) =>
        t.date.isAfter(prevStart.subtract(const Duration(microseconds: 1))) &&
        t.date.isBefore(prevEnd.add(const Duration(microseconds: 1)))).toList();

    final Map<ExpenseCategory, double> prevCategoryExpenses = {};
    for (final tx in prevTransactions) {
      if (tx.type == TransactionType.expense && tx.expenseCategory != null) {
        prevCategoryExpenses[tx.expenseCategory!] = (prevCategoryExpenses[tx.expenseCategory!] ?? 0.0) + tx.amount;
      }
    }

    // 1. Spending Behavior Stories (Expenses)
    if (expenses.isNotEmpty && report.totalExpense > 0) {
      // Dominant Category
      ExpenseCategory? maxCat;
      double maxVal = 0.0;
      report.categoryExpenses.forEach((cat, val) {
        if (val > maxVal) {
          maxVal = val;
          maxCat = cat;
        }
      });
      if (maxCat != null) {
        final pct = (maxVal / report.totalExpense * 100).toStringAsFixed(0);
        timeline.add('${maxCat!.displayName} spending became the dominant expense category, accounting for $pct% of total outflows.');
      }

      // Peak activity
      final Map<int, double> weeklySpent = {};
      for (final tx in expenses) {
        final day = tx.date.day;
        final week = ((day - 1) ~/ 7) + 1;
        weeklySpent[week] = (weeklySpent[week] ?? 0.0) + tx.amount;
      }
      int peakWeek = 1;
      double peakAmt = 0.0;
      weeklySpent.forEach((w, amt) {
        if (amt > peakAmt) {
          peakAmt = amt;
          peakWeek = w;
        }
      });
      if (peakAmt > 0) {
        timeline.add('Shopping and spending activity peaked during Week $peakWeek, with total expenses reaching ₹${peakAmt.toStringAsFixed(0)}.');
      }

      // Declined category compared to previous
      ExpenseCategory? declinedCat;
      double maxDeclinePct = 0.0;
      prevCategoryExpenses.forEach((cat, prevVal) {
        final currVal = report.categoryExpenses[cat] ?? 0.0;
        if (prevVal > 0 && currVal < prevVal) {
          final declinePct = (prevVal - currVal) / prevVal;
          if (declinePct > maxDeclinePct) {
            maxDeclinePct = declinePct;
            declinedCat = cat;
          }
        }
      });

      if (declinedCat != null && maxDeclinePct >= 0.15) {
        final pct = (maxDeclinePct * 100).toStringAsFixed(0);
        timeline.add('${declinedCat!.displayName} expenses declined by $pct% compared to the previous period.');
      } else {
        timeline.add('Food and retail spending remained consistent across the weeks.');
      }
    } else {
      timeline.add('No spending recorded during this period, keeping outflows at zero.');
    }

    // 2. Income Behavior Stories (Incomes)
    if (incomes.isNotEmpty && report.totalIncome > 0) {
      // Primary stream
      IncomeCategory? mainIncomeCat;
      double mainIncomeVal = 0.0;
      report.categoryIncomes.forEach((cat, val) {
        if (val > mainIncomeVal) {
          mainIncomeVal = val;
          mainIncomeCat = cat;
        }
      });

      if (mainIncomeCat != null) {
        final mainPct = (mainIncomeVal / report.totalIncome * 100).toStringAsFixed(0);
        timeline.add('${mainIncomeCat!.displayName} remained the primary income stream, contributing $mainPct% of total inflows.');
      }

      // Additional sources
      double secondaryIncomeVal = 0.0;
      report.categoryIncomes.forEach((cat, val) {
        if (cat != mainIncomeCat) {
          secondaryIncomeVal += val;
        }
      });
      if (secondaryIncomeVal > 0.0) {
        final secPct = (secondaryIncomeVal / report.totalIncome * 100).toStringAsFixed(0);
        timeline.add('Additional income sources contributed $secPct% of total inflows.');
      }

      if (incomes.length >= 2) {
        timeline.add('Inflow channels remained active with regular transfers logged across the period.');
      }
    } else {
      timeline.add('No income streams recorded during this period.');
    }

    return timeline;
  }

  GoalPrediction _generateGoalPrediction(FinancialReport report, List<TransactionEntity> allTransactions, double monthlyBudget) {
    // Dynamically scale goal target based on report duration
    final durationInDays = report.endDate.difference(report.startDate).inDays.clamp(1, 365);
    final target = (monthlyBudget * 5.0) * (durationInDays / 30.437);
    
    double progress = 0.0;
    if (report.netSavings > 0 && target > 0) {
      progress = (report.netSavings / target * 100.0).clamp(0.0, 100.0);
    }

    DateTime? estCompletionDate;
    String pace = 'Not Started';
    double recommended = 0.0;
    String suggestion = 'Start logging income and minimizing expenses to track your progress.';

    if (report.netSavings > 0) {
      final monthlyRate = (report.netSavings / durationInDays) * 30.437;
      final currentSavedAmount = report.netSavings; 
      final remaining = target - currentSavedAmount;

      if (remaining > 0 && monthlyRate > 0) {
        final monthsNeeded = (remaining / monthlyRate).ceil();
        estCompletionDate = DateTime.now().add(Duration(days: monthsNeeded * 30));
        pace = monthsNeeded <= 3 ? 'Fast' : 'Moderate';
        recommended = (remaining / 3.0).clamp(1000.0, 10000.0);
        suggestion = 'Increase your savings by ₹${(recommended - monthlyRate).clamp(500.0, 5000.0).toStringAsFixed(0)} monthly to hit your goal 2 months early.';
      } else if (remaining <= 0) {
        progress = 100.0;
        pace = 'Goal Reached!';
        suggestion = 'Congratulations! Set a higher budget target to earn bonus XP!';
      }
    }

    return GoalPrediction(
      goalProgress: progress,
      estimatedCompletionDate: estCompletionDate,
      pace: pace,
      recommendedContribution: recommended,
      earlyCompletionSuggestion: suggestion,
    );
  }

  List<FinancialInsight> _generatePrioritizedInsights(
    FinancialReport report,
    FinancialIntelligence intel,
  ) {
    final List<FinancialInsight> list = [];

    // 1. Check budget warning (Critical)
    if (report.totalExpense > report.totalIncome && report.totalIncome > 0) {
      list.add(FinancialInsight(
        id: 'i1',
        priority: InsightPriority.critical,
        category: 'Warning',
        title: 'Exceeding Income Limit',
        message: 'Your expenses exceed your earnings this period by ₹${(report.totalExpense - report.totalIncome).toStringAsFixed(0)}.',
        finnyMessage: 'Watch out! Spending more than you earn stalls your level progress. Let\'s cut non-essential shopping.',
        scoreImpact: -15,
      ));
    }

    // 2. Check category warning (Important)
    final foodSpent = report.categoryExpenses[ExpenseCategory.foodAndDining] ?? 0.0;
    if (foodSpent > report.totalExpense * 0.35 && report.totalExpense > 0) {
      list.add(FinancialInsight(
        id: 'i2',
        priority: InsightPriority.important,
        category: 'Category Analysis',
        title: 'High Food Expenses',
        message: 'Dining out and food orders account for ${(foodSpent / report.totalExpense * 100).toStringAsFixed(0)}% of your expenses.',
        finnyMessage: 'Food deliveries are draining your budget! Try cooking at home to save up to ₹5,000 this month.',
        scoreImpact: -8,
      ));
    }

    // 3. Positive savings rate (Positive)
    if (report.savingsRate >= 20.0) {
      list.add(FinancialInsight(
        id: 'i3',
        priority: InsightPriority.positive,
        category: 'Savings Intelligence',
        title: 'Strong Savings Rate',
        message: 'You saved ${report.savingsRate.toStringAsFixed(0)}% of your income this period.',
        finnyMessage: 'Fantastic job! You saved more than 20% of your earnings. Keep this streak going!',
        scoreImpact: 10,
      ));
    }

    // 4. Milestone savings (Achievement)
    if (report.netSavings >= 10000.0) {
      list.add(FinancialInsight(
        id: 'i4',
        priority: InsightPriority.achievement,
        category: 'Achievements',
        title: 'Gold Saver Milestone',
        message: 'You have accumulated over ₹10,000 in net savings during this filter period.',
        finnyMessage: 'Wow, you hit the ₹10k savings mark! You\'ve earned a virtual Golden Piggy bank badge!',
        scoreImpact: 15,
      ));
    }

    // Fallbacks to ensure we always have insights
    if (list.isEmpty) {
      list.add(FinancialInsight(
        id: 'i_fallback',
        priority: InsightPriority.positive,
        category: 'Habit Detection',
        title: 'Consistent Tracking',
        message: 'You are logging transactions consistently to understand your cash flow.',
        finnyMessage: 'Excellent logging streak! Keep recording your logs daily to reveal customized leak insights.',
        scoreImpact: 5,
      ));
    }

    // Sort by priority index: critical first, then important, then positive, then achievement
    list.sort((a, b) => a.priority.index.compareTo(b.priority.index));

    return list;
  }
}
