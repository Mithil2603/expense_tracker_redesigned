import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../core.dart';
import '../../features/dashboard/presentation/pages/dashboard_screen.dart';
import '../../features/expenses/domain/entities/transaction_entity.dart';

// Key for root navigator
final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'root',
);
final GlobalKey<NavigatorState> _shellNavigatorKey = GlobalKey<NavigatorState>(
  debugLabel: 'shell',
);

/// AppRouter — central navigation configuration using GoRouter.
abstract final class AppRouter {
  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.dashboardPath,
    errorBuilder: (context, state) => const _RouteErrorScreen(),
    routes: [
      // ─── Shell Route for Bottom Navigation ──────────────────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) {
          return _ScaffoldWithNavigation(child: child);
        },
        routes: [
          GoRoute(
            path: AppRoutes.dashboardPath,
            name: AppRoutes.dashboardName,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const DashboardScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
            routes: [
              GoRoute(
                path: AppRoutes.addExpensePath,
                name: AppRoutes.addExpenseName,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const _AddExpenseMockScreen(),
              ),
              GoRoute(
                path: AppRoutes.editExpensePath,
                name: AppRoutes.editExpenseName,
                parentNavigatorKey: _rootNavigatorKey,
                builder: (context, state) => const _EditExpenseMockScreen(),
              ),
            ],
          ),
          GoRoute(
            path: AppRoutes.questsPath,
            name: AppRoutes.questsName,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const _CommunityHubScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: AppRoutes.analyticsPath,
            name: AppRoutes.analyticsName,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const _AnalyticsMockScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
          GoRoute(
            path: AppRoutes.profilePath,
            name: AppRoutes.profileName,
            pageBuilder: (context, state) => CustomTransitionPage(
              key: state.pageKey,
              child: const _ProfileMockScreen(),
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                return FadeTransition(opacity: animation, child: child);
              },
            ),
          ),
        ],
      ),
      // ─── Standalone Auth Route ──────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.authPath,
        name: AppRoutes.authName,
        builder: (context, state) => const _AuthMockScreen(),
      ),
    ],
  );
}

// ══════════════════════════════════════════════════════════════════════════════
// SCAFFOLD WITH BOTTOM NAVIGATION BAR (ICON ONLY)
// ══════════════════════════════════════════════════════════════════════════════

class _ScaffoldWithNavigation extends StatelessWidget {
  final Widget child;

