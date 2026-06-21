import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/utils/utils.dart';
import '../models/transaction_model.dart';

/// [TransactionRemoteDataSource] — contract for transaction actions communicating with remote backend.
abstract class TransactionRemoteDataSource {
  Stream<List<TransactionModel>> watchTransactions(String userId);
  Future<List<TransactionModel>> getTransactions(String userId);
  Future<void> addTransaction(TransactionModel transaction, String userId);
  Future<void> updateTransaction(TransactionModel transaction, String userId);
  Future<void> deleteTransaction(String transactionId, String userId);
}

/// [TransactionRemoteDataSourceImpl] — concrete implementation using official Firebase Firestore SDK.
class TransactionRemoteDataSourceImpl implements TransactionRemoteDataSource {
  final FirebaseFirestore firestore;

  TransactionRemoteDataSourceImpl({required this.firestore});

  /// Get subcollection reference: `/users/{userId}/transactions`
  CollectionReference<Map<String, dynamic>> _userTransactionsRef(String userId) {
    return firestore
        .collection('users')
        .doc(userId)
        .collection('transactions');
  }

  @override
  Stream<List<TransactionModel>> watchTransactions(String userId) {
    return _userTransactionsRef(userId)
        .snapshots()
        .map((snapshot) {
      final list = <TransactionModel>[];
      for (final doc in snapshot.docs) {
        try {
          final data = doc.data();
          data['id'] = doc.id;
          // Ensure userId is populated (especially for legacy data that might omit it in the doc fields)
          if (data['userId'] == null || (data['userId'] as String).isEmpty) {
            data['userId'] = userId;
          }
          list.add(TransactionModel.fromJson(data));
        } catch (e) {
          AppLogger.w('Skipping malformed transaction doc ${doc.id}: $e');
        }
      }
      // Sort client-side by date descending to avoid requiring composite indexes in Firestore
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  @override
  Future<List<TransactionModel>> getTransactions(String userId) async {
    final query = await _userTransactionsRef(userId).get();
    final list = <TransactionModel>[];
    for (final doc in query.docs) {
      try {
        final data = doc.data();
        data['id'] = doc.id;
        // Ensure userId is populated (especially for legacy data that might omit it in the doc fields)
        if (data['userId'] == null || (data['userId'] as String).isEmpty) {
          data['userId'] = userId;
        }
        list.add(TransactionModel.fromJson(data));
      } catch (e) {
        AppLogger.w('Skipping malformed transaction doc ${doc.id}: $e');
      }
    }
    // Sort client-side by date descending
    list.sort((a, b) => b.date.compareTo(a.date));
    return list;
  }

  @override
  Future<void> addTransaction(TransactionModel transaction, String userId) async {
    final docRef = _userTransactionsRef(userId).doc(transaction.id.isEmpty ? null : transaction.id);
    final json = transaction.toJson();
    json['id'] = docRef.id; // ensure ID stored inside document matches the document key
    json['userId'] = userId; // ensure userId is set
    await docRef.set(json);
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction, String userId) async {
    final docRef = _userTransactionsRef(userId).doc(transaction.id);
    final json = transaction.toJson();
    json['userId'] = userId; // ensure userId is set
    await docRef.set(json, SetOptions(merge: true));
  }

  @override
  Future<void> deleteTransaction(String transactionId, String userId) async {
    await _userTransactionsRef(userId).doc(transactionId).delete();
  }
}
