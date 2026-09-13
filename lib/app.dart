import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/core.dart';
import 'core/theme/theme_provider.dart';
import 'core/domain/entities/quest_completion_reward.dart';
import 'di/injection_container.dart';
import 'features/expenses/presentation/bloc/transaction_bloc.dart';

/// FingoApp — root application wrapper initializing configuration routing and design themes.
class FingoApp extends StatelessWidget {
  const FingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionBloc>(
      create: (context) => sl<TransactionBloc>(),
      child: ListenableBuilder(
        listenable: sl<ThemeProvider>(),
        builder: (context, _) {
          return MaterialApp.router(
            title: 'Fingo',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: sl<ThemeProvider>().themeMode,
            routerConfig: AppRouter.router,
            builder: (context, child) {
              return _RewardNavigator(
                child: child ?? const SizedBox.shrink(),
              );
            },
          );
        },
      ),
    );
  }
}

/// Listens to [FingoState.pendingRewards] and auto-pushes the first pending
/// reward screen via GoRouter the moment it becomes non-empty.
/// Queues multiple rewards sequentially (daily → weekly → monthly).
class _RewardNavigator extends StatefulWidget {
  final Widget child;
  const _RewardNavigator({required this.child});

  @override
  State<_RewardNavigator> createState() => _RewardNavigatorState();
}

class _RewardNavigatorState extends State<_RewardNavigator> {
  bool _navigationScheduled = false;

  @override
  void initState() {
    super.initState();
    sl<FingoState>().addListener(_onStateChanged);
    // Check on first frame (handles rewards pending from before app fully started)
    WidgetsBinding.instance.addPostFrameCallback((_) => _onStateChanged());
  }

  @override
  void dispose() {
    sl<FingoState>().removeListener(_onStateChanged);
    super.dispose();
  }

  void _onStateChanged() {
    final state = sl<FingoState>();
    if (_navigationScheduled) return;
    if (state.pendingRewards.isEmpty && state.pendingQuestRewards.isEmpty) return;

    _navigationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _navigationScheduled = false;
      if (state.pendingRewards.isNotEmpty) {
        final sorted = [...state.pendingRewards]
          ..sort((a, b) => a.index.compareTo(b.index));
        final next = sorted.first;
        AppRouter.router.push('/reward/${next.name}');
      } else if (state.pendingQuestRewards.isNotEmpty) {
        final questRewards = List<QuestCompletionReward>.from(state.pendingQuestRewards);
        AppRouter.router.push('/reward/quest', extra: questRewards);
      }
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
