class DetectionPattern {
  final String id;
  final String bank;
  final String type; // 'debit' or 'credit'
  final List<String> senderPatterns;
  final RegExp regex;
  final Map<String, String> extractionMap;
  final String? paymentMethod;
  final double confidenceBoost;
  final int version;
  final bool enabled;

  const DetectionPattern({
    required this.id,
    required this.bank,
    required this.type,
    required this.senderPatterns,
    required this.regex,
    required this.extractionMap,
    this.paymentMethod,
    this.confidenceBoost = 0.0,
    required this.version,
    required this.enabled,
  });

  factory DetectionPattern.fromJson(Map<String, dynamic> json) {
    return DetectionPattern(
      id: json['id'] as String,
      bank: json['bank'] as String,
      type: json['type'] as String,
      senderPatterns: (json['senderPatterns'] as List<dynamic>).map((e) => e as String).toList(),
      regex: RegExp(json['regex'] as String, caseSensitive: false),
      extractionMap: Map<String, String>.from(json['extractionMap'] as Map),
      paymentMethod: json['paymentMethod'] as String?,
      confidenceBoost: (json['confidenceBoost'] as num?)?.toDouble() ?? 0.0,
      version: json['version'] as int? ?? 1,
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}
