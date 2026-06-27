import 'models/detection_pattern.dart';

class PatternMatchResult {
  final DetectionPattern? pattern;
  final RegExpMatch match;

  const PatternMatchResult(this.pattern, this.match);
}

class PatternMatcher {
  static List<DetectionPattern> _patterns = _getDefaultPatterns();

  /// Updates the pattern library (e.g. from Remote Config).
  static void updatePatterns(List<DetectionPattern> newPatterns) {
    _patterns = newPatterns;
  }

  /// Attempts to match the normalized text against known bank templates.
  /// Falls back to a generic regex if no template matches.
  static PatternMatchResult? match(String normalizedText, String sender) {
    final lowerSender = sender.toLowerCase();

    // 1. Try to find a specific template match
    // Sort patterns by version descending, then by confidence boost descending
    final activePatterns = _patterns.where((p) => p.enabled).toList()
      ..sort((a, b) {
        if (a.version != b.version) return b.version.compareTo(a.version);
        return b.confidenceBoost.compareTo(a.confidenceBoost);
      });

    for (final pattern in activePatterns) {
      // Check if the sender matches any of the pattern's sender patterns
      final senderMatches = pattern.senderPatterns.any((sp) => lowerSender.contains(sp.toLowerCase()));
      if (senderMatches) {
        final match = pattern.regex.firstMatch(normalizedText);
        if (match != null) {
          return PatternMatchResult(pattern, match);
        }
      }
    }

    // 2. Generic Fallback Regex if no template matched
    // Captures amounts near common transaction keywords
    final genericRegex = RegExp(
      r'(?:debited|credited|spent|paid|received|deducted|dr|cr).*?(?:inr|rs|₹)?\s*(?<amount>[\d,]+(?:\.\d{1,2})?)|(?:inr|rs|₹)?\s*(?<amount2>[\d,]+(?:\.\d{1,2})?).*?(?:debited|credited|spent|paid|received|deducted|dr|cr)',
      caseSensitive: false,
    );

    final genericMatch = genericRegex.firstMatch(normalizedText);
    if (genericMatch != null) {
      return PatternMatchResult(null, genericMatch);
    }

    return null;
  }

  static List<DetectionPattern> _getDefaultPatterns() {
    return [
      DetectionPattern(
        id: 'hdfc_debit_upi_v1',
        bank: 'HDFC',
        type: 'debit',
        senderPatterns: ['HDFCBK', 'HDFC', 'HDFCBANK'],
        regex: RegExp(r'(?:account|a\/c)\s*(?:xx|ending)?\s*(?<acct>\d{4})\s*(?:debited|paid)\s*(?:by)?\s*(?:inr)?\s*(?<amount>[\d,]+(?:\.\d{1,2})?)\s*(?:to|for|at)\s*(?<merchant>[a-z0-9\s\.]+?)\s*(?:on|ref|upi)', caseSensitive: false),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'upi',
        confidenceBoost: 0.2,
        version: 1,
        enabled: true,
      ),
      DetectionPattern(
        id: 'sbi_debit_upi_v1',
        bank: 'SBI',
        type: 'debit',
        senderPatterns: ['SBIUPI', 'SBI', 'STATEBANK'],
        regex: RegExp(r'debited\s*(?:by)?\s*(?:inr)?\s*(?<amount>[\d,]+(?:\.\d{1,2})?)\s*from\s*(?:a\/c|account)\s*(?<acct>\d{4}).*?to\s*(?<merchant>[a-z0-9\s\.]+?)\s*(?:ref|upi)', caseSensitive: false),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'upi',
        confidenceBoost: 0.2,
        version: 1,
        enabled: true,
      ),
      DetectionPattern(
        id: 'au_debit_upi_v1',
        bank: 'AU Bank',
        type: 'debit',
        senderPatterns: ['AUBANK', 'AU Bank', 'AU SMALL', 'AU'],
        regex: RegExp(r'dr\s*(?:inr|rs)?\s*(?<amount>[\d,]+(?:\.\d{1,2})?)\s*-\s*au\s*account\s*(?:x|ending)?\s*(?<acct>\d{4}).*?upi\/dr\/\d+\/(?<merchant>[^\/]+)', caseSensitive: false),
        extractionMap: {'amount': 'amount', 'merchant': 'merchant', 'accountLast4': 'acct'},
        paymentMethod: 'upi',
        confidenceBoost: 0.3,
        version: 1,
        enabled: true,
      ),
      // Add more bundled defaults as needed
    ];
  }
}
