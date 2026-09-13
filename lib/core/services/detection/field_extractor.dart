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
      // ── Template match ────────────────────────────────────────────────────
      final pattern = matchResult.pattern!;
      final match = matchResult.match;

      // Amount
      final amountGroupName = pattern.extractionMap['amount'];
      if (amountGroupName != null) {
        final amountStr = _safeGroup(match, amountGroupName);
        if (amountStr != null) {
          amount = double.tryParse(amountStr.replaceAll(',', ''));
        }
      }

      // Merchant — clean up trailing noise
      final merchantGroupName = pattern.extractionMap['merchant'];
      if (merchantGroupName != null) {
        final raw = _safeGroup(match, merchantGroupName)?.trim();
        merchant = _cleanMerchant(raw);
      }

      // Account last 4 digits
      final acctGroupName = pattern.extractionMap['accountLast4'];
      if (acctGroupName != null) {
        accountLast4 = _safeGroup(match, acctGroupName)?.trim();
      }

      // UPI reference number from pattern (if regex has 'ref' group)
      final refStr = _safeGroup(match, 'ref');
      if (refStr != null && refStr.length >= 6) {
        referenceNumber = refStr;
      }

      // Type from pattern
      type = pattern.type == 'credit' ? 'income' : 'expense';
      paymentMethod = pattern.paymentMethod ?? 'other';

      // Override type if the pattern has a 'typeK' or 'typeC' capture group
      // (used in generic patterns that detect dr/cr inline)
      final typeGroup = _safeGroup(match, 'typeK') ?? _safeGroup(match, 'typeC');
      if (typeGroup != null) {
        type = typeGroup.toLowerCase() == 'cr' ? 'income' : 'expense';
      }
    } else {
      // ── Generic fallback match ────────────────────────────────────────────
      final match = matchResult.match;

      // Try each named amount group in priority order
      final amountStr = _safeGroup(match, 'amountA')
          ?? _safeGroup(match, 'amountB')
          ?? _safeGroup(match, 'amountC')
          ?? _safeGroup(match, 'amountD')
          ?? _safeGroup(match, 'amount')
          ?? _safeGroup(match, 'amount2');

      if (amountStr != null) {
        amount = double.tryParse(amountStr.replaceAll(',', ''));
      }

      // Type: check typeC group first (dr/cr), then text keywords
      final typeC = _safeGroup(match, 'typeC');
      if (typeC != null) {
        type = typeC.toLowerCase() == 'cr' ? 'income' : 'expense';
      } else if (normalizedText.contains('credited') ||
          normalizedText.contains('received') ||
          RegExp(r'\bcr\b').hasMatch(normalizedText)) {
        type = 'income';
      } else {
        type = 'expense';
      }

      paymentMethod = 'other';
    }

    // Must have a valid positive amount
    if (amount == null || amount <= 0) return null;

    // ── Universal reference number extraction ─────────────────────────────
    if (referenceNumber == null) {
      // Priority 1: UPI reference from UPI/DR/REF or UPI/CR/REF format
      final upiRefRegex = RegExp(r'upi/(?:dr|cr)/(?<ref>\d{6,})', caseSensitive: false);
      final upiRefMatch = upiRefRegex.firstMatch(normalizedText);
      referenceNumber ??= upiRefMatch?.namedGroup('ref');
    }
    if (referenceNumber == null) {
      // Priority 2: labeled reference number
      final labeledRefRegex = RegExp(
        r'(?:ref(?:erence)?(?:\s*no\.?)?|txn(?:\s*id)?|imps(?:\s*ref)?|neft(?:\s*ref)?|upi\s*ref)[^a-z0-9]*(?<ref>\d{6,})',
        caseSensitive: false,
      );
      final labeledMatch = labeledRefRegex.firstMatch(normalizedText);
      if (labeledMatch != null) {
        referenceNumber = labeledMatch.namedGroup('ref');
      }
    }

    // ── Universal merchant extraction fallback ─────────────────────────────
    // If template didn't give us a merchant, try the UPI reference line pattern
    if (merchant == null || merchant.isEmpty) {
      // "UPI/DR/123456789/Merchant Name" — merchant is the last segment
      final upiMerchantRegex = RegExp(
        r'upi/(?:dr|cr)/\d+/(?<merchant>[^/\n\r\s][^/\n\r]{1,50}?)(?=\s*(?:balance|bal|fraud|avl|$))',
        caseSensitive: false,
      );
      final upiMerchantMatch = upiMerchantRegex.firstMatch(normalizedText);
      if (upiMerchantMatch != null) {
        merchant = _cleanMerchant(upiMerchantMatch.namedGroup('merchant'));
      }
    }

    // ── Universal date extraction ─────────────────────────────────────────
    DateTime? date;

    // Pattern 1: DD-MMM-YYYY  e.g. 02-JUL-2026 or 02-Jul-26
    final dateRegex1 = RegExp(r'(?<day>\d{1,2})-(?<month>[a-zA-Z]{3})-(?<year>\d{2,4})');
    final match1 = dateRegex1.firstMatch(normalizedText);
    if (match1 != null) {
      final d = match1.namedGroup('day')!;
      final m = match1.namedGroup('month')!;
      var y = match1.namedGroup('year')!;
      if (y.length == 2) y = '20$y';
      try { date = DateFormat('dd-MMM-yyyy').parse('$d-$m-$y'); } catch (_) {}
    }

    // Pattern 2: DD/MM/YYYY or DD/MM/YY
    if (date == null) {
      final dateRegex2 = RegExp(r'(?<day>\d{1,2})/(?<month>\d{1,2})/(?<year>\d{2,4})');
      final match2 = dateRegex2.firstMatch(normalizedText);
      if (match2 != null) {
        final d = match2.namedGroup('day')!;
        final m = match2.namedGroup('month')!;
        var y = match2.namedGroup('year')!;
        if (y.length == 2) y = '20$y';
        try { date = DateFormat('dd/MM/yyyy').parse('$d/$m/$y'); } catch (_) {}
      }
    }

    // Pattern 3: DD-MM-YYYY  e.g. 02-07-2026
    if (date == null) {
      final dateRegex3 = RegExp(r'(?<day>\d{2})-(?<month>\d{2})-(?<year>\d{4})');
      final match3 = dateRegex3.firstMatch(normalizedText);
      if (match3 != null) {
        final d = match3.namedGroup('day')!;
        final m = match3.namedGroup('month')!;
        final y = match3.namedGroup('year')!;
        try { date = DateFormat('dd-MM-yyyy').parse('$d-$m-$y'); } catch (_) {}
      }
    }

    // Pattern 4: SBI compact — DDMonYY (no separators), e.g. "17Jan23" or "02Jul26"
    if (date == null) {
      final dateRegex4 = RegExp(r'(?<day>\d{2})(?<month>[a-zA-Z]{3})(?<year>\d{2,4})');
      final match4 = dateRegex4.firstMatch(normalizedText);
      if (match4 != null) {
        final d = match4.namedGroup('day')!;
        final m = match4.namedGroup('month')!;
        var y = match4.namedGroup('year')!;
        if (y.length == 2) y = '20$y';
        try { date = DateFormat('ddMMMyyyy').parse('$d$m$y'); } catch (_) {}
      }
    }

    date ??= DateTime.now();

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

  /// Safely retrieves a named group from a RegExpMatch without throwing.
  static String? _safeGroup(RegExpMatch match, String name) {
    try { return match.namedGroup(name); } catch (_) { return null; }
  }

  /// Cleans a raw merchant string: removes trailing noise words, trims punctuation.
  static String? _cleanMerchant(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    // Remove trailing balance/fraud/ref keywords and their surrounding whitespace
    String cleaned = raw
        .replaceAll(RegExp(r'\s*(balance|bal|avl|fraud|ref|on\s+\d|\.?\s*$)', caseSensitive: false), '')
        .replaceAll(RegExp(r'[.,:;\-]+$'), '')
        .trim();
    // Title-case the merchant name
    if (cleaned.isEmpty) return null;
    return cleaned
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0].toUpperCase() + w.substring(1) : '')
        .join(' ');
  }
}
