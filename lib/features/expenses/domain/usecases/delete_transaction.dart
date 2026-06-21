import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/transaction_repository.dart';

class DeleteTransaction {
  final TransactionRepository repository;

  DeleteTransaction(this.repository);

  Future<Either<Failure, void>> call(String transactionId, String userId) {
    return repository.deleteTransaction(transactionId, userId);
  }
}
