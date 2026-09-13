import 'models/detection_pattern.dart';

class PatternMatchResult {
  final DetectionPattern? pattern;
  final RegExpMatch match;

  const PatternMatchResult(this.pattern, this.match);
}

/// Attempts to match a normalized SMS/notification body against known bank templates.
/// Falls back to a multi-signal generic extractor when no template matches.
class PatternMatcher {
  static List<DetectionPattern> _patterns = _getDefaultPatterns();

  static void updatePatterns(List<DetectionPattern> newPatterns) {
    _patterns = newPatterns;
  }

  static PatternMatchResult? match(String normalizedText, String sender) {
    final lowerSender = sender.toLowerCase();

    final activePatterns = _patterns.where((p) => p.enabled).toList()
      ..sort((a, b) {
        if (a.version != b.version) return b.version.compareTo(a.version);
        return b.confidenceBoost.compareTo(a.confidenceBoost);
      });

    // 1. Sender-matched template pass
    for (final pattern in activePatterns) {
      final senderMatches = pattern.senderPatterns
          .any((sp) => lowerSender.contains(sp.toLowerCase()));
      if (senderMatches) {
        final m = pattern.regex.firstMatch(normalizedText);
        if (m != null) return PatternMatchResult(pattern, m);
      }
    }

    // 2. Sender-agnostic pass (high-confidence templates only)
    for (final pattern in activePatterns) {
      if (pattern.confidenceBoost < 0.25) continue;
      final m = pattern.regex.firstMatch(normalizedText);
      if (m != null) return PatternMatchResult(pattern, m);
    }

    // 3. Generic fallback
    final genericRegex = RegExp(
      r'(?:'
      r'(?:debited|credited|deducted)\s*(?:by|with|of|for)?\s*(?:inr|rs\.?|₹)?\s*(?<amountA>[\d]+(?:\.\d{1,2})?)'
      r'|(?:inr|rs\.?|₹)\s*(?<amountB>[\d]+(?:\.\d{1,2})?)\s*(?:debited|credited|deducted|paid|spent|sent|received)'
      r'|\b(?<typeC>dr|cr)\b\s*(?:inr|rs\.?|₹)?\s*(?<amountC>[\d]+(?:\.\d{1,2})?)'
      r'|(?:paid|spent|sent)\s*(?:inr|rs\.?|₹)?\s*(?<amountD>[\d]+(?:\.\d{1,2})?)'
      r'|amt\s*sent\s*(?:rs\.?|inr|₹)?\s*(?<amountE>[\d]+(?:\.\d{1,2})?)'
      r')',
      caseSensitive: false,
    );

    final genericMatch = genericRegex.firstMatch(normalizedText);
    if (genericMatch != null) return PatternMatchResult(null, genericMatch);

    return null;
  }



