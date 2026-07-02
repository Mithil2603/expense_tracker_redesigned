import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fingo/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:fingo/features/expenses/domain/entities/transaction_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fingo/features/expenses/presentation/bloc/transaction_bloc.dart';
import 'package:fingo/features/expenses/presentation/bloc/transaction_event.dart';
import 'package:fingo/features/expenses/presentation/bloc/transaction_state.dart';

import 'package:fingo/features/expenses/domain/usecases/watch_transactions.dart';
import 'package:fingo/features/expenses/domain/usecases/add_transaction.dart';
import 'package:fingo/features/expenses/domain/usecases/update_transaction.dart';
import 'package:fingo/features/expenses/domain/usecases/delete_transaction.dart';

class FakeTransactionBloc extends Bloc<TransactionEvent, TransactionState> implements TransactionBloc {
  final List<TransactionEntity> txs;
  FakeTransactionBloc(this.txs) : super(TransactionLoaded(txs));

  @override
  WatchTransactions get watchTransactions => throw UnimplementedError();
  @override
  AddTransaction get addTransaction => throw UnimplementedError();
  @override
  UpdateTransaction get updateTransaction => throw UnimplementedError();
  @override
  DeleteTransaction get deleteTransaction => throw UnimplementedError();
}
void main() {
  testWidgets('DashboardScreen pending review crash test', (tester) async {
    final mockTx = TransactionEntity(
      id: 'test',
      userId: 'test',
      title: 'test merchant',
      amount: 100,
      type: TransactionType.expense,
      expenseCategory: ExpenseCategory.other,
      date: DateTime.now(),
      paymentMethod: PaymentMethod.other,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isPending: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TransactionBloc>(
          create: (_) => FakeTransactionBloc([mockTx]),
          child: const Scaffold(
            body: DashboardScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    
    // Tap the pending review indicator
    await tester.tap(find.textContaining('pending transaction'));
    await tester.pumpAndSettle();
    
    expect(find.text('APPROVE'), findsOneWidget);
  });
}
