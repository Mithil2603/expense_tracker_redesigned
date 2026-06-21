import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_entity.dart';

/// [TransactionEvent] — abstract base event class for transaction management BLoC.
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

/// Dispatched to initialize real-time observation stream of user's transactions.
class WatchTransactionsEvent extends TransactionEvent {
  final String userId;
  const WatchTransactionsEvent(this.userId);

  @override
  List<Object?> get props => [userId];
}

/// Dispatched internally when the Firestore snapshot stream updates.
class TransactionsUpdatedEvent extends TransactionEvent {
  final List<TransactionEntity> transactions;
  const TransactionsUpdatedEvent(this.transactions);

  @override
  List<Object?> get props => [transactions];
}

/// Dispatched to save a new transaction.
class AddTransactionEvent extends TransactionEvent {
  final TransactionEntity transaction;
  final String userId;
  const AddTransactionEvent(this.transaction, this.userId);

  @override
  List<Object?> get props => [transaction, userId];
}

/// Dispatched to update an existing transaction.
class UpdateTransactionEvent extends TransactionEvent {
  final TransactionEntity transaction;
  final String userId;
  const UpdateTransactionEvent(this.transaction, this.userId);

  @override
  List<Object?> get props => [transaction, userId];
}

/// Dispatched to remove a transaction by ID.
class DeleteTransactionEvent extends TransactionEvent {
  final String transactionId;
  final String userId;
  const DeleteTransactionEvent(this.transactionId, this.userId);

  @override
  List<Object?> get props => [transactionId, userId];
}

/// Dispatched internally when the Firestore snapshot stream encounters an error.
class TransactionErrorEvent extends TransactionEvent {
  final String message;
  const TransactionErrorEvent(this.message);

  @override
  List<Object?> get props => [message];
}
