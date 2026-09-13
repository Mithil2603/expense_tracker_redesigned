import 'pattern_matcher.dart';
import 'field_extractor.dart';

class ConfidenceScore {
  final double score;
  final List<String> matchedRules;

  const ConfidenceScore(this.score, this.matchedRules);
}

class ConfidenceScorer {
  /// Scores detection confidence based on aggregated signals.
  /// The score must reach [DetectionPipeline.autoCreateThreshold] (0.70) to
  /// auto-create a transaction, or [DetectionPipeline.reviewQueueThreshold] (0.40)
  /// to queue it for user review.
  static ConfidenceScore score({
    required String normalizedText,
    required String sender,
    required PatternMatchResult matchResult,
    required ExtractedFields extractedFields,
  }) {
    double totalScore = 0.0;
    final List<String> matchedRules = [];

    // 1. Valid positive amount (mandatory — worth most)
    if (extractedFields.amount > 0) {
      totalScore += 0.25;
      matchedRules.add('has_valid_amount');
    }

    // 2. Transaction keyword in text
    final txnKeywords = [
      'debited', 'credited', 'deducted', 'paid', 'received', 'spent', 'sent',
    ];
    final hasTxnKeyword = txnKeywords.any((k) => normalizedText.contains(k));
    final hasDrCr = RegExp(r'\b(dr|cr)\b').hasMatch(normalizedText);
    final hasUpiDrCr = RegExp(r'upi/(dr|cr)/', caseSensitive: false).hasMatch(normalizedText);

    if (hasTxnKeyword || hasDrCr || hasUpiDrCr) {
      totalScore += 0.20;
      matchedRules.add('has_txn_keyword');
    }

    // 3. Sender signal
    final lowerSender = sender.toLowerCase();
    final isBankSender = lowerSender.contains('bank') ||
        lowerSender.contains('bk') ||
        lowerSender.contains('sbi') ||
        lowerSender.contains('upi') ||
        lowerSender.contains('hdfc') ||
        lowerSender.contains('icici') ||
        lowerSender.contains('axis') ||
        lowerSender.contains('kotak') ||
        lowerSender.contains('au') ||
        lowerSender.contains('paytm') ||
        lowerSender.contains('phonepe') ||
        lowerSender.contains('gpay');

    final senderMatchesTemplate = matchResult.pattern != null &&
        matchResult.pattern!.senderPatterns.any(
          (sp) => lowerSender.contains(sp.toLowerCase()),
        );

    if (senderMatchesTemplate) {
      totalScore += 0.20;
      matchedRules.add('sender_matches_template');
    } else if (isBankSender) {
      totalScore += 0.15;
      matchedRules.add('sender_resembles_bank');
    }

    // 4. Specific template match bonus
    if (matchResult.pattern != null) {
      final boost = matchResult.pattern!.confidenceBoost;
      totalScore += 0.10 + boost; // base + template-specific boost
      matchedRules.add('matches_specific_template:${matchResult.pattern!.id}');
    }

    // 5. Account reference present
    final hasAccount = extractedFields.accountLast4 != null ||
        normalizedText.contains('a/c') ||
        normalizedText.contains('account') ||
        RegExp(r'\bxx\d{4}\b').hasMatch(normalizedText);
    if (hasAccount) {
      totalScore += 0.10;
      matchedRules.add('has_account_reference');
    }

    // 6. UPI reference number (strong signal — uniquely identifies the transaction)
    if (extractedFields.referenceNumber != null) {
      totalScore += 0.10;
      matchedRules.add('has_reference_number');
    }

    // 7. Merchant extracted
    if (extractedFields.merchant != null && extractedFields.merchant!.isNotEmpty) {
      totalScore += 0.05;
      matchedRules.add('has_merchant');
    }

    // 8. Text length reasonable for a bank SMS (20–350 chars)
    if (normalizedText.length > 20 && normalizedText.length < 350) {
      totalScore += 0.05;
      matchedRules.add('valid_text_length');
    }

    // 9. Balance line present (very common in real bank SMSes — positive signal)
    if (RegExp(r'\b(bal|balance)\b.*?\d').hasMatch(normalizedText)) {
      totalScore += 0.05;
      matchedRules.add('has_balance_line');
    }

    // Cap at 1.0
    if (totalScore > 1.0) totalScore = 1.0;

    return ConfidenceScore(totalScore, matchedRules);
  }
}
