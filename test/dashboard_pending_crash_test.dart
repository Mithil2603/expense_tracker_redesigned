import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fingo/features/dashboard/presentation/pages/dashboard_screen.dart';
import 'package:fingo/features/expenses/domain/entities/transaction_entity.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fingo/features/expenses/presentation/bloc/transaction_bloc.dart';
import 'package:fingo/core/core.dart';
import 'package:fingo/di/injection_container.dart' as di;
import 'package:get_it/get_it.dart';
import 'package:dartz/dartz.dart';
import 'package:fingo/features/expenses/domain/repositories/transaction_repository.dart';

class FakeTransactionRepository implements TransactionRepository {
  final List<TransactionEntity> txs;
  FakeTransactionRepository(this.txs);

  @override
  Stream<Either<Failure, List<TransactionEntity>>> watchTransactions(String userId) {
    return Stream.value(Right(txs));
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(String userId) async {
    return Right(txs);
  }

  @override
  Future<Either<Failure, void>> addTransaction(TransactionEntity transaction, String userId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> updateTransaction(TransactionEntity transaction, String userId) async {
    return const Right(null);
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String transactionId, String userId) async {
    return const Right(null);
  }
}

void main() {
  setUp(() async {
    await GetIt.instance.reset();
    await di.init();
  });

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

    GetIt.instance.unregister<TransactionRepository>();
    GetIt.instance.registerLazySingleton<TransactionRepository>(() => FakeTransactionRepository([mockTx]));

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<TransactionBloc>(
          create: (_) => di.sl<TransactionBloc>(),
          child: const Scaffold(
            body: DashboardScreen(),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();
    
    // Verify pending review indicator and action icons are present
    expect(find.text('PENDING AUTO-TRANSACTIONS'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byIcon(Icons.close), findsOneWidget);
  });
}
