import 'package:equatable/equatable.dart';

class DetectionMetadata extends Equatable {
  final double confidence;
  final String source;
  final String senderPackage;
  final String senderName;
  final String? matchedPatternId;
  final List<String> matchedRules;
  final String classificationMethod;
  final String? extractedRefNumber;
  final String? extractedAccountLast4;
  final String? rawText;

  const DetectionMetadata({
    required this.confidence,
    required this.source,
    required this.senderPackage,
    required this.senderName,
    this.matchedPatternId,
    required this.matchedRules,
    required this.classificationMethod,
    this.extractedRefNumber,
    this.extractedAccountLast4,
    this.rawText,
  });

  factory DetectionMetadata.fromJson(Map<String, dynamic> json) {
    return DetectionMetadata(
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
      source: json['source'] as String? ?? 'sms',
      senderPackage: json['senderPackage'] as String? ?? '',
      senderName: json['senderName'] as String? ?? '',
      matchedPatternId: json['matchedPatternId'] as String?,
      matchedRules: (json['matchedRules'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      classificationMethod: json['classificationMethod'] as String? ?? 'fallback_inference',
      extractedRefNumber: json['extractedRefNumber'] as String?,
      extractedAccountLast4: json['extractedAccountLast4'] as String?,
      rawText: json['rawText'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'confidence': confidence,
      'source': source,
      'senderPackage': senderPackage,
      'senderName': senderName,
      'matchedPatternId': matchedPatternId,
      'matchedRules': matchedRules,
      'classificationMethod': classificationMethod,
      'extractedRefNumber': extractedRefNumber,
      'extractedAccountLast4': extractedAccountLast4,
      'rawText': rawText,
    };
  }

  @override
  List<Object?> get props => [
        confidence,
        source,
        senderPackage,
        senderName,
        matchedPatternId,
        matchedRules,
        classificationMethod,
        extractedRefNumber,
        extractedAccountLast4,
        rawText,
      ];
}
