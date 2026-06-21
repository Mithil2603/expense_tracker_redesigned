import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker_app/app.dart';
import 'package:expense_tracker_app/core/core.dart';
import 'package:expense_tracker_app/di/injection_container.dart' as di;
import 'package:get_it/get_it.dart';

import 'package:dartz/dartz.dart';
import 'package:expense_tracker_app/features/expenses/domain/repositories/transaction_repository.dart';
import 'package:expense_tracker_app/features/expenses/domain/entities/transaction_entity.dart';

class FakeTransactionRepository implements TransactionRepository {
  @override
  Stream<Either<Failure, List<TransactionEntity>>> watchTransactions(String userId) {
    return Stream.value(const Right([]));
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(String userId) async {
    return const Right([]);
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
    // Reset service locator before each test
    await GetIt.instance.reset();
    await di.init();

    // Register fake repository to bypass Firebase dependencies in widget testing
    GetIt.instance.unregister<TransactionRepository>();
    GetIt.instance.registerLazySingleton<TransactionRepository>(() => FakeTransactionRepository());
  });

  testWidgets('Fingo App dashboard renders weekly transaction header', (WidgetTester tester) async {
    // Force authenticated override state so router goes to dashboard
    GetIt.instance<AuthNotifier>().setAuthenticatedOverride(true);

    // Build our app and trigger a frame.
    await tester.pumpWidget(const FingoApp());

    // Let routing settle
    await tester.pumpAndSettle();

    // Verify that the clean weekly dashboard starts up correctly
    expect(find.text('THIS WEEK'), findsOneWidget);
  });
}

