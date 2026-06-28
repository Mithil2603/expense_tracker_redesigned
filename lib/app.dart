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
            themeMode: sl<ThemeProvider>().themeMode, // Controlled by user setting
            routerConfig: AppRouter.router,
            builder: (context, child) {
              return Stack(
                children: [
                  // ignore: use_null_aware_elements
                  if (child != null) child,
                  const Positioned(
                    right: 16,
                    bottom: 110,
                    child: FinnyPlaceholderWidget(),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

