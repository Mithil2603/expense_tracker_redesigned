class ExclusionFilter {
  static const List<String> otpPatterns = [
    'otp',
    'one time password',
    'one-time',
    'do not share',
    'verification code',
    'code is',
    'your code',
  ];

  static const List<String> promoPatterns = [
    'offer',
    'cashback upto',
    '% off',
    'limited period',
    'apply now',
    'pre-approved',
    'pre approved',
    'eligible for',
    'congratulations',
    'avail',
    'upgrade',
    'claim',
    'recharge now',
    'subscribe to',
    'win',
    'bonus',
    'referral',
    'invite',
  ];

  static const List<String> reminderPatterns = [
    'bill due',
    'payment reminder',
    'emi due',
    'due date',
    'autopay scheduled',
    'upcoming payment',
  ];

  static const List<String> deliveryPatterns = [
    'delivered',
    'shipped',
    'out for delivery',
    'tracking',
  ];

  static const List<String> transactionVerbs = [
    'debit',
    'credit',
    'paid',
    'received',
    'sent',
    'deducted',
    'spent',
  ];

  /// Returns true if the text should be excluded from further processing.
  static bool shouldExclude(String normalizedText) {
    if (_containsAny(normalizedText, otpPatterns)) return true;
    if (_containsAny(normalizedText, promoPatterns)) return true;
    if (_containsAny(normalizedText, reminderPatterns)) return true;
    if (_containsAny(normalizedText, deliveryPatterns)) return true;

    // Balance-only check: if it mentions balance but has no transaction verb
    final hasBalance = normalizedText.contains('balance') || normalizedText.contains('bal');
    final hasTxnVerb = _containsAny(normalizedText, transactionVerbs);
    if (hasBalance && !hasTxnVerb) return true;

    return false;
  }

  /// Returns the reason for exclusion, or null if it shouldn't be excluded.
  static String? getExclusionReason(String normalizedText) {
    if (_containsAny(normalizedText, otpPatterns)) return 'OTP';
    if (_containsAny(normalizedText, promoPatterns)) return 'Promotion';
    if (_containsAny(normalizedText, reminderPatterns)) return 'Reminder';
    if (_containsAny(normalizedText, deliveryPatterns)) return 'Delivery';
    
    final hasBalance = normalizedText.contains('balance') || normalizedText.contains('bal');
    final hasTxnVerb = _containsAny(normalizedText, transactionVerbs);
    if (hasBalance && !hasTxnVerb) return 'Balance-only';

    return null;
  }

  static bool _containsAny(String text, List<String> patterns) {
    return patterns.any((pattern) => text.contains(pattern.toLowerCase()));
  }
}
