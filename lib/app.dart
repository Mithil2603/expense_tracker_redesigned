import 'package:flutter/material.dart';
import 'core/core.dart';

/// FingoApp — root application wrapper initializing configuration routing and design themes.
class FingoApp extends StatelessWidget {
  const FingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Fingo',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.system, // Seamlessly adapt to light/dark system settings
      routerConfig: AppRouter.router,
    );
  }
}