  const _ScaffoldWithNavigation({required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();

    int calculateSelectedIndex() {
      if (location.startsWith(AppRoutes.dashboardPath)) return 0;
      if (location.startsWith(AppRoutes.questsPath)) return 1;
      if (location.startsWith(AppRoutes.analyticsPath)) return 2;
      if (location.startsWith(AppRoutes.profilePath)) return 3;
      return 0;
    }

    void onItemTapped(int index) {
      switch (index) {
        case 0:
          context.goNamed(AppRoutes.dashboardName);
          break;
        case 1:
          context.goNamed(AppRoutes.questsName);
          break;
        case 2:
          context.goNamed(AppRoutes.analyticsName);
          break;
        case 3:
          context.goNamed(AppRoutes.profileName);
          break;
      }
    }

    final isLight = Theme.of(context).brightness == Brightness.light;
    final navBgColor = isLight ? Colors.white : AppColors.surfaceDark;
    final navOutlineColor = isLight
        ? const Color(0xFFE5E5E5)
        : AppColors.outlineDark;

    return Scaffold(
      body: Stack(
        children: [
          child,
          Positioned(
            left: 16,
            right: 16,
            bottom: 20,
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                // Floating Bar with Symmetrical Layout
                Container(
                  height: 64,
                  decoration: BoxDecoration(
                    color: navBgColor,
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: navOutlineColor,
                      width: AppSizes.borderThick,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isLight ? 0.08 : 0.25,
                        ),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Symmetrical Left side of the FAB
                      _NavBarItem(
                        icon: Icons.home_rounded,
                        isSelected: calculateSelectedIndex() == 0,
                        onTap: () => onItemTapped(0),
                        activeColor: AppColors.secondary,
                      ),
                      _NavBarItem(
                        icon: Icons.emoji_events_rounded,
                        isSelected: calculateSelectedIndex() == 1,
                        onTap: () => onItemTapped(1),
                        activeColor: AppColors.accent,
                      ),

                      const SizedBox(
                        width: 52,
                      ), // Spacer width for overlapping FAB
                      // Symmetrical Right side of the FAB
                      _NavBarItem(
                        icon: Icons.bar_chart_rounded,
                        isSelected: calculateSelectedIndex() == 2,
                        onTap: () => onItemTapped(2),
                        activeColor: AppColors.info,
                      ),
                      _NavBarItem(
                        icon: Icons.person_rounded,
                        isSelected: calculateSelectedIndex() == 3,
                        onTap: () => onItemTapped(3),
                        activeColor: AppColors.success,
                      ),
                    ],
                  ),
                ),
                // Overflowing central FAB
                Positioned(
                  top: -20,
                  child: _App3DFAB(
                    onTap: () => _showAddOptionsBottomSheet(context),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showAddOptionsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        final isLight = Theme.of(context).brightness == Brightness.light;
        final bgColor = isLight ? Colors.white : AppColors.surfaceDark;
        final outlineColor = isLight ? const Color(0xFFE5E5E5) : AppColors.outlineDark;
        return Container(
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
            border: Border.all(color: outlineColor, width: AppSizes.borderThick),
          ),
          padding: const EdgeInsets.all(AppSizes.paddingLG),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: outlineColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Select Transaction Type',
                style: AppTextStyles.h2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: App3DButton(
                      label: 'Income',
                      color: AppColors.success,
                      shadowColor: AppColors.successDark,
                      icon: Icons.arrow_upward_rounded,
                      onTap: () {
                        Navigator.of(context).pop();
                        _showAddIncomeSheet(context);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: App3DButton(
                      label: 'Expense',
                      color: AppColors.error,
                      shadowColor: AppColors.errorDark,
                      icon: Icons.arrow_downward_rounded,
                      onTap: () {
                        Navigator.of(context).pop();
                        _showAddExpenseSheet(context);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  void _showAddIncomeSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    IncomeCategory selectedCat = IncomeCategory.salary;
    DateTime selectedDate = DateTime.now();

    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? Colors.white : AppColors.surfaceDark;
    final outlineColor = isLight ? const Color(0xFFE5E5E5) : AppColors.outlineDark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
                border: Border.all(color: outlineColor, width: AppSizes.borderThick),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.paddingLG,
                left: AppSizes.paddingLG,
                right: AppSizes.paddingLG,
                top: AppSizes.paddingMD,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text('Add Income', style: AppTextStyles.h2),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Income Source',
                    hint: 'e.g. Salary, Freelance',
                    controller: titleCtrl,
                    prefixIcon: Icons.wallet_rounded,
                  ),
                  const SizedBox(height: 12),
                  AppAmountField(
                    label: 'Amount (INR)',
                    hint: '0.00',
                    controller: amountCtrl,
                  ),
                  const SizedBox(height: 16),
                  Text('Category', style: AppTextStyles.labelMD),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: IncomeCategory.values.length,
                      separatorBuilder: (context, idx) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final cat = IncomeCategory.values[idx];
                        final isSelected = cat == selectedCat;
                        return AppChip(
                          label: cat.displayName,
                          icon: cat.icon,
                          selected: isSelected,
                          color: cat.color,
                          onTap: () {
                            setModalState(() {
                              selectedCat = cat;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Transaction Date', style: AppTextStyles.labelMD),
                      AppOutlineButton(
                        label: AppFormatters.formatDate(selectedDate),
                        icon: Icons.calendar_today_rounded,
                        expand: false,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setModalState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  App3DButton(
                    label: 'Save Income',
                    color: AppColors.success,
                    shadowColor: AppColors.successDark,
                    onTap: () {
                      final amount = double.tryParse(amountCtrl.text) ?? 0.0;
                      final title = titleCtrl.text.trim();
                      if (title.isEmpty || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a valid title and amount.')),
                        );
                        return;
                      }

                      FingoState.instance.addTransaction(
                        title: title,
                        amount: amount,
                        type: TransactionType.income,
                        incomeCategory: selectedCat,
                        date: selectedDate,
                      );

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Income logged successfully!')),
                      );
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

  void _showAddExpenseSheet(BuildContext context) {
    final titleCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    ExpenseCategory selectedCat = ExpenseCategory.foodAndDining;
    DateTime selectedDate = DateTime.now();

    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? Colors.white : AppColors.surfaceDark;
    final outlineColor = isLight ? const Color(0xFFE5E5E5) : AppColors.outlineDark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
                border: Border.all(color: outlineColor, width: AppSizes.borderThick),
              ),
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.paddingLG,
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
                  Text('Category', style: AppTextStyles.labelMD),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: ExpenseCategory.values.length,
                      separatorBuilder: (context, idx) => const SizedBox(width: 8),
                      itemBuilder: (context, idx) {
                        final cat = ExpenseCategory.values[idx];
                        final isSelected = cat == selectedCat;
                        return AppChip(
                          label: cat.displayName,
                          icon: cat.icon,
                          selected: isSelected,
                          color: cat.color,
                          onTap: () {
                            setModalState(() {
                              selectedCat = cat;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Transaction Date', style: AppTextStyles.labelMD),
                      AppOutlineButton(
                        label: AppFormatters.formatDate(selectedDate),
                        icon: Icons.calendar_today_rounded,
                        expand: false,
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setModalState(() {
                              selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  App3DButton(
                    label: 'Save Expense',
                    color: AppColors.error,
                    shadowColor: AppColors.errorDark,
                    onTap: () {
                      final amount = double.tryParse(amountCtrl.text) ?? 0.0;
                      final title = titleCtrl.text.trim();
                      if (title.isEmpty || amount <= 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Please enter a valid title and amount.')),
                        );
                        return;
                      }

                      FingoState.instance.addTransaction(
                        title: title,
                        amount: amount,
                        type: TransactionType.expense,
                        expenseCategory: selectedCat,
                        date: selectedDate,
                      );

                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Expense logged successfully!')),
                      );
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
}

class _App3DFAB extends StatefulWidget {
  final VoidCallback onTap;
  const _App3DFAB({required this.onTap});

  @override
  State<_App3DFAB> createState() => _App3DFABState();
}

class _App3DFABState extends State<_App3DFAB> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: SizedBox(
        width: 60,
        height: 64,
        child: Stack(
          children: [
            // Bevel bottom shadow layer
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppColors.primaryDark,
                shape: BoxShape.circle,
              ),
            ),
            // Playful top layer
            AnimatedContainer(
              duration: const Duration(milliseconds: 60),
              margin: EdgeInsets.only(
                top: _isPressed ? 4 : 0,
                bottom: _isPressed ? 0 : 4,
              ),
              width: 60,
              height: 56,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.15),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 32,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final Color activeColor;

  const _NavBarItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final unselectedColor = isLight
        ? const Color(0xFF8C8C8C)
        : AppColors.textTertiary;

    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedScale(
          scale: isSelected ? 1.15 : 1.0,
          duration: const Duration(milliseconds: 150),
          child: Center(
            child: Icon(
              icon,
              color: isSelected ? activeColor : unselectedColor,
              size: AppSizes.iconMD + 4,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// ROUTE MOCK & ERROR SCREENS
// ══════════════════════════════════════════════════════════════════════════════

class _RouteErrorScreen extends StatelessWidget {
  const _RouteErrorScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Error')),
      body: Center(child: Text('Route not found!', style: AppTextStyles.h2)),
    );
  }
}

class _HubTabToggle extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const _HubTabToggle({
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    final bgColor = isLight ? const Color(0xFFF0F0F0) : AppColors.surfaceDark;
    final activeColor = AppColors.primary;

    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
          color: isLight ? const Color(0xFFE5E5E5) : AppColors.outlineDark,
          width: AppSizes.borderThick,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: selectedIndex == 0 ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  boxShadow: selectedIndex == 0
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Daily Quests 🏆',
                  style: AppTextStyles.labelMD.copyWith(
                    color: selectedIndex == 0
                        ? Colors.white
                        : (isLight ? Colors.black87 : Colors.white70),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: selectedIndex == 1 ? activeColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                  boxShadow: selectedIndex == 1
                      ? [
                          BoxShadow(
                            color: activeColor.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  'Social Feed 💬',
                  style: AppTextStyles.labelMD.copyWith(
                    color: selectedIndex == 1
                        ? Colors.white
                        : (isLight ? Colors.black87 : Colors.white70),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CommunityHubScreen extends StatefulWidget {
  const _CommunityHubScreen();

  @override
  State<_CommunityHubScreen> createState() => _CommunityHubScreenState();
}

class _CommunityHubScreenState extends State<_CommunityHubScreen> {
  int _selectedTab = 0; // 0 = Quests, 1 = Feed
  final TextEditingController _postCtrl = TextEditingController();

  final List<_SocialPostItem> _feedItems = [
    _SocialPostItem(
      userName: 'Sarah Jones',
      avatar: '🥑',
      content:
          'Kept my daily food budget under ₹150 for 4 consecutive days! 🔥',
      timeAgo: '15 mins ago',
      isAchievement: true,
      likes: 12,
    ),
    _SocialPostItem(
      userName: 'Rahul Verma',
      avatar: '💻',
      content:
          'Any tips to reduce high electricity utilities this summer? My bills are shooting up.',
      timeAgo: '1 hr ago',
      likes: 5,
    ),
    _SocialPostItem(
      userName: 'Jessica Miller',
      avatar: '🌟',
      content: 'Levelled up to Level 2! Fingo rules! ⭐',
      timeAgo: '3 hrs ago',
      isAchievement: true,
      likes: 24,
    ),
    _SocialPostItem(
      userName: 'David Miller',
      avatar: '🚗',
      content: 'Saved ₹2,500 on transportation this week by carpooling! 💰🚘',
      timeAgo: '5 hrs ago',
      isAchievement: true,
      likes: 18,
    ),
  ];

  @override
  void initState() {
    super.initState();
    FingoState.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    FingoState.instance.removeListener(_refresh);
    _postCtrl.dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  void _addPost() {
    final text = _postCtrl.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _feedItems.insert(
        0,
        _SocialPostItem(
          userName: 'Mithil (You)',
          avatar: '🐸',
          content: text,
          timeAgo: 'Just now',
          likes: 0,
        ),
      );
      _postCtrl.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Milestone shared globally! 🌎')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = FingoState.instance;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final outlineColor = isLight
        ? const Color(0xFFE5E5E5)
        : AppColors.outlineDark;

    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.screenHPadding,
                vertical: 12,
              ),
              child: _HubTabToggle(
                selectedIndex: _selectedTab,
                onTabChanged: (val) {
                  setState(() {
                    _selectedTab = val;
                  });
                },
              ),
            ),
            Expanded(
              child: _selectedTab == 0
                  ? _buildQuestsView(state, isLight)
                  : _buildFeedView(isLight, outlineColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestsView(FingoState state, bool isLight) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(
        left: AppSizes.screenHPadding,
        right: AppSizes.screenHPadding,
        bottom: 100, // spacing for bottom bar
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Mascot Comic Box (Duolingo Style Speech bubble)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/fingo_mascot.png',
                width: 90,
                height: 90,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: const Text(
                      '🐸',
                      style: TextStyle(fontSize: 40),
                    ),
                  );
                },
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(AppSizes.paddingMD),
                  decoration: BoxDecoration(
                    color: isLight
                        ? AppColors.surfaceLight
                        : AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(
                      AppSizes.radiusLG,
                    ),
                    border: Border.all(
                      color: isLight
                          ? AppColors.outlineLight
                          : AppColors.outlineDark,
                      width: AppSizes.borderThick,
                    ),
                  ),
                  child: Text(
                    'Break today’s budget rocks to collect rewards and climb the Ruby division! 💎',
                    style: AppTextStyles.bodySM.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. Monthly Quest Card
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'JUNE CHALLENGE',
                      style: AppTextStyles.overline.copyWith(
                        color: AppColors.accentDark,
                      ),
                    ),
                    const Text('🥚', style: TextStyle(fontSize: 20)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Hatch Fingo the Frog',
                  style: AppTextStyles.labelMD.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                Text(
                  'Harness smart budget habits to earn 100 XP points this month.',
                  style: AppTextStyles.bodySM,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull,
                        ),
                        child: SizedBox(
                          height: 8,
                          child: LinearProgressIndicator(
                            value: (state.xp / 100.0).clamp(0.0, 1.0),
                            color: AppColors.accent,
                            backgroundColor: isLight
                                ? const Color(0xFFE5E5E5)
                                : AppColors.bgDark,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${state.xp}/100 XP',
                      style: AppTextStyles.caption.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Daily Quests Header
          Row(
            children: [
              Text("Daily Quests", style: AppTextStyles.h2),
              const SizedBox(width: 6),
              const Icon(
                Icons.rocket_launch_rounded,
                color: AppColors.accent,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Daily Quests (Rock breaking theme)
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: state.quests.length,
            separatorBuilder: (context, index) =>
                const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final quest = state.quests[index];

              final String rockIcon;
              if (quest.completed) {
                rockIcon = '🪙';
              } else if (quest.progress > 0) {
                rockIcon = '🔨';
              } else {
                rockIcon = '🪨';
              }

              return AppCard(
                onTap: () {
                  if (quest.completed) return;
                  setState(() {
                    if (quest.id == 'q3') {
                      quest.progress++;
                      if (quest.progress >= quest.target) {
                        quest.completed = true;
                        state.awardXP(quest.xpReward);
                      }
                    } else {
                      quest.completed = true;
                      state.awardXP(quest.xpReward);
                    }
                  });
                },
                color: quest.completed
                    ? (isLight
                        ? AppColors.successSurfaceLight
                        : AppColors.successSurfaceDark)
                    : null,
                borderColor: quest.completed
                    ? AppColors.primary.withValues(alpha: 0.6)
                    : null,
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: quest.completed
                            ? AppColors.primary.withValues(alpha: 0.15)
                            : (isLight ? Colors.white : AppColors.bgDark),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: quest.completed
                              ? AppColors.primary
                              : AppColors.outline,
                          width: 2,
                        ),
                      ),
                      child: Text(
                        rockIcon,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  quest.title,
                                  style: AppTextStyles.labelMD.copyWith(
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              Text(
                                '+${quest.xpReward} XP',
                                style: AppTextStyles.caption.copyWith(
                                  color: AppColors.accentDark,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(quest.description, style: AppTextStyles.bodySM),
                          if (quest.target > 1) ...[
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusFull,
                              ),
                              child: SizedBox(
                                height: 6,
                                child: LinearProgressIndicator(
                                  value:
                                      (quest.progress / quest.target).clamp(0.0, 1.0),
                                  color: AppColors.primary,
                                  backgroundColor: isLight
                                      ? const Color(0xFFE5E5E5)
                                      : AppColors.bgDark,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${quest.progress}/${quest.target}',
                              style: AppTextStyles.caption.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          // Weekly Leaderboard Header
          Row(
            children: [
              Text("Weekly Leaderboard", style: AppTextStyles.h2),
              const SizedBox(width: 6),
              const Text('🏆', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 12),
          AppCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildLeaderboardRow(
                  1,
                  '🥇 Sophia',
                  '120 XP',
                  isCurrentUser: false,
                  isGold: true,
                ),
                const AppDivider(indent: 16),
                _buildLeaderboardRow(
                  2,
                  '🥈 Liam',
                  '80 XP',
                  isCurrentUser: false,
                ),
                const AppDivider(indent: 16),
                _buildLeaderboardRow(
                  3,
                  '🥉 Mithil (You)',
                  '${state.xp} XP',
                  isCurrentUser: true,
                ),
                const AppDivider(indent: 16),
                _buildLeaderboardRow(
                  4,
                  'Dave',
                  '20 XP',
                  isCurrentUser: false,
                ),
                const AppDivider(indent: 16),
                _buildLeaderboardRow(
                  5,
                  'Emma',
                  '10 XP',
                  isCurrentUser: false,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardRow(
    int rank,
    String name,
    String xpText, {
    required bool isCurrentUser,
    bool isGold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              style: AppTextStyles.labelMD.copyWith(
                fontWeight: FontWeight.w900,
                color: isGold
                    ? AppColors.accentDark
                    : (isCurrentUser ? AppColors.primary : Colors.grey),
              ),
            ),
          ),
          Expanded(
            child: Text(
              name,
              style: AppTextStyles.labelMD.copyWith(
                fontWeight: isCurrentUser ? FontWeight.w900 : FontWeight.w700,
                color: isCurrentUser ? AppColors.primary : null,
              ),
            ),
          ),
          Text(
            xpText,
            style: AppTextStyles.labelMD.copyWith(
              fontWeight: FontWeight.w900,
              color: isCurrentUser ? AppColors.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedView(bool isLight, Color outlineColor) {
    return Column(
      children: [
        // Post creation card
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.screenHPadding,
          ),
          child: AppCard(
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _postCtrl,
                    style: AppTextStyles.bodySM,
                    decoration: InputDecoration(
                      hintText:
                          'Share a save, milestone or ask a question...',
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      contentPadding: EdgeInsets.zero,
                      hintStyle: AppTextStyles.caption,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                App3DButton(
                  label: 'Post',
                  expand: false,
                  height: 36,
                  shadowHeight: 2,
                  color: AppColors.primary,
                  shadowColor: AppColors.primaryDark,
                  onTap: _addPost,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Posts list
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.only(
              left: AppSizes.screenHPadding,
              right: AppSizes.screenHPadding,
              bottom: 100, // spacing for bottom bar
            ),
            itemCount: _feedItems.length,
            separatorBuilder: (context, idx) => const SizedBox(height: 12),
            itemBuilder: (context, idx) {
              final post = _feedItems[idx];
              return AppCard(
                color: post.isAchievement
                    ? (isLight
                        ? AppColors.successSurfaceLight
                        : AppColors.successSurfaceDark)
                    : null,
                borderColor: post.isAchievement
                    ? AppColors.primary.withValues(alpha: 0.3)
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isLight
                                ? Colors.white
                                : AppColors.bgDark,
                            shape: BoxShape.circle,
                            border: Border.all(color: outlineColor),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            post.avatar,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post.userName,
                                style: AppTextStyles.labelSM.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                post.timeAgo,
                                style: AppTextStyles.caption,
                              ),
                            ],
                          ),
                        ),
                        if (post.isAchievement) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'MILESTONE 🏆',
                              style: AppTextStyles.caption.copyWith(
                                color: AppColors.primary,
                                fontSize: 8,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(post.content, style: AppTextStyles.bodySM),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              if (post.isLiked) {
                                post.likes--;
                                post.isLiked = false;
                              } else {
                                post.likes++;
                                post.isLiked = true;
                              }
                            });
                          },
                          child: Row(
                            children: [
                              Icon(
                                post.isLiked
                                    ? Icons.favorite_rounded
                                    : Icons.favorite_border_rounded,
                                color: AppColors.error,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${post.likes}',
                                style: AppTextStyles.caption.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AnalyticsMockScreen extends StatefulWidget {
  const _AnalyticsMockScreen();
  @override
  State<_AnalyticsMockScreen> createState() => _AnalyticsMockScreenState();
}

class _AnalyticsMockScreenState extends State<_AnalyticsMockScreen> {
  @override
  void initState() {
    super.initState();
    FingoState.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    FingoState.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = FingoState.instance;
    final isLight = Theme.of(context).brightness == Brightness.light;
    final remainingBudget = state.monthlyBudget - state.totalSpent;
    final budgetRatio = (remainingBudget / state.monthlyBudget).clamp(0.0, 1.0);

    // Calculate category totals dynamically
    final expenseTxs = state.transactions
        .where((t) => t.type == TransactionType.expense)
        .toList();

    final categoryTotals = <ExpenseCategory, double>{};
    for (final tx in expenseTxs) {
      final cat = tx.expenseCategory!;
      categoryTotals[cat] = (categoryTotals[cat] ?? 0.0) + tx.amount;
    }

    return Scaffold(
      appBar: null, // Removed AppBar as requested
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.screenHPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'SAFE BUDGET',
                            style: AppTextStyles.overline.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          Text(
                            '${remainingBudget.toCurrency()} Left',
                            style: AppTextStyles.labelSM.copyWith(
                              color: remainingBudget < 1000.0
                                  ? AppColors.error
                                  : AppColors.primary,
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
                            state.totalSpent.toCurrency(),
                            style: AppTextStyles.display2,
                          ),
                          const SizedBox(width: 6),
                          Text('spent this month', style: AppTextStyles.bodySM),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSizes.radiusFull,
                        ),
                        child: SizedBox(
                          height: 12,
                          child: LinearProgressIndicator(
                            value: budgetRatio,
                            color: remainingBudget < 1000.0
                                ? AppColors.error
                                : AppColors.primary,
                            backgroundColor: isLight
                                ? const Color(0xFFE5E5E5)
                                : AppColors.bgDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Text('🐸 ', style: TextStyle(fontSize: 18)),
                          Expanded(
                            child: Text(
                              remainingBudget < 1000.0
                                  ? 'Careful! Fingo advises you to pause shopping now!'
                                  : 'You are in the Fingo Green Zone! Keep up the smart saves.',
                              style: AppTextStyles.bodySM.copyWith(
                                fontWeight: FontWeight.w600,
                                color: remainingBudget < 1000.0
                                    ? AppColors.error
                                    : AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                // Budget breakdown section
                Text("Insights Breakdown", style: AppTextStyles.h2),
                const SizedBox(height: 12),
                if (expenseTxs.isEmpty)
                  AppCard(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.pie_chart_outline_rounded,
                            color: AppColors.textTertiary,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'No expenses logged yet',
                            style: AppTextStyles.labelMD,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Log your expenses to view category insights.',
                            style: AppTextStyles.bodySM,
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  ...categoryTotals.entries.map((entry) {
                    final cat = entry.key;
                    final total = entry.value;
                    return _buildCategoryUsageRow(
                      cat.displayName,
                      total,
                      cat.color,
                      cat.icon,
                    );
                  }),
                const SizedBox(height: 100), // spacing for bottom bar
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryUsageRow(
    String cat,
    double amount,
    Color color,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(cat, style: AppTextStyles.labelMD),
            const Spacer(),
            Text(amount.toCurrency(), style: AppTextStyles.amountSM),
          ],
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════════════
// DEDICATED SUBSCRIPTIONS TAB SCREEN
// ══════════════════════════════════════════════════════════════════════════════

void _showSubscriptionPlansBottomSheet(BuildContext context) {
  int selectedPlanIdx = 1; // Default to Annual
  final isLight = Theme.of(context).brightness == Brightness.light;
  final bgColor = isLight ? Colors.white : AppColors.surfaceDark;
  final outlineColor = isLight ? const Color(0xFFE5E5E5) : AppColors.outlineDark;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(AppSizes.radiusXL)),
              border: Border.all(color: outlineColor, width: AppSizes.borderThick),
            ),
            padding: const EdgeInsets.all(AppSizes.paddingLG),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: outlineColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('⚡ ', style: TextStyle(fontSize: 24)),
                    Text(
                      'UPGRADE TO FINGO SUPER',
                      style: AppTextStyles.h2.copyWith(color: AppColors.accentDark, fontWeight: FontWeight.w900),
                    ),
                    const Text(' ⚡', style: TextStyle(fontSize: 24)),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Unlock your full financial potential with zero interruptions.',
                  style: AppTextStyles.bodySM,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                _buildSubscriptionPlanRowHelper(
                  context: context,
                  idx: 0,
                  title: 'Fingo Plus (Monthly)',
                  price: '₹199 / mo',
                  description: 'No ads, unlimited health, premium badges.',
                  isSelected: selectedPlanIdx == 0,
                  onTap: () => setModalState(() => selectedPlanIdx = 0),
                ),
                const SizedBox(height: 12),
                _buildSubscriptionPlanRowHelper(
                  context: context,
                  idx: 1,
                  title: 'Fingo Premium (Annual Saver)',
                  price: '₹1,499 / yr',
                  description: 'Everything in Plus + weekly reports & widget designs. Save 37%!',
                  isSelected: selectedPlanIdx == 1,
                  isPopular: true,
                  onTap: () => setModalState(() => selectedPlanIdx = 1),
                ),
                const SizedBox(height: 12),
                _buildSubscriptionPlanRowHelper(
                  context: context,
                  idx: 2,
                  title: 'Fingo Family (Group Plan)',
                  price: '₹399 / mo',
                  description: 'Up to 5 accounts, joint budgets, shared streaks.',
                  isSelected: selectedPlanIdx == 2,
                  onTap: () => setModalState(() => selectedPlanIdx = 2),
                ),
                const SizedBox(height: 24),
                App3DButton(
                  label: 'Start 7-Day Free Trial',
                  color: AppColors.accent,
                  shadowColor: AppColors.accentDark,
                  onTap: () {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Welcome to Fingo Super! 🚀')),
                    );
                  },
                ),
                const SizedBox(height: 12),
                Text(
                  'Cancel anytime in Google Play Store. Terms apply.',
                  style: AppTextStyles.caption,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      );
    },
  );
}

Widget _buildSubscriptionPlanRowHelper({
  required BuildContext context,
  required int idx,
  required String title,
  required String price,
  required String description,
  required bool isSelected,
  bool isPopular = false,
  required VoidCallback onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.accent.withValues(alpha: .1) : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSizes.radiusLG),
        border: Border.all(
          color: isSelected ? AppColors.accent : AppColors.outline,
          width: isSelected ? AppSizes.borderThick : AppSizes.borderThin,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: AppTextStyles.labelMD.copyWith(
                        fontWeight: FontWeight.w800,
                        color: isSelected ? AppColors.accentDark : null,
                      ),
                    ),
                    if (isPopular) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'POPULAR',
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(description, style: AppTextStyles.bodySM),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            price,
            style: AppTextStyles.labelMD.copyWith(fontWeight: FontWeight.w900),
          ),
        ],
      ),
    ),
  );
}

class _SocialPostItem {
  final String userName;
  final String avatar;
  final String content;
  final String timeAgo;
  final bool isAchievement;
  int likes;
  bool isLiked = false;

  _SocialPostItem({
    required this.userName,
    required this.avatar,
    required this.content,
    required this.timeAgo,
    this.isAchievement = false,
    this.likes = 0,
  });
}



class _ProfileMockScreen extends StatefulWidget {
  const _ProfileMockScreen();
  @override
  State<_ProfileMockScreen> createState() => _ProfileMockScreenState();
}

class _ProfileMockScreenState extends State<_ProfileMockScreen> {
  @override
  void initState() {
    super.initState();
    FingoState.instance.addListener(_refresh);
  }

  @override
  void dispose() {
    FingoState.instance.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final state = FingoState.instance;

    return Scaffold(
      appBar: null,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(AppSizes.screenHPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Header
                Center(
                  child: Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.primary,
                            width: 3,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const Text('🐸', style: TextStyle(fontSize: 48)),
                      ),
                      const SizedBox(height: 12),
                      Text('Budgeting Champion', style: AppTextStyles.h2),
                      Text('Mithil', style: AppTextStyles.bodySM),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Stats Cards Grid
                Row(
                  children: [
                    Expanded(
                      child: AppCard(
                        child: Column(
                          children: [
                            const Text('👑', style: TextStyle(fontSize: 24)),
                            const SizedBox(height: 4),
                            Text(
                              'Level ${state.level}',
                              style: AppTextStyles.labelMD,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppCard(
                        child: Column(
                          children: [
                            const Text('🔥', style: TextStyle(fontSize: 24)),
                            const SizedBox(height: 4),
                            Text(
                              '${state.streak} Days',
                              style: AppTextStyles.labelMD,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Premium Banner
                GestureDetector(
                  onTap: () => _showSubscriptionPlansBottomSheet(context),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 24),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.accentDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppSizes.radiusLG),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accentDark.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        const Text('⚡', style: TextStyle(fontSize: 28)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'UPGRADE TO FINGO SUPER',
                                style: AppTextStyles.labelMD.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              Text(
                                'Unlock daily lives, unlimited quests, and double XP!',
                                style: AppTextStyles.bodySM.copyWith(
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded, color: Colors.white),
                      ],
                    ),
                  ),
                ),

                // Achievements section
                Text("My Achievements", style: AppTextStyles.h2),
                const SizedBox(height: 12),
                _buildAchievementRow(
                  'Streak Starter',
                  'Keep a streak of 3 days.',
                  state.streak >= 3,
                ),
                _buildAchievementRow(
                  'Budget Sentinel',
                  'Never breach budget for a week.',
                  state.totalSpent > 0 &&
                      state.totalSpent <= state.monthlyBudget,
                ),
                _buildAchievementRow(
                  'Gold Miner',
                  'Collect 100 XP points.',
                  state.level > 1 || state.xp >= 100,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAchievementRow(String name, String desc, bool unlocked) {
    final isLight = Theme.of(context).brightness == Brightness.light;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: AppCard(
        color: unlocked
            ? null
            : (isLight ? const Color(0xFFF2F2F2) : const Color(0xFF1E2428)),
        borderColor: unlocked ? AppColors.accent : Colors.transparent,
        child: Row(
          children: [
            Text(unlocked ? '🏆' : '🔒', style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.labelMD.copyWith(
                      color: unlocked ? null : Colors.grey,
                    ),
                  ),
                  Text(desc, style: AppTextStyles.bodySM),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddExpenseMockScreen extends StatelessWidget {
  const _AddExpenseMockScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Expense')),
      body: Center(
        child: Text('Add Expense Screen Coming Soon!', style: AppTextStyles.h2),
      ),
    );
  }
}

class _EditExpenseMockScreen extends StatelessWidget {
  const _EditExpenseMockScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Expense')),
      body: Center(
        child: Text(
          'Edit Expense Screen Coming Soon!',
          style: AppTextStyles.h2,
        ),
      ),
    );
  }
}

class _AuthMockScreen extends StatelessWidget {
  const _AuthMockScreen();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Authentication Screen Coming Soon!',
          style: AppTextStyles.h2,
        ),
      ),
    );
  }
}
