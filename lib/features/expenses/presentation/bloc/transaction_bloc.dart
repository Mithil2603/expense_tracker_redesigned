import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/utils/fingo_state.dart';
import '../../../../core/services/quest/quest_engine_service.dart';
import '../../../../core/domain/entities/quest_event.dart';
import '../../../../di/injection_container.dart';
import '../../domain/usecases/watch_transactions.dart';
import '../../domain/usecases/add_transaction.dart';
import '../../domain/usecases/update_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

/// [TransactionBloc] — coordinates transaction actions and real-time state observations.
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  final WatchTransactions watchTransactions;
  final AddTransaction addTransaction;
  final UpdateTransaction updateTransaction;
  final DeleteTransaction deleteTransaction;

  StreamSubscription? _transactionsSubscription;

  TransactionBloc({
    required this.watchTransactions,
    required this.addTransaction,
    required this.updateTransaction,
    required this.deleteTransaction,
  }) : super(TransactionInitial()) {
    
    on<WatchTransactionsEvent>((event, emit) async {
      emit(TransactionLoading());
      await _transactionsSubscription?.cancel();

      // Fetch initial transactions from cache/server immediately to prevent endless loading spinner
      try {
        final initialResult = await watchTransactions.repository
            .getTransactions(event.userId)
            .timeout(const Duration(seconds: 2));
        if (state is TransactionLoading) {
          initialResult.fold(
            (_) => emit(const TransactionLoaded([])),
            (transactions) {
              sl<FingoState>().syncWithTransactions(transactions);
              emit(TransactionLoaded(transactions));
            },
          );
        }
      } catch (_) {
        if (state is TransactionLoading) {
          emit(const TransactionLoaded([]));
        }
      }

      // Then subscribe to real-time updates
      _transactionsSubscription = watchTransactions(event.userId).listen((result) {
        result.fold(
          (failure) => add(TransactionErrorEvent(failure.message)),
          (transactions) => add(TransactionsUpdatedEvent(transactions)),
        );
      });
    });

    on<TransactionsUpdatedEvent>((event, emit) {
      sl<FingoState>().syncWithTransactions(event.transactions);
      emit(TransactionLoaded(event.transactions));
    });

    on<TransactionErrorEvent>((event, emit) {
      emit(TransactionFailure(event.message));
    });

    on<AddTransactionEvent>((event, emit) async {
      final result = await addTransaction(event.transaction, event.userId);
      result.fold(
        (failure) => emit(TransactionFailure(failure.message)),
        (_) {
          // Add Diamonds
          sl<FingoState>().awardDiamonds(10);
          
          // Deduct Health: if the transaction is manual, deduct 1 health. 
          // Auto transactions (with detectionMeta) are handled in NotificationSyncService.
          if (event.transaction.detectionMeta == null) {
            sl<FingoState>().deductHealth(1);
          }

          if (sl.isRegistered<QuestEngineService>()) {
            sl<QuestEngineService>().recordEvent(
              QuestEvent(
                type: QuestEventType.transactionAdded,
                transaction: event.transaction,
                timestamp: DateTime.now(),
              ),
              event.userId,
            );
          }
        },
      );
    });

    on<UpdateTransactionEvent>((event, emit) async {
      final result = await updateTransaction(event.transaction, event.userId);
      result.fold(
        (failure) => emit(TransactionFailure(failure.message)),
        (_) {
          if (!event.transaction.isPending && sl.isRegistered<QuestEngineService>()) {
            sl<QuestEngineService>().recordEvent(
              QuestEvent(
                type: QuestEventType.pendingReviewActioned,
                transaction: event.transaction,
                timestamp: DateTime.now(),
              ),
              event.userId,
            );
          }
        },
      );
    });

    on<DeleteTransactionEvent>((event, emit) async {
      final result = await deleteTransaction(event.transactionId, event.userId);
      result.fold(
        (failure) => emit(TransactionFailure(failure.message)),
        (_) {
          if (sl.isRegistered<QuestEngineService>()) {
            // Find in current state if needed, or trigger list update
            sl<QuestEngineService>().recordEvent(
              QuestEvent(
                type: QuestEventType.transactionListUpdated,
                timestamp: DateTime.now(),
              ),
              event.userId,
            );
          }
        },
      );
    });
  }

  @override
  Future<void> close() {
    _transactionsSubscription?.cancel();
    return super.close();
  }
}
