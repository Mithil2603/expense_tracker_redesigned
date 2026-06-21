import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/network/network_info.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/transaction_remote_data_source.dart';
import '../models/transaction_model.dart';

/// [TransactionRepositoryImpl] — concrete implementation of [TransactionRepository] coordinating remote operations.
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TransactionRepositoryImpl({
    required this.remoteDataSource,
    required this.networkInfo,
  });

  @override
  Stream<Either<Failure, List<TransactionEntity>>> watchTransactions(String userId) {
    return remoteDataSource.watchTransactions(userId).map<Either<Failure, List<TransactionEntity>>>((models) {
      return Right(models);
    }).handleError((error) {
      return Left(ServerFailure(error.toString()));
    });
  }

  @override
  Future<Either<Failure, List<TransactionEntity>>> getTransactions(String userId) async {
    try {
      final models = await remoteDataSource.getTransactions(userId);
      return Right(models);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> addTransaction(TransactionEntity transaction, String userId) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await remoteDataSource.addTransaction(model, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateTransaction(TransactionEntity transaction, String userId) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await remoteDataSource.updateTransaction(model, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteTransaction(String transactionId, String userId) async {
    try {
      await remoteDataSource.deleteTransaction(transactionId, userId);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
