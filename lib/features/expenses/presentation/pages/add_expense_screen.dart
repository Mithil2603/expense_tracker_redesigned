import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class AddExpenseScreen extends StatelessWidget {
  const AddExpenseScreen({super.key});

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
