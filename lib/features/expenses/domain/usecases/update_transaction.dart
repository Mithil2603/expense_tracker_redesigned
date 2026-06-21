import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class UpdateTransaction {
  final TransactionRepository repository;

  UpdateTransaction(this.repository);

  Future<Either<Failure, void>> call(TransactionEntity transaction, String userId) {
    return repository.updateTransaction(transaction, userId);
  }
}
