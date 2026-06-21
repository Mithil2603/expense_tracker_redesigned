import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/core.dart';
import 'di/injection_container.dart';
import 'features/expenses/presentation/bloc/transaction_bloc.dart';

/// FingoApp — root application wrapper initializing configuration routing and design themes.
class FingoApp extends StatelessWidget {
  const FingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionBloc>(
      create: (context) => sl<TransactionBloc>(),
      child: MaterialApp.router(
        title: 'Fingo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system, // Seamlessly adapt to light/dark system settings
        routerConfig: AppRouter.router,
      ),
    );
  }
}

