import 'package:flutter/material.dart';
import '../../core.dart';

class RouteErrorScreen extends StatelessWidget {
  const RouteErrorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Navigation Error')),
      body: Center(child: Text('Route not found!', style: AppTextStyles.h2)),
    );
  }
}
