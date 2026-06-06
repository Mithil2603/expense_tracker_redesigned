import '../../domain/entities/transaction_entity.dart';

/// Data Model representing the transaction representation at the API / database layer.
/// Inherits from [TransactionEntity] to maintain clean architecture separation.
class TransactionModel extends TransactionEntity {
  const TransactionModel({
    required super.id,
    required super.title,
    required super.amount,
    required super.type,
    super.expenseCategory,
    super.incomeCategory,
    required super.date,
    super.notes,
    required super.paymentMethod,
    super.attachmentUrl,
  });

  /// Factory constructor to parse dynamic JSON structures (such as API payloads or Firestore maps).
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] as String? ?? '',
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
    );
  }

  /// Converts the data model instance back to a JSON-compatible map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type.name,
      'expenseCategory': expenseCategory?.name,
      'incomeCategory': incomeCategory?.name,
      'date': date.toIso8601String(),
      'notes': notes,
      'paymentMethod': paymentMethod.name,
      'attachmentUrl': attachmentUrl,
    };
  }

  /// Factory constructor to instantiate from a pure domain entity.
  factory TransactionModel.fromEntity(TransactionEntity entity) {
    return TransactionModel(
      id: entity.id,
      title: entity.title,
      amount: entity.amount,
      type: entity.type,
      expenseCategory: entity.expenseCategory,
      incomeCategory: entity.incomeCategory,
      date: entity.date,
      notes: entity.notes,
      paymentMethod: entity.paymentMethod,
      attachmentUrl: entity.attachmentUrl,
    );
  }
}
