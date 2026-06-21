import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/transaction_entity.dart';
import '../repositories/transaction_repository.dart';

class WatchTransactions {
  final TransactionRepository repository;

  WatchTransactions(this.repository);

  Stream<Either<Failure, List<TransactionEntity>>> call(String userId) {
    return repository.watchTransactions(userId);
  }
}
