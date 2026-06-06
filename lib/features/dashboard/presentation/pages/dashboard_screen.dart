import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Gamified User Stats
  int _streak = 5;
  int _xp = 20;
  final int _targetXp = 50;
  int _hearts = 4;
  final int _maxHearts = 5;
  int _level = 2;
  double _monthlyBudget = 15000.0;
  double _totalSpent = 469.0;

  // Mock Quests
  late List<_QuestItem> _quests;

  // Mock Transactions
  late List<_TransactionItem> _transactions;

  @override
  void initState() {
    super.initState();
    _quests = [
      _QuestItem(
        id: 'q1',
        title: 'Daily Reporter',
        description: 'Log your first transaction of the day.',
        xpReward: 10,
        progress: 1,
        target: 1,
        completed: true,
      ),
      _QuestItem(
        id: 'q2',
        title: 'Thrifty Habit',
        description: 'Keep your daily expenses below ₹500.',
        xpReward: 20,
        progress: 469, // current spending today
        target: 500,
        completed: false,
      ),
      _QuestItem(
        id: 'q3',
        title: 'Financial Scholar',
        description: 'Log 3 transactions in any category.',
        xpReward: 15,
        progress: 2,
        target: 3,
        completed: false,
      ),
    ];

    _transactions = [
      _TransactionItem(
        title: 'Starbucks Coffee',
        amount: 240.00,
        category: 'Food',
        date: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      _TransactionItem(
        title: 'Auto Fare to Station',
        amount: 50.00,
        category: 'Travel',
        date: DateTime.now().subtract(const Duration(hours: 4)),
      ),
      _TransactionItem(
        title: 'Spotify Subscription',
        amount: 179.00,
        category: 'Entertainment',
        date: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ];
  }

  // ─── Interaction Handlers ──────────────────────────────────────────────────

  void _onQuestTapped(int index) {
    if (_quests[index].completed) return;

    setState(() {
      final q = _quests[index];
      if (q.id == 'q3') {
        // Increment progress
        q.progress++;
        if (q.progress >= q.target) {
          q.completed = true;
          _awardXP(q.xpReward);
        }
      } else if (q.id == 'q2') {
        // Complete the budget quest manually for demo
        q.completed = true;
        _awardXP(q.xpReward);
      }
    });
  }

  void _awardXP(int xpEarned) {
    setState(() {
      _xp += xpEarned;
      if (_xp >= _targetXp) {
        _xp -= _targetXp;
        _level++;
        _showLevelUpBanner();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.accent,
            content: Row(
              children: [
                const Text('⭐ ', style: TextStyle(fontSize: 18)),
                Expanded(
                  child: Text(
                    'Quest Completed! +$xpEarned XP earned!',
                    style: AppTextStyles.labelMD.copyWith(color: AppColors.bgDark),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    });
  }

  void _showLevelUpBanner() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('👑', style: TextStyle(fontSize: 54)),
              const SizedBox(height: 12),
              Text('LEVEL UP!', style: AppTextStyles.display2.copyWith(color: AppColors.accent)),
              const SizedBox(height: 8),
              Text(
                'Congratulations! You reached Level $_level!',
                style: AppTextStyles.bodyMD,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              App3DButton(
                label: 'Awesome!',
                onTap: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addNewTransaction(String title, double amount, String category) {
    setState(() {
      final newTx = _TransactionItem(
        title: title,
        amount: amount,
        category: category,
        date: DateTime.now(),
      );
      _transactions.insert(0, newTx);
      _totalSpent += amount;

      // Update quests progress
      // 1. Daily Reporter completes
      final q1 = _quests.firstWhere((q) => q.id == 'q1');
      if (!q1.completed) {
        q1.completed = true;
        _awardXP(q1.xpReward);
      }

      // 2. Scholar progress
      final q3 = _quests.firstWhere((q) => q.id == 'q3');
      if (!q3.completed) {
        q3.progress++;
        if (q3.progress >= q3.target) {
          q3.completed = true;
          _awardXP(q3.xpReward);
        }
      }

      // 3. Keep budget quest checks
      final q2 = _quests.firstWhere((q) => q.id == 'q2');
      q2.progress = _transactions
          .where((t) =>
              t.date.year == DateTime.now().year &&
              t.date.month == DateTime.now().month &&
              t.date.day == DateTime.now().day)
          .fold(0.0, (sum, t) => sum + t.amount)
          .toInt();
      if (q2.progress > q2.target && !q2.completed) {
        // Deduct life!
        if (_hearts > 0) _hearts--;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.error,
            content: Row(
              children: [
                const Text('💔 ', style: TextStyle(fontSize: 18)),
                Expanded(
                  child: Text(
                    'Budget Breach! You lost a heart today.',
                    style: AppTextStyles.labelMD.copyWith(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      }

      // Standard log XP
      _awardXP(5); // +5 XP for logging expense
    });
  }

  void _showAddExpenseDialog() {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    String selectedCategory = 'Food';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: AppSizes.paddingLG,
                right: AppSizes.paddingLG,
                top: AppSizes.paddingMD,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Log New Expense', style: AppTextStyles.h2),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Expense Description',
                    hint: 'e.g. McDonald Lunch',
                    controller: titleCtrl,
                    prefixIcon: Icons.edit_rounded,
                  ),
                  const SizedBox(height: 12),
                  AppAmountField(
                    label: 'Amount (INR)',
                    hint: '0.00',
                    controller: amountCtrl,
                  ),
                  const SizedBox(height: 16),
                  Text('Category'.toUpperCase(), style: AppTextStyles.overline),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.categories.map((cat) {
                      final isSelected = selectedCategory == cat;
                      final catColor = _getCategoryColor(cat);
                      return AppChip(
                        label: cat,
                        selected: isSelected,
                        color: catColor,
                        icon: _getCategoryIcon(cat),
                        onTap: () {
                          setDialogState(() {
                            selectedCategory = cat;
                          });
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                  App3DButton(
                    label: 'Log Transaction',
                    color: AppColors.primary,
                    shadowColor: AppColors.primaryDark,
                    onTap: () {
                      final title = titleCtrl.text.trim();
                      final amountVal = double.tryParse(amountCtrl.text) ?? 0.0;
                      if (title.isNotEmpty && amountVal > 0.0) {
                        _addNewTransaction(title, amountVal, selectedCategory);
                        Navigator.of(context).pop();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please fill out all fields correctly.'),
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final remainingBudget = _monthlyBudget - _totalSpent;
    final budgetRatio = (remainingBudget / _monthlyBudget).clamp(0.0, 1.0);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            setState(() {
              _streak++;
              _xp = (_xp + 5).clamp(0, _targetXp);
              if (_xp >= _targetXp) {
                _xp = 0;
                _level++;
              }
            });
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.screenHPadding,
                vertical: AppSizes.screenVPadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ─── Game Status Top Header Bar ────────────────────────────
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
                          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                          border: Border.all(
                            color: isLight ? AppColors.outlineLight : AppColors.outlineDark,
                            width: AppSizes.borderThick,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Text('👑', style: TextStyle(fontSize: 16)),
                            const SizedBox(width: 4),
                            Text(
                              'LVL $_level',
                              style: AppTextStyles.labelMD.copyWith(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      AppStreakIndicator(
                        streak: _streak,
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Streak Active! Log transactions daily to protect it! 🔥'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(width: 8),
                      AppHeartIndicator(
                        lives: _hearts,
                        maxLives: _maxHearts,
                        onTap: () {
                          setState(() {
                            _hearts = _maxHearts;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Hearts Refilled! ❤️')),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ─── Daily XP Goal Progress ────────────────────────────────
                  Container(
                    padding: const EdgeInsets.all(AppSizes.paddingMD),
                    decoration: BoxDecoration(
                      color: isLight ? AppColors.surfaceLight : AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                      border: Border.all(
                        color: isLight ? AppColors.outlineLight : AppColors.outlineDark,
                        width: AppSizes.borderThick,
                      ),
                    ),
                    child: AppXPProgressBar(currentXP: _xp, targetXP: _targetXp),
                  ),
                  const SizedBox(height: 16),

                  // ─── Financial Status Card ─────────────────────────────────
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'FINGO SAFE BUDGET',
                              style: AppTextStyles.overline.copyWith(color: AppColors.primary),
                            ),
                            Text(
                              '${remainingBudget.toCurrency()} Left',
                              style: AppTextStyles.labelSM.copyWith(
                                color: remainingBudget < 1000.0 ? AppColors.error : AppColors.primary,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              _totalSpent.toCurrency(),
                              style: AppTextStyles.display2.copyWith(
                                color: isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'spent this month',
                              style: AppTextStyles.bodySM,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppSizes.radiusFull),
                          child: SizedBox(
                            height: 12,
                            child: LinearProgressIndicator(
                              value: budgetRatio,
                              color: remainingBudget < 1000.0 ? AppColors.error : AppColors.primary,
                              backgroundColor: isLight ? const Color(0xFFE5E5E5) : AppColors.bgDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Text('🐸 ', style: TextStyle(fontSize: 16)),
                            Expanded(
                              child: Text(
                                remainingBudget < 1000.0
                                    ? 'Careful! You are approaching your daily heart-loss zone.'
                                    : 'Fingo says: Streak preserved! Keep up the smart saves.',
                                style: AppTextStyles.bodySM.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: remainingBudget < 1000.0 ? AppColors.error : AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ─── Today\'s Quests Title ─────────────────────────────────
                  Row(
                    children: [
                      Text("Today's Quests", style: AppTextStyles.h2),
                      const SizedBox(width: 6),
                      const Icon(Icons.rocket_launch_rounded, color: AppColors.accent, size: 20),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Quests List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _quests.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final quest = _quests[index];
                      return AppQuestCard(
                        title: quest.title,
                        description: quest.description,
                        xpReward: quest.xpReward,
                        progress: quest.progress,
                        target: quest.target,
                        completed: quest.completed,
                        onTap: () => _onQuestTapped(index),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // ─── Transactions Logs Title ──────────────────────────────
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Transaction Log", style: AppTextStyles.h2),
                      TextButton(
                        onPressed: () {},
                        child: Text('View All', style: AppTextStyles.labelSM.copyWith(color: AppColors.primary)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Transactions List
                  _transactions.isEmpty
                      ? const AppEmptyState(
                          icon: Icons.receipt_long_rounded,
                          title: 'No transactions logged today',
                          message: 'Tap "Log Expense" below to start your budget streak!',
                        )
                      : ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _transactions.length,
                          separatorBuilder: (context, index) => const AppDivider(indent: 8),
                          itemBuilder: (context, index) {
                            final tx = _transactions[index];
                            final catColor = _getCategoryColor(tx.category);
                            return ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(AppSizes.s8),
                                decoration: BoxDecoration(
                                  color: catColor.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                                  border: Border.all(color: catColor.withOpacity(0.3), width: 1.5),
                                ),
                                child: Icon(_getCategoryIcon(tx.category), color: catColor, size: 22),
                              ),
                              title: Text(tx.title, style: AppTextStyles.labelMD),
                              subtitle: Text(
                                '${tx.category} • ${AppFormatters.formatRelativeDate(tx.date)}',
                                style: AppTextStyles.bodySM,
                              ),
                              trailing: Text(
                                '-${tx.amount.toCurrency(decimals: 0)}',
                                style: AppTextStyles.amountSM.copyWith(
                                  color: isLight ? AppColors.textPrimaryLight : AppColors.textPrimaryDark,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            );
                          },
                        ),
                  const SizedBox(height: 80), // spacer for bottom navigation
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSizes.screenHPadding),
        child: App3DButton(
          label: 'Log Expense',
          icon: Icons.add_rounded,
          color: AppColors.primary,
          shadowColor: AppColors.primaryDark,
          onTap: _showAddExpenseDialog,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ─── Helpers ───────────────────────────────────────────────────────────────

  Color _getCategoryColor(String category) {
    switch (category) {
      case 'Food':
        return AppColors.catFood;
      case 'Travel':
        return AppColors.catTravel;
      case 'Bills':
        return AppColors.catBills;
      case 'Shopping':
        return AppColors.catShopping;
      case 'Health':
        return AppColors.catHealth;
      case 'Entertainment':
        return AppColors.catEntertainment;
      default:
        return AppColors.catOther;
    }
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Food':
        return Icons.fastfood_rounded;
      case 'Travel':
        return Icons.directions_transit_rounded;
      case 'Bills':
        return Icons.receipt_rounded;
      case 'Shopping':
        return Icons.local_mall_rounded;
      case 'Health':
        return Icons.medical_services_rounded;
      case 'Entertainment':
        return Icons.celebration_rounded;
      default:
        return Icons.widgets_rounded;
    }
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DATA STRUCTURES
// ══════════════════════════════════════════════════════════════════════════════

class _QuestItem {
  final String id;
  final String title;
  final String description;
  final int xpReward;
  int progress;
  final int target;
  bool completed;

  _QuestItem({
    required this.id,
    required this.title,
    required this.description,
    required this.xpReward,
    required this.progress,
    required this.target,
    required this.completed,
  });
}

class _TransactionItem {
  final String title;
  final double amount;
  final String category;
  final DateTime date;

  _TransactionItem({
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });
}
