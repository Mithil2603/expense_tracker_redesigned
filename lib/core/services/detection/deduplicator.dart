import 'package:cloud_firestore/cloud_firestore.dart';
import '../../utils/logger.dart';
import 'field_extractor.dart';

class Deduplicator {
  /// Checks if a transaction is a duplicate based on multi-signal matching.
  /// Needs access to Firestore to check past 24 hours.
  static Future<bool> isDuplicate({
    required String userId,
    required ExtractedFields fields,
    required DateTime timestamp,
  }) async {
    final firestore = FirebaseFirestore.instance;
    final cutoff = timestamp.subtract(const Duration(hours: 24));
    final windowStart = timestamp.subtract(const Duration(minutes: 5));
    final windowEnd = timestamp.add(const Duration(minutes: 5));

    AppLogger.i('--------------------------------');
    AppLogger.i('Deduplicator START');
    AppLogger.i('userId: $userId');
    AppLogger.i('timestamp: $timestamp');
    AppLogger.i('fields.referenceNumber: ${fields.referenceNumber}');
    AppLogger.i('fields.amount: ${fields.amount}');
    AppLogger.i('fields.type: ${fields.type}');
    AppLogger.i('fields.merchant: ${fields.merchant}');
    AppLogger.i('fields.accountLast4: ${fields.accountLast4}');
    AppLogger.i('--------------------------------');

    try {
      // 1. Primary: Reference number match within 24h
      if (fields.referenceNumber != null && fields.referenceNumber!.isNotEmpty) {
        AppLogger.i('Running Reference Query');
        AppLogger.i('cutoff timestamp: $cutoff');
        AppLogger.i('referenceNumber being searched: ${fields.referenceNumber}');
        AppLogger.i('--------------------------------');

        final refQuery = await firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
            .get();

        AppLogger.i('Number of documents returned: ${refQuery.docs.length}');
        String? matchingDocId;
        for (final doc in refQuery.docs) {
          final data = doc.data();
          final meta = data['detectionMeta'] as Map<String, dynamic>?;
          final storedRef = meta?['extractedRefNumber'];
          final isMatch = storedRef != null && storedRef == fields.referenceNumber;
          AppLogger.i('document id: ${doc.id}');
          AppLogger.i('stored detectionMeta.extractedRefNumber: $storedRef');
          AppLogger.i('incoming referenceNumber: ${fields.referenceNumber}');
          AppLogger.i('MATCH = $isMatch');
          AppLogger.i('--------------------------------');
          if (isMatch && matchingDocId == null) {
            matchingDocId = doc.id;
          }
        }

        if (matchingDocId != null) {
          AppLogger.i('WHY duplicate is being returned: Reference match? true | Amount/time match? false | Which document caused it? $matchingDocId');
          return true;
        }
      }

      // 2. Secondary: Amount + Type + 5-minute window
      // Used for SMS + Push notification combo
      AppLogger.i('Running Time Query');
      AppLogger.i('windowStart: $windowStart');
      AppLogger.i('windowEnd: $windowEnd');
      AppLogger.i('amount: ${fields.amount}');
      AppLogger.i('type: ${fields.type}');
      AppLogger.i('--------------------------------');

      final timeQuery = await firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(windowStart))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(windowEnd))
          .where('type', isEqualTo: fields.type)
          .where('amount', isEqualTo: fields.amount)
          .get();

      AppLogger.i('Number of matching documents: ${timeQuery.docs.length}');
      for (final doc in timeQuery.docs) {
        final data = doc.data();
        AppLogger.i('document id: ${doc.id}');
        AppLogger.i('stored amount: ${data['amount']}');
        AppLogger.i('stored type: ${data['type']}');
        AppLogger.i('stored date: ${data['date']}');
        AppLogger.i('--------------------------------');
      }

      if (timeQuery.docs.isNotEmpty) {
        final causingDocId = timeQuery.docs.first.id;
        AppLogger.i('WHY duplicate is being returned: Reference match? false | Amount/time match? true | Which document caused it? $causingDocId');
        return true;
      }

    } catch (e) {
      // If query fails (e.g. offline), err on the side of allowing it 
      // (user can manually delete, better than missing data)
      AppLogger.e('Deduplicator.isDuplicate query error: $e');
      AppLogger.i('No duplicate found.');
      return false;
    }

    AppLogger.i('No duplicate found.');
    return false;
  }
}