  static List<DetectionPattern> _getDefaultPatterns() {
    // All regex patterns use double-quoted strings (no raw r'' prefix)
    // so we escape backslashes properly and avoid the apostrophe issue.
    return [

      // ── HDFC: Amt Sent UPI ────────────────────────────────────────────────
      DetectionPattern(
        id: 'hdfc_amt_sent_v3',
        bank: 'HDFC',
        type: 'debit',
        senderPatterns: ['hdfcbk', 'hdfcbn', 'hdfcbm', 'hdfcbank', 'hdfc'],
        regex: RegExp(
          r'amt\s*sent\s*(?:rs\.?|inr|₹)?\s*(?<amount>[\d]+(?:\.\d{1,2})?)\s*from\s*hdfc[^,\.]{0,25}'
          r'(?:a/c|account)\s*[x*]+\s*(?<acct>\d{4})'
          r'(?:\s*to\s+(?<merchant>[a-z0-9][a-z0-9 .\-_@]{1,40}?)(?:\s*on|\s*ref|\s*\.|$))?',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'upi',
        confidenceBoost: 0.35,
        version: 3,
        enabled: true,
      ),

      // ── HDFC: General Debit ───────────────────────────────────────────────
      DetectionPattern(
        id: 'hdfc_debit_general_v3',
        bank: 'HDFC',
        type: 'debit',
        senderPatterns: ['hdfcbk', 'hdfcbn', 'hdfcbm', 'hdfcbank', 'hdfc'],
        regex: RegExp(
          r'(?:inr|rs\.?|₹)\s*(?<amount>[\d]+(?:\.\d{1,2})?)\s*debited\s*from[^,\.]{0,30}'
          r'(?:a/c|account)\s*(?:xx|[x*]+)?\s*(?<acct>\d{4})'
          r'(?:.*?info:\s*(?<merchant>[a-z0-9][a-z0-9 .\-_]{1,40}?)(?:\s*avl|\s*not|\s*\.|$))?',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'upi',
        confidenceBoost: 0.28,
        version: 3,
        enabled: true,
      ),

      // ── HDFC: Credit Card ─────────────────────────────────────────────────
      DetectionPattern(
        id: 'hdfc_cc_debit_v3',
        bank: 'HDFC',
        type: 'debit',
        senderPatterns: ['hdfcbk', 'hdfcbn', 'hdfcbm', 'hdfcbank', 'hdfc'],
        regex: RegExp(
          r'(?:inr|rs\.?|₹)\s*(?<amount>[\d]+(?:\.\d{1,2})?)\s*spent\s*on\s*hdfc\s*bank\s*card\s*[x*]\s*(?<acct>\d{4})'
          r'(?:\s*at\s+(?<merchant>[a-z0-9][a-z0-9 .\-_]{1,40}?)(?:\s*on|\s*avl|\s*\.|$|\s*\d))?',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'credit_card',
        confidenceBoost: 0.32,
        version: 3,
        enabled: true,
      ),

      // ── HDFC: Credit ──────────────────────────────────────────────────────
      DetectionPattern(
        id: 'hdfc_credit_v3',
        bank: 'HDFC',
        type: 'credit',
        senderPatterns: ['hdfcbk', 'hdfcbn', 'hdfcbm', 'hdfcbank', 'hdfc'],
        regex: RegExp(
          r'(?:inr|rs\.?|₹)\s*(?<amount>[\d]+(?:\.\d{1,2})?)\s*credited\s*to\s*(?:a/c|account|acct)\s*(?:xx|[x*]+)?\s*(?<acct>\d{4})'
          r'(?:.*?(?:by|from|vpa)\s+(?<merchant>[a-z0-9][a-z0-9 .\-_@]{1,40}?)(?:\s*\(|\s*ref|\s*upi|\s*\.|$))?',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'upi',
        confidenceBoost: 0.28,
        version: 3,
        enabled: true,
      ),

      // ── SBI: UPI Debit ────────────────────────────────────────────────────
      // "A/c X{last4}-debited by Rs{amount} on {DDMonYY} transfer to {payee} Ref No {ref}"
      DetectionPattern(
        id: 'sbi_debit_upi_v3',
        bank: 'SBI',
        type: 'debit',
        senderPatterns: ['sbinb', 'sbibnk', 'sbmsbi', 'sbisms', 'statebank', 'sbi'],
        regex: RegExp(
          r'(?:a/c|account|acct)\s*[x]+\s*(?<acct>\d{4})\s*[-]?\s*debited\s*by\s*(?:inr|rs\.?|₹)?\s*(?<amount>[\d]+(?:\.\d{1,2})?)'
          r'(?:.*?(?:transfer\s*to|to)\s+(?<merchant>[a-z0-9][a-z0-9 .\-_@]{1,40}?)(?:\s*ref|\s*on|\s*\.|$))?',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'upi',
        confidenceBoost: 0.30,
        version: 3,
        enabled: true,
      ),

      // ── SBI: General Debit ────────────────────────────────────────────────
      DetectionPattern(
        id: 'sbi_debit_general_v3',
        bank: 'SBI',
        type: 'debit',
        senderPatterns: ['sbinb', 'sbibnk', 'sbmsbi', 'sbisms', 'statebank', 'sbi'],
        regex: RegExp(
          r'(?:a/c|account|acct)\s*(?:no\.?)?\s*[x]+\s*(?<acct>\d{4})\s*(?:is\s*)?debited\s*(?:for|by|with)?\s*(?:inr|rs\.?|₹)?\s*(?<amount>[\d]+(?:\.\d{1,2})?)'
          r'(?:.*?(?:to)\s+(?<merchant>[a-z0-9][a-z0-9 .\-_@]{1,40}?)(?:\s*imps|\s*ref|\s*if|\s*\.|$))?',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'bank_transfer',
        confidenceBoost: 0.25,
        version: 3,
        enabled: true,
      ),

      // ── SBI: Credit Card ──────────────────────────────────────────────────
      DetectionPattern(
        id: 'sbi_cc_debit_v3',
        bank: 'SBI',
        type: 'debit',
        senderPatterns: ['sbinb', 'sbibnk', 'sbmsbi', 'sbisms', 'sbicrd', 'statebank', 'sbi'],
        regex: RegExp(
          r'(?:inr|rs\.?|₹)\s*(?<amount>[\d]+(?:\.\d{1,2})?)\s*spent\s*on\s*(?:your\s*)?sbi\s*credit\s*card\s*(?:ending\s*with|xx|[x*]+)?\s*(?<acct>\d{4})'
          r'(?:\s*at\s+(?<merchant>[a-z0-9][a-z0-9 .\-_]{1,40}?)(?:\s*on|\s*via|\s*ref|\s*\.|$))?',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'credit_card',
        confidenceBoost: 0.32,
        version: 3,
        enabled: true,
      ),

      // ── AU Small Finance Bank: Debit (UPI) ────────────────────────────────
      // ACTUAL format: "Dr INR 900.90 - AU A/c X0750 02-JUL-2026\nUPI/DR/654960158602/Euronet Services I\nBal INR 38,324.92"
      // After normalization: "dr inr 900.90 - au a/c x0750 02-jul-2026 upi/dr/654960158602/euronet services i bal inr 38324.92 ..."
      DetectionPattern(
        id: 'au_debit_upi_v3',
        bank: 'AU Small Finance Bank',
        type: 'debit',
        senderPatterns: ['ausfbl', 'aubank', 'ausbfl', 'ausbfd', 'aubksb', 'au small', 'au'],
        regex: RegExp(
          r'\bdr\b\s*(?:inr|rs\.?|₹)?\s*(?<amount>[\d]+(?:\.\d{1,2})?)'
          r'\s*[-]?\s*au\s*(?:a/c|account|acct)\s*[x]*\s*(?<acct>\d{4})'
          r'(?:.*?upi/dr/(?<ref>\d{6,})/(?<merchant>[^/\s][^/\r\n]{0,50}?)(?=\s*(?:bal|balance|fraud|call|\d{2}-[a-z]|$)))?',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'upi',
        confidenceBoost: 0.38,
        version: 3,
        enabled: true,
      ),

      // ── AU Small Finance Bank: Credit (UPI) ───────────────────────────────
      DetectionPattern(
        id: 'au_credit_upi_v3',
        bank: 'AU Small Finance Bank',
        type: 'credit',
        senderPatterns: ['ausfbl', 'aubank', 'ausbfl', 'ausbfd', 'aubksb', 'au small', 'au'],
        regex: RegExp(
          r'\bcr\b\s*(?:inr|rs\.?|₹)?\s*(?<amount>[\d]+(?:\.\d{1,2})?)'
          r'\s*[-]?\s*au\s*(?:a/c|account|acct)\s*[x]*\s*(?<acct>\d{4})'
          r'(?:.*?upi/cr/(?<ref>\d{6,})/(?<merchant>[^/\s][^/\r\n]{0,50}?)(?=\s*(?:bal|balance|fraud|call|\d{2}-[a-z]|$)))?',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'upi',
        confidenceBoost: 0.38,
        version: 3,
        enabled: true,
      ),

      // ── AU Small Finance Bank: General Debit (non-UPI) ────────────────────
      // "Dear Customer, INR 500 debited from your A/c XX0750 on 02-Jul-26. Info: ATM. Avl Bal: INR 10000."
      DetectionPattern(
        id: 'au_debit_general_v3',
        bank: 'AU Small Finance Bank',
        type: 'debit',
        senderPatterns: ['ausfbl', 'aubank', 'ausbfl', 'ausbfd', 'aubksb', 'au small', 'au'],
        regex: RegExp(
          r'(?:inr|rs\.?|₹)\s*(?<amount>[\d]+(?:\.\d{1,2})?)\s*debited\s*from\s*(?:your\s*)?'
          r'(?:a/c|account|acct)\s*(?:xx|[x*]+)?\s*(?<acct>\d{4})'
          r'(?:.*?(?:info:|to|at)\s+(?<merchant>[a-z0-9][a-z0-9 .\-_]{1,40}?)(?:\s*avl|\s*not|\s*\.|$))?',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'other',
        confidenceBoost: 0.28,
        version: 3,
        enabled: true,
      ),

      // ── ICICI: General Debit ──────────────────────────────────────────────
      // "INR 500 debited from Acct XX1234 on 07-Jun-24."
      DetectionPattern(
        id: 'icici_debit_general_v3',
        bank: 'ICICI',
        type: 'debit',
        senderPatterns: ['icicib', 'icicic', 'icicibank', 'icici'],
        regex: RegExp(
          r'(?:inr|rs\.?|₹)\s*(?<amount>[\d]+(?:\.\d{1,2})?)\s*debited\s*from\s*(?:acct|a/c|account|ac)\s*(?:xx|[x*]+)?\s*(?<acct>\d{4})'
          r'(?:.*?(?:trf\s*to|to|at)\s+(?<merchant>[a-z0-9][a-z0-9 .\-_@]{1,40}?)(?:\s*ref|\s*avl|\s*if|\s*\.|$))?',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'upi',
        confidenceBoost: 0.28,
        version: 3,
        enabled: true,
      ),

      // ── ICICI: UPI Debit ──────────────────────────────────────────────────
      // "A/C X{last4} debited by {amount} on {date} trf to {payee}"
      DetectionPattern(
        id: 'icici_debit_upi_v3',
        bank: 'ICICI',
        type: 'debit',
        senderPatterns: ['icicib', 'icicic', 'icicibank', 'icici'],
        regex: RegExp(
          r'(?:a/c|acct|account)\s*[x]+\s*(?<acct>\d{4})\s*debited\s*by\s*(?<amount>[\d]+(?:\.\d{1,2})?)'
          r'(?:.*?(?:trf\s*to|transfer\s*to|to)\s+(?<merchant>[a-z0-9][a-z0-9 .\-_@]{1,40}?)(?:\s*refno|\s*ref|\s*if|\s*\.|$))?',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'upi',
        confidenceBoost: 0.30,
        version: 3,
        enabled: true,
      ),

      // ── ICICI: Credit Card ────────────────────────────────────────────────
      DetectionPattern(
        id: 'icici_cc_debit_v3',
        bank: 'ICICI',
        type: 'debit',
        senderPatterns: ['icicib', 'icicic', 'icicibank', 'icici'],
        regex: RegExp(
          r'(?:inr|rs\.?|₹)\s*(?<amount>[\d]+(?:\.\d{1,2})?)\s*spent\s*on\s*icici\s*bank\s*credit\s*card\s*(?:xx|[x*]+)?\s*(?<acct>\d{4})'
          r'(?:\s*at\s+(?<merchant>[a-z0-9][a-z0-9 .\-_]{1,40}?)(?:\s*on|\s*avbl|\s*not|\s*\.|$))?',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'credit_card',
        confidenceBoost: 0.32,
        version: 3,
        enabled: true,
      ),

      // ── Axis Bank: Debit ──────────────────────────────────────────────────
      // "INR 500 has been debited from A/c no. XX1234 on 02-Jul-26. Info- Swiggy/UPI"
      DetectionPattern(
        id: 'axis_debit_v3',
        bank: 'Axis Bank',
        type: 'debit',
        senderPatterns: ['axisbk', 'utibop', 'axisnb', 'axisbank', 'axis'],
        regex: RegExp(
          r'(?:inr|rs\.?|₹)\s*(?<amount>[\d]+(?:\.\d{1,2})?)\s*(?:has\s*been\s*)?debited\s*from\s*'
          r'(?:a/c|account)\s*(?:no\.?)?\s*(?:xx|[x*]+)?\s*(?<acct>\d{4})'
          r'(?:.*?info[-:]\s*(?<merchant>[a-z0-9][a-z0-9 .\-_@/]{1,40}?)(?:\s*avl|\s*regards|\s*not|\s*\.|$))?',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'upi',
        confidenceBoost: 0.28,
        version: 3,
        enabled: true,
      ),

      // ── Axis Bank: Credit Card ────────────────────────────────────────────
      DetectionPattern(
        id: 'axis_cc_debit_v3',
        bank: 'Axis Bank',
        type: 'debit',
        senderPatterns: ['axisbk', 'utibop', 'axisnb', 'axisbank', 'axis'],
        regex: RegExp(
          r'(?:inr|rs\.?|₹)\s*(?<amount>[\d]+(?:\.\d{1,2})?)\s*spent\s*on\s*(?:your\s*)?axis\s*bank\s*credit\s*card\s*(?:ending\s*with|xx|[x*]+)?\s*(?<acct>\d{4})'
          r'(?:\s*at\s+(?<merchant>[a-z0-9][a-z0-9 .\-_]{1,40}?)(?:\s*on|\s*avail|\s*not|\s*\.|$))?',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'credit_card',
        confidenceBoost: 0.32,
        version: 3,
        enabled: true,
      ),

      // ── Kotak Bank ────────────────────────────────────────────────────────
      // "Rs.500 debited from A/c XX1234 on 02-Jul-26. Info: Swiggy. Avail bal: Rs.10000"
      DetectionPattern(
        id: 'kotak_debit_v3',
        bank: 'Kotak',
        type: 'debit',
        senderPatterns: ['kotakb', 'kmbl', 'kotakbank', 'kotak'],
        regex: RegExp(
          r'(?:inr|rs\.?|₹)\s*(?<amount>[\d]+(?:\.\d{1,2})?)\s*debited\s*from\s*(?:a/c|account)\s*(?:xx|[x*]+)?\s*(?<acct>\d{4})'
          r'(?:.*?info:\s*(?<merchant>[a-z0-9][a-z0-9 .\-_@/]{1,40}?)(?:\s*avail|\s*ref|\s*kotak|\s*\.|$))?',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'upi',
        confidenceBoost: 0.28,
        version: 3,
        enabled: true,
      ),

      // ── Yes Bank ──────────────────────────────────────────────────────────
      DetectionPattern(
        id: 'yes_debit_v3',
        bank: 'Yes Bank',
        type: 'debit',
        senderPatterns: ['yesbk', 'yesbnk', 'yesbank'],
        regex: RegExp(
          r'(?:inr|rs\.?|₹)\s*(?<amount>[\d]+(?:\.\d{1,2})?)\s*(?:has\s*been\s*)?debited\s*from\s*(?:your\s*)?'
          r'(?:a/c|account)\s*(?:xx|[x*]+)?\s*(?<acct>\d{4})',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'upi',
        confidenceBoost: 0.25,
        version: 3,
        enabled: true,
      ),

      // ── IDFC First Bank ───────────────────────────────────────────────────
      // "INR 500 debited from your A/c XX1234 on 02-Jul-26. Info: Swiggy/UPI. Avbl Bal: INR 10000"
      DetectionPattern(
        id: 'idfc_debit_v3',
        bank: 'IDFC First',
        type: 'debit',
        senderPatterns: ['idfcfb', 'idfcbk', 'idfc'],
        regex: RegExp(
          r'(?:inr|rs\.?|₹)\s*(?<amount>[\d]+(?:\.\d{1,2})?)\s*debited\s*from\s*(?:your\s*)?'
          r'(?:a/c|account)\s*(?:xx|[x*]+)?\s*(?<acct>\d{4})'
          r'(?:.*?info:\s*(?<merchant>[a-z0-9][a-z0-9 .\-_@/]{1,40}?)(?:\s*avbl|\s*not|\s*\.|$))?',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'upi',
        confidenceBoost: 0.28,
        version: 3,
        enabled: true,
      ),

      // ── IndusInd Bank ─────────────────────────────────────────────────────
      // "your A/c XXXXXX1234 has been debited for INR 500 towards {merchant}"
      DetectionPattern(
        id: 'indusind_debit_v3',
        bank: 'IndusInd',
        type: 'debit',
        senderPatterns: ['indusb', 'indbnk', 'indusin', 'indusind'],
        regex: RegExp(
          r'(?:a/c|account)\s*[x]+\s*(?<acct>\d{4})\s*(?:has\s*been\s*)?debited\s*(?:for|by|with)?\s*(?:inr|rs\.?|₹)?\s*(?<amount>[\d]+(?:\.\d{1,2})?)'
          r'(?:.*?towards\s+(?<merchant>[a-z0-9][a-z0-9 .\-_@]{1,40}?)(?:\s*the\s*available|\s*for\s*assist|\s*\.|$))?',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'upi',
        confidenceBoost: 0.28,
        version: 3,
        enabled: true,
      ),

      // ── PNB ───────────────────────────────────────────────────────────────
      DetectionPattern(
        id: 'pnb_debit_v3',
        bank: 'PNB',
        type: 'debit',
        senderPatterns: ['pnbbnk', 'pnbsms', 'pnb'],
        regex: RegExp(
          r'(?:inr|rs\.?|₹)\s*(?<amount>[\d]+(?:\.\d{1,2})?)\s*debited\s*from\s*(?:a/c|account)\s*(?:xx|[x*]+)?\s*(?<acct>\d{4})',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'upi',
        confidenceBoost: 0.25,
        version: 3,
        enabled: true,
      ),

      // ── Bank of Baroda ────────────────────────────────────────────────────
      DetectionPattern(
        id: 'bob_debit_v3',
        bank: 'Bank of Baroda',
        type: 'debit',
        senderPatterns: ['barodb', 'bobbnk', 'bankofbaroda'],
        regex: RegExp(
          r'(?:inr|rs\.?|₹)\s*(?<amount>[\d]+(?:\.\d{1,2})?)\s*debited\s*from\s*(?:your\s*)?(?:a/c|account)\s*(?:no\.?)?\s*(?:xxxx|[x*]+)?\s*(?<acct>\d{4})',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'upi',
        confidenceBoost: 0.25,
        version: 3,
        enabled: true,
      ),

      // ── Canara Bank ───────────────────────────────────────────────────────
      DetectionPattern(
        id: 'canara_debit_v3',
        bank: 'Canara Bank',
        type: 'debit',
        senderPatterns: ['canbnk', 'canbk', 'canara'],
        regex: RegExp(
          r'(?:inr|rs\.?|₹)\s*(?<amount>[\d]+(?:\.\d{1,2})?)\s*(?:has\s*been\s*)?debited\s*from\s*(?:your\s*)?(?:a/c|account)\s*(?:no\.?)?\s*[x]+\s*(?<acct>\d{4})',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'upi',
        confidenceBoost: 0.25,
        version: 3,
        enabled: true,
      ),

      // ── Union Bank ────────────────────────────────────────────────────────
      DetectionPattern(
        id: 'union_debit_v3',
        bank: 'Union Bank',
        type: 'debit',
        senderPatterns: ['ubibnk', 'unionb', 'unionbank'],
        regex: RegExp(
          r'(?:inr|rs\.?|₹)\s*(?<amount>[\d]+(?:\.\d{1,2})?)\s*(?:is\s*)?debited\s*from\s*(?:your\s*)?(?:a/c|account)\s*(?:no\.?)?\s*(?:xx|[x*]+)?\s*(?<acct>\d{4})',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'upi',
        confidenceBoost: 0.25,
        version: 3,
        enabled: true,
      ),

      // ── RBL Bank ──────────────────────────────────────────────────────────
      DetectionPattern(
        id: 'rbl_debit_v3',
        bank: 'RBL Bank',
        type: 'debit',
        senderPatterns: ['rblbnk', 'rblbkn', 'rblbank', 'rbl'],
        regex: RegExp(
          r'(?:inr|rs\.?|₹)\s*(?<amount>[\d]+(?:\.\d{1,2})?)\s*debited\s*from\s*(?:a/c|account)\s*(?:xx|[x*]+)?\s*(?<acct>\d{4})',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'upi',
        confidenceBoost: 0.25,
        version: 3,
        enabled: true,
      ),

      // ── Federal Bank ──────────────────────────────────────────────────────
      DetectionPattern(
        id: 'federal_debit_v3',
        bank: 'Federal Bank',
        type: 'debit',
        senderPatterns: ['fedbnk', 'fedral', 'federalbank', 'federal'],
        regex: RegExp(
          r'(?:inr|rs\.?|₹)\s*(?<amount>[\d]+(?:\.\d{1,2})?)\s*debited\s*from\s*(?:a/c|account)\s*(?:xxxx|[x*]+)?\s*(?<acct>\d{4})',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'upi',
        confidenceBoost: 0.25,
        version: 3,
        enabled: true,
      ),

      // ── Bandhan Bank ──────────────────────────────────────────────────────
      DetectionPattern(
        id: 'bandhan_debit_v3',
        bank: 'Bandhan Bank',
        type: 'debit',
        senderPatterns: ['bandhb', 'bandhn', 'bandhanbank', 'bandhan'],
        regex: RegExp(
          r'(?:inr|rs\.?|₹)\s*(?<amount>[\d]+(?:\.\d{1,2})?)\s*(?:has\s*been\s*)?debited\s*from\s*(?:your\s*)?'
          r'(?:a/c|account)\s*(?:no\.?)?\s*(?:xx|[x*]+)?\s*(?<acct>\d{4})',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'upi',
        confidenceBoost: 0.25,
        version: 3,
        enabled: true,
      ),

      // ── Generic: UPI reference line (catches any bank) ────────────────────
      // Matches: \bdr\b or \bcr\b + amount + "upi/dr/REF/Merchant"
      DetectionPattern(
        id: 'generic_upi_refline_v2',
        bank: 'Generic',
        type: 'debit',
        senderPatterns: [],
        regex: RegExp(
          r'\b(?<typeK>dr|cr)\b[^\d\n]{0,40}?(?:inr|rs\.?|₹)?\s*(?<amount>[\d]+(?:\.\d{1,2})?)'
          r'(?:.*?upi/(?:dr|cr)/(?<ref>\d{6,})/(?<merchant>[^/\s][^/\r\n]{0,50}?)(?=\s*(?:bal|balance|fraud|avl|avail|\d{2}-[a-z]|$|\n)))?',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant'},
        paymentMethod: 'upi',
        confidenceBoost: 0.20,
        version: 2,
        enabled: true,
      ),

      // ── Generic: IMPS/NEFT/RTGS ───────────────────────────────────────────
      DetectionPattern(
        id: 'generic_imps_neft_v2',
        bank: 'Generic',
        type: 'debit',
        senderPatterns: [],
        regex: RegExp(
          r'(?:imps|neft|rtgs)\s*(?:of|for|ref)?\s*(?:inr|rs\.?|₹)?\s*(?<amount>[\d]+(?:\.\d{1,2})?)'
          r'(?:.*?(?:to|from)\s+(?<merchant>[a-z0-9][a-z0-9 .\-_@]{1,40}?)(?:\s*ref|\s*on|\s*\.|$))?'
          r'(?:.*?(?:a/c|account)\s*(?:xx|[x*]+)?\s*(?<acct>\d{4}))?',
          caseSensitive: false,
        ),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'bank_transfer',
        confidenceBoost: 0.15,
        version: 2,
        enabled: true,
      ),
    ];
  }
}
