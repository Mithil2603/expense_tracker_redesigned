class TextNormalizer {
  /// Normalizes notification text by lowercasing, stripping noise,
  /// standardizing currencies, and expanding abbreviations.
  static String normalize(String text) {
    if (text.isEmpty) return text;

    String normalized = text.toLowerCase();

    // Standardize currency symbols
    normalized = normalized.replaceAll(RegExp(r'₹|rs\.?|inr', caseSensitive: false), 'inr ');

    // Handle comma-formatted numbers (Indian lakh format): 1,50,000.00 -> 150000.00
    // We only want to remove commas that are between digits.
    normalized = normalized.replaceAllMapped(
      RegExp(r'(\d),(\d)'),
      (match) => '${match.group(1)}${match.group(2)}',
    );
    // Run it again to catch overlapping matches like 1,50,000
    normalized = normalized.replaceAllMapped(
      RegExp(r'(\d),(\d)'),
      (match) => '${match.group(1)}${match.group(2)}',
    );

    // Expand common abbreviations
    final abbreviations = {
      r'\ba/c\b': 'account',
      r'\bacct\b': 'account',
      r'\btxn\b': 'transaction',
      r'\bamt\b': 'amount',
      r'\bbal\b': 'balance',
      r'\bref\b': 'reference',
    };

    abbreviations.forEach((pattern, replacement) {
      normalized = normalized.replaceAll(RegExp(pattern), replacement);
    });

    // Strip excessive whitespace and newlines
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');

    return normalized.trim();
  }
}
