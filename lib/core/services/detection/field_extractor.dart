import 'pattern_matcher.dart';

class ExtractedFields {
  final double amount;
  final String type; // 'expense' or 'income'
  final String? merchant;
  final String? accountLast4;
  final String? referenceNumber;
  final String paymentMethod;

  const ExtractedFields({
    required this.amount,
    required this.type,
    this.merchant,
    this.accountLast4,
    this.referenceNumber,
    required this.paymentMethod,
  });
}

class FieldExtractor {
  /// Extracts structured fields from a regex match result.
  static ExtractedFields? extract(PatternMatchResult matchResult, String normalizedText) {
    double? amount;
    String? merchant;
    String? accountLast4;
    String? referenceNumber;
    String type = 'expense';
    String paymentMethod = 'other';

    if (matchResult.pattern != null) {
      // We have a specific template match
      final pattern = matchResult.pattern!;
      final match = matchResult.match;

      // Extract amount
      final amountGroupName = pattern.extractionMap['amount'];
      if (amountGroupName != null) {
        final amountStr = match.namedGroup(amountGroupName);
        if (amountStr != null) {
          amount = double.tryParse(amountStr.replaceAll(',', ''));
        }
      }

      // Extract merchant
      final merchantGroupName = pattern.extractionMap['merchant'];
      if (merchantGroupName != null) {
        merchant = match.namedGroup(merchantGroupName)?.trim();
      }

      // Extract account
      final acctGroupName = pattern.extractionMap['accountLast4'];
      if (acctGroupName != null) {
        accountLast4 = match.namedGroup(acctGroupName)?.trim();
      }

      type = pattern.type == 'credit' ? 'income' : 'expense';
      paymentMethod = pattern.paymentMethod ?? 'other';
    } else {
      // Fallback regex match
      final match = matchResult.match;
      final amountStr = match.namedGroup('amount') ?? match.namedGroup('amount2');
      if (amountStr != null) {
        amount = double.tryParse(amountStr.replaceAll(',', ''));
      }
      
      // Infer type from keywords
      if (normalizedText.contains('credited') || normalizedText.contains('received')) {
        type = 'income';
      } else {
        type = 'expense';
      }
    }

    // Must have a valid amount > 0 to proceed
    if (amount == null || amount <= 0) {
      return null;
    }

    // Attempt to extract reference number universally
    final refRegex = RegExp(r'(?:ref|txn|imps|neft|upi ref)[^\d]*?(?<ref>\d{6,})', caseSensitive: false);
    final refMatch = refRegex.firstMatch(normalizedText);
    if (refMatch != null) {
      referenceNumber = refMatch.namedGroup('ref');
    }

    return ExtractedFields(
      amount: amount,
      type: type,
      merchant: merchant,
      accountLast4: accountLast4,
      referenceNumber: referenceNumber,
      paymentMethod: paymentMethod,
    );
  }
}
