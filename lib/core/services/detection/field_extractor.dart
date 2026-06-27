import 'pattern_matcher.dart';
import 'package:intl/intl.dart';

class ExtractedFields {
  final double amount;
  final String type; // 'expense' or 'income'
  final String? merchant;
  final String? accountLast4;
  final String? referenceNumber;
  final String paymentMethod;
  final DateTime? date;

  const ExtractedFields({
    required this.amount,
    required this.type,
    this.merchant,
    this.accountLast4,
    this.referenceNumber,
    required this.paymentMethod,
    this.date,
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

    // Extract date universally
    DateTime? date;
    
    // Pattern 1: DD-MMM-YYYY (e.g., 21-JUN-2026)
    final dateRegex1 = RegExp(r'(?<day>\d{1,2})-(?<month>[a-zA-Z]{3})-(?<year>\d{4})');
    final match1 = dateRegex1.firstMatch(normalizedText);
    if (match1 != null) {
      final d = match1.namedGroup('day');
      final m = match1.namedGroup('month');
      final y = match1.namedGroup('year');
      if (d != null && m != null && y != null) {
        try {
          date = DateFormat('dd-MMM-yyyy').parse('$d-$m-$y');
        } catch (_) {}
      }
    }
    
    // Pattern 2: DD/MM/YYYY
    if (date == null) {
      final dateRegex2 = RegExp(r'(?<day>\d{1,2})/(?<month>\d{1,2})/(?<year>\d{2,4})');
      final match2 = dateRegex2.firstMatch(normalizedText);
      if (match2 != null) {
        final d = match2.namedGroup('day');
        final m = match2.namedGroup('month');
        final y = match2.namedGroup('year');
        if (d != null && m != null && y != null) {
          try {
            final yStr = y.length == 2 ? '20$y' : y;
            date = DateFormat('dd/MM/yyyy').parse('$d/$m/$yStr');
          } catch (_) {}
        }
      }
    }
    
    if (date == null && normalizedText.contains('today')) {
      date = DateTime.now();
    }

    return ExtractedFields(
      amount: amount,
      type: type,
      merchant: merchant,
      accountLast4: accountLast4,
      referenceNumber: referenceNumber,
      paymentMethod: paymentMethod,
      date: date,
    );
  }
}
