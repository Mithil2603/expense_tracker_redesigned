import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_entity.dart';

/// [TransactionState] — abstract base state class for transaction management BLoC.
abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

/// Initial state prior to any data actions.
class TransactionInitial extends TransactionState {}

/// Loading state representing server write or fetch actions.
class TransactionLoading extends TransactionState {}

/// Success state carrying the active list of user transactions.
class TransactionLoaded extends TransactionState {
  final List<TransactionEntity> transactions;
  const TransactionLoaded(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

/// Action state emitted when write operations (add, edit, delete) complete successfully.
class TransactionActionSuccess extends TransactionState {}

/// Failure state carrying failure details.
class TransactionFailure extends TransactionState {
  final String message;
  const TransactionFailure(this.message);

  @override
  List<Object?> get props => [message];
}
