import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/core.dart';
import 'core/theme/theme_provider.dart';
import 'di/injection_container.dart';
import 'features/expenses/presentation/bloc/transaction_bloc.dart';
import 'features/gamification/presentation/widgets/finny_placeholder_widget.dart';

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
                child: Stack(
                  children: [
                    // ignore: use_null_aware_elements
                    if (child != null) child,
                    const Positioned(
                      right: 16,
                      bottom: 110,
                      child: FinnyPlaceholderWidget(),
                    ),
                  ],
                ),
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
    if (state.pendingRewards.isEmpty || _navigationScheduled) return;

    // Sort: daily first, then weekly, then monthly
    final sorted = [...state.pendingRewards]
      ..sort((a, b) => a.index.compareTo(b.index));
    final next = sorted.first;

    _navigationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _navigationScheduled = false;
      // GoRouter.of(context) is safe here because we're inside the MaterialApp.router builder
      AppRouter.router.push('/reward/${next.name}');
    });
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
