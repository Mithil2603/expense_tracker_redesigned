class ExclusionFilter {
  static List<String> otpPatterns = [
    'otp',
    'one time password',
    'one-time password',
    'do not share',
    'verification code',
    'code is',
    'your code',
    'passcode',
  ];

  static List<String> promoPatterns = [
    'cashback upto',
    '% off',
    'limited period',
    'apply now',
    'pre-approved',
    'pre approved',
    'eligible for',
    'avail now',
    'upgrade your',
    'claim your',
    'recharge now',
    'subscribe to',
    'win up to',
    'referral code',
    'invite friends',
    'special offer',
    'exclusive offer',
  ];

  static List<String> reminderPatterns = [
    'bill due',
    'payment reminder',
    'emi due',
    'due date',
    'autopay scheduled',
    'upcoming payment',
    'minimum due',
    'total due',
    'last date',
    'pay now to avoid',
  ];

  static List<String> deliveryPatterns = [
    'out for delivery',
    'order shipped',
    'order delivered',
    'your order',
  ];

  /// Keywords that confirm the message IS a real transaction
  static List<String> transactionVerbs = [
    'debited',
    'credited',
    'paid',
    'received',
    'sent',
    'deducted',
    'spent',
    'upi/dr',
    'upi/cr',
    '\bdr\b',
    '\bcr\b',
  ];

  static void updateRules({
    required List<String> otpPatterns,
    required List<String> promoPatterns,
    required List<String> reminderPatterns,
    required List<String> deliveryPatterns,
    required List<String> transactionVerbs,
  }) {
    ExclusionFilter.otpPatterns      = otpPatterns;
    ExclusionFilter.promoPatterns    = promoPatterns;
    ExclusionFilter.reminderPatterns = reminderPatterns;
    ExclusionFilter.deliveryPatterns = deliveryPatterns;
    ExclusionFilter.transactionVerbs = transactionVerbs;
  }

  /// Returns the reason for exclusion, or null if it should be processed.
  static String? getExclusionReason(String normalizedText) {
    if (_containsAny(normalizedText, otpPatterns))      return 'OTP';
    if (_containsAny(normalizedText, promoPatterns))    return 'Promotion';
    if (_containsAny(normalizedText, reminderPatterns)) return 'Reminder';
    if (_containsAny(normalizedText, deliveryPatterns)) return 'Delivery';

    // Balance-only check: only exclude if there's a balance reference AND
    // NO real transaction verb. Bank debit/credit SMSes always have both.
    final hasBalance = normalizedText.contains('balance') ||
        RegExp(r'\bbal\b').hasMatch(normalizedText);
    final hasTxnVerb = _containsAnyRegex(normalizedText, transactionVerbs);
    if (hasBalance && !hasTxnVerb) return 'Balance-only';

    return null;
  }

  static bool _containsAny(String text, List<String> patterns) {
    return patterns.any((p) => text.contains(p.toLowerCase()));
  }

  /// Supports both plain string and \b-anchored regex patterns in the list.
  static bool _containsAnyRegex(String text, List<String> patterns) {
    for (final p in patterns) {
      if (p.contains(r'\b') || p.contains('/')) {
        if (RegExp(p, caseSensitive: false).hasMatch(text)) return true;
      } else {
        if (text.contains(p.toLowerCase())) return true;
      }
    }
    return false;
  }
}
