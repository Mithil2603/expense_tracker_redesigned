import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/detection/models/detection_metadata.dart';
import '../../domain/entities/transaction_entity.dart';

/// Data Model representing the transaction representation at the API / database layer.
/// Inherits from [TransactionEntity] to maintain clean architecture separation.
class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.userId,
    required super.title,
    required super.amount,
    required super.type,
    super.expenseCategory,
    super.incomeCategory,
    required super.date,
    super.notes,
    required super.paymentMethod,
    super.attachmentUrl,
    required super.createdAt,
    required super.updatedAt,
    super.isRecurring = false,
    super.recurringId,
    super.processedForXp = false,
    super.detectionMeta,
    super.isPending = false,
  });

  /// Resolves the title from various legacy field names.
  /// Old app may store the description in 'merchant' instead of 'title'.
  static String _resolveTitle(Map<String, dynamic> json) {
    final title = json['title'] as String? ?? '';
    if (title.isNotEmpty) return title;
    // Legacy fallback: old app used 'merchant' field
    final merchant = json['merchant'] as String? ?? '';
    if (merchant.isNotEmpty) return merchant;
    return 'Transaction';
  }

  /// Factory constructor to parse dynamic JSON structures (such as API payloads or Firestore maps).
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDateTime(dynamic val) {
      if (val is Timestamp) {
        return val.toDate();
      } else if (val is String) {
        return DateTime.parse(val);
      }
      return DateTime.now();
    }

    final date = parseDateTime(json['date']);
    final createdAt = json['createdAt'] != null ? parseDateTime(json['createdAt']) : date;
    final updatedAt = json['updatedAt'] != null ? parseDateTime(json['updatedAt']) : date;

    final rawType = (json['type'] as String? ?? 'expense').toLowerCase();
    final type = TransactionType.values.firstWhere(
      (e) => e.name.toLowerCase() == rawType,
      orElse: () => TransactionType.expense,
    );

    ExpenseCategory? expenseCategory;
    IncomeCategory? incomeCategory;

    if (type == TransactionType.expense) {
      if (json['expenseCategory'] != null) {
        expenseCategory = ExpenseCategory.values.firstWhere(
          (e) => e.name == json['expenseCategory'],
          orElse: () => ExpenseCategory.other,
        );
      } else if (json['category'] != null) {
        final categoryStr = json['category'] as String;
        expenseCategory = ExpenseCategory.values.firstWhere(
          (e) => e.name.toLowerCase() == categoryStr.toLowerCase() || e.displayName.toLowerCase() == categoryStr.toLowerCase(),
          orElse: () {
            // Try fallback mappings for common legacy categories
            final lower = categoryStr.toLowerCase();
            if (lower.contains('rent') || lower.contains('house') || lower.contains('home')) {
              return ExpenseCategory.housingAndRent;
            }
            if (lower.contains('bill') || lower.contains('util') || lower.contains('power') || lower.contains('electricity')) {
              return ExpenseCategory.utilities;
            }
            if (lower.contains('food') || lower.contains('dining') || lower.contains('restaurant') || lower.contains('lunch') || lower.contains('dinner') || lower.contains('cafe')) {
              return ExpenseCategory.foodAndDining;
            }
            if (lower.contains('cab') || lower.contains('auto') || lower.contains('travel') || lower.contains('transport') || lower.contains('uber') || lower.contains('ola') || lower.contains('metro')) {
              return ExpenseCategory.transportation;
            }
            if (lower.contains('health') || lower.contains('fit') || lower.contains('medical') || lower.contains('doctor') || lower.contains('pharmacy') || lower.contains('gym')) {
              return ExpenseCategory.healthAndFitness;
            }
            if (lower.contains('shop') || lower.contains('clothing') || lower.contains('mall') || lower.contains('grocer')) {
              return ExpenseCategory.shoppingAndFashion;
            }
            if (lower.contains('movie') || lower.contains('entertainment') || lower.contains('fun') || lower.contains('leisure') || lower.contains('show')) {
              return ExpenseCategory.entertainmentAndLeisure;
            }
            if (lower.contains('education') || lower.contains('learn') || lower.contains('school') || lower.contains('college') || lower.contains('book')) {
              return ExpenseCategory.educationAndLearning;
            }
            if (lower.contains('loan') || lower.contains('emi') || lower.contains('interest') || lower.contains('finance') || lower.contains('fee')) {
              return ExpenseCategory.financialServices;
            }
            return ExpenseCategory.other;
          },
        );
      } else {
        // Neither expenseCategory nor category field present — assign default
        expenseCategory = ExpenseCategory.other;
      }
    } else {
      if (json['incomeCategory'] != null) {
        incomeCategory = IncomeCategory.values.firstWhere(
          (e) => e.name == json['incomeCategory'],
          orElse: () => IncomeCategory.other,
        );
      } else if (json['category'] != null) {
        final categoryStr = json['category'] as String;
        incomeCategory = IncomeCategory.values.firstWhere(
          (e) => e.name.toLowerCase() == categoryStr.toLowerCase() || e.displayName.toLowerCase() == categoryStr.toLowerCase(),
          orElse: () {
            final lower = categoryStr.toLowerCase();
            if (lower.contains('salary') || lower.contains('wage') || lower.contains('pay')) {
              return IncomeCategory.salary;
            }
            if (lower.contains('freelance') || lower.contains('consult') || lower.contains('gig')) {
              return IncomeCategory.freelance;
            }
            if (lower.contains('business') || lower.contains('revenue') || lower.contains('sale')) {
              return IncomeCategory.business;
            }
            if (lower.contains('invest') || lower.contains('dividend') || lower.contains('interest') || lower.contains('stock') || lower.contains('mutual')) {
              return IncomeCategory.investments;
            }
            if (lower.contains('gift') || lower.contains('inherit')) {
              return IncomeCategory.giftsAndInheritance;
            }
            return IncomeCategory.other;
          },
        );
      } else {
        // Neither incomeCategory nor category field present — assign default
        incomeCategory = IncomeCategory.other;
      }
    }

    final detectionMetaJson = json['detectionMeta'] as Map<String, dynamic>?;
    final detectionMeta = detectionMetaJson != null ? DetectionMetadata.fromJson(detectionMetaJson) : null;

    return TransactionModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: _resolveTitle(json),
      amount: (json['amount'] as num? ?? 0.0).toDouble(),
      type: type,
      expenseCategory: expenseCategory,
      incomeCategory: incomeCategory,
      date: date,
      notes: json['notes'] as String? ?? '',
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == (json['paymentMethod'] ?? 'cash'),
        orElse: () => PaymentMethod.cash,
      ),
      attachmentUrl: json['attachmentUrl'] as String?,
      createdAt: createdAt,
      updatedAt: updatedAt,
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringId: json['recurringId'] as String?,
      processedForXp: json['processedForXp'] as bool? ?? false,
      detectionMeta: detectionMeta,
      isPending: json['isPending'] as bool? ?? false,
    );
  }

  /// Converts the data model instance back to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'amount': amount,
      'type': type.name,
      'expenseCategory': expenseCategory?.name,
      'incomeCategory': incomeCategory?.name,
      'category': type == TransactionType.expense
          ? (expenseCategory?.displayName ?? '')
          : (incomeCategory?.displayName ?? ''),
      'date': Timestamp.fromDate(date),
      'notes': notes,
      'paymentMethod': paymentMethod.name,
      'attachmentUrl': attachmentUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'isRecurring': isRecurring,
      'recurringId': recurringId,
      'processedForXp': processedForXp,
      if (detectionMeta != null) 'detectionMeta': detectionMeta!.toJson(),
      'isPending': isPending,
    };
  }

  /// Factory constructor to instantiate from a pure domain entity.
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      userId: entity.userId,
      title: entity.title,
      amount: entity.amount,
      type: entity.type,
      expenseCategory: entity.expenseCategory,
      incomeCategory: entity.incomeCategory,
      date: entity.date,
      notes: entity.notes,
      paymentMethod: entity.paymentMethod,
      attachmentUrl: entity.attachmentUrl,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      isRecurring: entity.isRecurring,
      recurringId: entity.recurringId,
      processedForXp: entity.processedForXp,
      detectionMeta: entity.detectionMeta,
      isPending: entity.isPending,
    );
  }
}
