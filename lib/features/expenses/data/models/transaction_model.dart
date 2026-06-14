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
  });

  /// Factory constructor to parse dynamic JSON structures (such as API payloads or Firestore maps).
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      amount: (json['amount'] as num? ?? 0.0).toDouble(),
      type: TransactionType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => TransactionType.expense,
      ),
      expenseCategory: json['expenseCategory'] != null
          ? ExpenseCategory.values.firstWhere(
              (e) => e.name == json['expenseCategory'],
              orElse: () => ExpenseCategory.other,
            )
          : null,
      incomeCategory: json['incomeCategory'] != null
          ? IncomeCategory.values.firstWhere(
              (e) => e.name == json['incomeCategory'],
              orElse: () => IncomeCategory.other,
            )
          : null,
      date: json['date'] != null ? DateTime.parse(json['date'] as String) : DateTime.now(),
      notes: json['notes'] as String? ?? '',
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name == (json['paymentMethod'] ?? 'cash'),
        orElse: () => PaymentMethod.cash,
      ),
      attachmentUrl: json['attachmentUrl'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : DateTime.now(),
      isRecurring: json['isRecurring'] as bool? ?? false,
      recurringId: json['recurringId'] as String?,
      processedForXp: json['processedForXp'] as bool? ?? false,
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
      'date': date.toIso8601String(),
      'notes': notes,
      'paymentMethod': paymentMethod.name,
      'attachmentUrl': attachmentUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isRecurring': isRecurring,
      'recurringId': recurringId,
      'processedForXp': processedForXp,
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
    );
  }
}
