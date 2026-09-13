import 'package:equatable/equatable.dart';
import '../../../../features/expenses/domain/entities/transaction_entity.dart';

enum QuestEventType {
  appOpen,
  transactionAdded,
  transactionDeleted,
  pendingReviewActioned,
  analyticsOpened,
  budgetUpdated,
  transactionListUpdated,
}

class QuestEvent extends Equatable {
  final QuestEventType type;
  final TransactionEntity? transaction;
  final DateTime timestamp;

  const QuestEvent({
    required this.type,
    this.transaction,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [type, transaction, timestamp];
}
