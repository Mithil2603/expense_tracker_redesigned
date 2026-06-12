import 'package:flutter/material.dart';
import '../../../../core/core.dart';

class EditExpenseScreen extends StatelessWidget {
  const EditExpenseScreen({super.key});

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
