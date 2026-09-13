class TextNormalizer {
  /// Normalizes notification/SMS text for pattern matching.
  /// Steps: lowercase → currency standardization → comma removal from numbers
  ///        → abbreviation expansion → whitespace collapse.
  static String normalize(String text) {
    if (text.isEmpty) return text;

    String normalized = text.toLowerCase();

    // Standardize currency symbols to the token 'inr'
    normalized = normalized.replaceAll(RegExp(r'₹'), 'inr ');
    normalized = normalized.replaceAll(RegExp(r'\brs\.?\b', caseSensitive: false), 'inr');

    // NOTE: We do NOT replace "inr" with "inr " here — it is already "inr".
    // This avoids double-space injection.

    // Remove commas between digits (Indian lakh formatting: 1,50,000 → 150000)
    // Run twice to handle overlapping triplets like 1,23,456
    for (int i = 0; i < 2; i++) {
      normalized = normalized.replaceAllMapped(
        RegExp(r'(\d),(\d)'),
        (m) => '${m.group(1)}${m.group(2)}',
      );
    }

    // Expand common banking abbreviations
    final abbreviations = <String, String>{
      r'\ba/c\b':  'a/c',     // Keep a/c as-is — patterns match it literally
      r'\bacct\b': 'account',
      r'\btxn\b':  'transaction',
      r'\bamt\b':  'amount',
      r'\bavl\b':  'available',
      // NOTE: do NOT expand 'bal' → 'balance' here because pattern regexes
      // use '(?=\s*(?:balance|bal|...))' as stop conditions — we keep 'bal' intact
      // but also match 'balance' in the exclusion filter below.
    };

    abbreviations.forEach((pattern, replacement) {
      normalized = normalized.replaceAll(RegExp(pattern), replacement);
    });

    // Normalize line breaks to spaces, then collapse multiple spaces
    normalized = normalized.replaceAll(RegExp(r'[\r\n\t]+'), ' ');
    normalized = normalized.replaceAll(RegExp(r' {2,}'), ' ');

    return normalized.trim();
  }
}
