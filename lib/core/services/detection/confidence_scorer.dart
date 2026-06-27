import 'pattern_matcher.dart';
import 'field_extractor.dart';

class ConfidenceScore {
  final double score;
  final List<String> matchedRules;

  const ConfidenceScore(this.score, this.matchedRules);
}

class ConfidenceScorer {
  /// Scores the confidence of a detection based on aggregated signals.
  static ConfidenceScore score({
    required String normalizedText,
    required String sender,
    required PatternMatchResult matchResult,
    required ExtractedFields extractedFields,
  }) {
    double totalScore = 0.0;
    final List<String> matchedRules = [];

    // 1. Amount
    if (extractedFields.amount > 0) {
      totalScore += 0.25;
      matchedRules.add('has_valid_amount');
    }

    // 2. Transaction keyword
    final txnKeywords = ['debit', 'credit', 'paid', 'received', 'sent', 'deducted', 'spent'];
    if (txnKeywords.any((k) => normalizedText.contains(k))) {
      totalScore += 0.20;
      matchedRules.add('has_txn_keyword');
    }

    // 3. Sender Pattern
    // Check if sender looks like a bank (has 'bk', 'bank', or matches a template)
    final lowerSender = sender.toLowerCase();
    if (lowerSender.contains('bk') || lowerSender.contains('bank')) {
      totalScore += 0.15;
      matchedRules.add('sender_resembles_bank');
    } else if (matchResult.pattern != null && 
               matchResult.pattern!.senderPatterns.any((sp) => lowerSender.contains(sp.toLowerCase()))) {
      totalScore += 0.15;
      matchedRules.add('sender_matches_template');
    }

    // 4. Template match
    if (matchResult.pattern != null) {
      totalScore += 0.20 + (matchResult.pattern!.confidenceBoost);
      matchedRules.add('matches_specific_template');
    }

    // 5. Account reference
    if (extractedFields.accountLast4 != null || normalizedText.contains('a/c') || normalizedText.contains('account')) {
      totalScore += 0.10;
      matchedRules.add('has_account_reference');
    }

    // 6. Reference number
    if (extractedFields.referenceNumber != null) {
      totalScore += 0.05;
      matchedRules.add('has_reference_number');
    }

    // 7. Length check (avoiding extremely long T&C messages or short ads)
    if (normalizedText.length > 20 && normalizedText.length < 250) {
      totalScore += 0.05;
      matchedRules.add('valid_text_length');
    }

    // Cap at 1.0
    if (totalScore > 1.0) totalScore = 1.0;

    return ConfidenceScore(totalScore, matchedRules);
  }
}
