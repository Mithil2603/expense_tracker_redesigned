import 'package:cloud_firestore/cloud_firestore.dart';
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

    try {
      // 1. Primary: Reference number match within 24h
      if (fields.referenceNumber != null && fields.referenceNumber!.isNotEmpty) {
        final refQuery = await firestore
            .collection('users')
            .doc(userId)
            .collection('transactions')
            .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(cutoff))
            .get();

        for (final doc in refQuery.docs) {
          final data = doc.data();
          final meta = data['detectionMeta'] as Map<String, dynamic>?;
          if (meta != null && meta['extractedRefNumber'] == fields.referenceNumber) {
            return true;
          }
        }
      }

      // 2. Secondary: Amount + Type + 5-minute window
      // Used for SMS + Push notification combo
      final timeQuery = await firestore
          .collection('users')
          .doc(userId)
          .collection('transactions')
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(windowStart))
          .where('date', isLessThanOrEqualTo: Timestamp.fromDate(windowEnd))
          .where('type', isEqualTo: fields.type)
          .where('amount', isEqualTo: fields.amount)
          .get();

      if (timeQuery.docs.isNotEmpty) {
        return true;
      }

    } catch (e) {
      // If query fails (e.g. offline), err on the side of allowing it 
      // (user can manually delete, better than missing data)
      return false;
    }

    return false;
  }
}
