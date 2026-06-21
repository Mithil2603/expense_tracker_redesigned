import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';

/// [TransactionRepository] — abstract contract defining transactions capabilities in the Domain Layer.
abstract class TransactionRepository {
  /// Stream listening for real-time transaction updates from the data layer.
  Stream<Either<Failure, List<TransactionEntity>>> watchTransactions(String userId);

  /// Fetch transactions list once.
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(String userId);

  /// Create a transaction for a user.
  Future<Either<Failure, void>> addTransaction(TransactionEntity transaction, String userId);

  /// Modify an existing transaction.
  Future<Either<Failure, void>> updateTransaction(TransactionEntity transaction, String userId);

  /// Remove a transaction by ID.
  Future<Either<Failure, void>> deleteTransaction(String transactionId, String userId);
}
