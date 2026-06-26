import '../../../../features/expenses/domain/entities/transaction_entity.dart';
import '../../utils/logger.dart';
import 'models/detection_metadata.dart';
import 'text_normalizer.dart';
import 'exclusion_filter.dart';
import 'pattern_matcher.dart';
import 'field_extractor.dart';
import 'confidence_scorer.dart';
import 'deduplicator.dart';
import 'category_mapper.dart';
import 'package:uuid/uuid.dart';

class DetectionResult {
  final TransactionEntity? transaction;
  final bool isDuplicate;
  final String? exclusionReason;
  final double confidence;

  const DetectionResult({
    this.transaction,
    this.isDuplicate = false,
    this.exclusionReason,
    this.confidence = 0.0,
  });
}

class DetectionPipeline {
  static const double autoCreateThreshold = 0.70;
  static const double reviewQueueThreshold = 0.40;


  static Future<DetectionResult?> process({
    required String packageName,
    required String title,
    required String body,
    required String userId,
  }) async {
    final rawText = '$title. $body';
    
    // 1. Source Gate (Optional: currently we allow all to catch SMS, but we could filter)
    // if (!_allowedPackages.contains(packageName) && !packageName.contains('messaging')) {
    //   return null; 
    // }

    // 2. Normalize Text
    final normalizedText = TextNormalizer.normalize(rawText);

    // 3. Exclusion Filter
    final exclusionReason = ExclusionFilter.getExclusionReason(normalizedText);
    if (exclusionReason != null) {
      AppLogger.d('DetectionPipeline: Excluded due to $exclusionReason');
      return DetectionResult(exclusionReason: exclusionReason);
    }

    // 4. Pattern Matcher
    final matchResult = PatternMatcher.match(normalizedText, title); // Using title as sender
    if (matchResult == null) {
      return const DetectionResult();
    }

    // 5. Extract Fields
    final extractedFields = FieldExtractor.extract(matchResult, normalizedText);
    if (extractedFields == null) {
      return const DetectionResult();
    }

    // 6. Confidence Score
    final confidenceScore = ConfidenceScorer.score(
      normalizedText: normalizedText,
      sender: title,
      matchResult: matchResult,
      extractedFields: extractedFields,
    );

    // 7. Deduplicator
    // We only deduplicate if confidence is at least reviewQueueThreshold
    if (confidenceScore.score >= reviewQueueThreshold) {
      final isDuplicate = await Deduplicator.isDuplicate(
        userId: userId,
        fields: extractedFields,
        timestamp: DateTime.now(),
      );

      if (isDuplicate) {
        AppLogger.d('DetectionPipeline: Duplicate detected');
        return DetectionResult(
          isDuplicate: true,
          confidence: confidenceScore.score,
        );
      }
    } else {
      AppLogger.d('DetectionPipeline: Confidence too low (${confidenceScore.score})');
      return DetectionResult(confidence: confidenceScore.score);
    }

    // 8. Category Mapper
    final mappedCategory = CategoryMapper.mapCategory(
      type: extractedFields.type,
      merchant: extractedFields.merchant,
      normalizedText: normalizedText,
    );

    // 9. Tier Gate
    // In Phase 5 we will gate robust features (like specific templates and category mapping)
    // based on EntitlementService. For now, we let it pass.
    
    // 10. Construct Entity & Metadata
    final metadata = DetectionMetadata(
      confidence: confidenceScore.score,
      source: packageName.contains('messaging') ? 'sms' : 'notification',
      senderPackage: packageName,
      senderName: title,
      matchedPatternId: matchResult.pattern?.id,
      matchedRules: confidenceScore.matchedRules,
      classificationMethod: mappedCategory.method,
      extractedRefNumber: extractedFields.referenceNumber,
      extractedAccountLast4: extractedFields.accountLast4,
      // rawText: rawText, // Disabled for privacy by default
    );

    final transaction = TransactionEntity(
      id: const Uuid().v4(),
      userId: userId,
      title: extractedFields.merchant ?? 'Unknown Merchant',
      amount: extractedFields.amount,
      type: extractedFields.type == 'expense' ? TransactionType.expense : TransactionType.income,
      expenseCategory: mappedCategory.expenseCategory,
      incomeCategory: mappedCategory.incomeCategory,
      date: extractedFields.date ?? DateTime.now(),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == extractedFields.paymentMethod,
        orElse: () => PaymentMethod.other,
      ),
      notes: 'Auto-logged from notification alert',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      detectionMeta: metadata,
      isPending: confidenceScore.score < autoCreateThreshold,
    );

    return DetectionResult(
      transaction: transaction,
      confidence: confidenceScore.score,
    );
  }
}
