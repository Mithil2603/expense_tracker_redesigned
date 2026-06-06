import 'package:flutter/material.dart';

/// Type of financial transaction.
enum TransactionType { expense, income }

/// Comprehensive payment methods for transaction tracking.
enum PaymentMethod {
  cash,
  creditCard,
  debitCard,
  bankTransfer,
  upi,
  other,
}

extension PaymentMethodExtension on PaymentMethod {
  String get displayName {
    switch (this) {
      case PaymentMethod.cash:
        return 'Cash';
      case PaymentMethod.creditCard:
        return 'Credit Card';
      case PaymentMethod.debitCard:
        return 'Debit Card';
      case PaymentMethod.bankTransfer:
        return 'Bank Transfer';
      case PaymentMethod.upi:
        return 'UPI / QR Code';
      case PaymentMethod.other:
        return 'Other Payment';
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentMethod.cash:
        return Icons.money_rounded;
      case PaymentMethod.creditCard:
        return Icons.credit_card_rounded;
      case PaymentMethod.debitCard:
        return Icons.payment_rounded;
      case PaymentMethod.bankTransfer:
        return Icons.account_balance_rounded;
      case PaymentMethod.upi:
        return Icons.qr_code_scanner_rounded;
      case PaymentMethod.other:
        return Icons.account_balance_wallet_rounded;
    }
  }
}

/// A highly detailed list of all possible expense categories to support granular filters.
enum ExpenseCategory {
  foodAndDining,
  transportation,
  utilities,
  shopping,
  entertainment,
  healthAndFitness,
  education,
  travel,
  personalCare,
  familyAndKids,
  giftsAndDonations,
  financial,
  business,
  other,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.foodAndDining:
        return 'Food & Dining';
      case ExpenseCategory.transportation:
        return 'Transportation';
      case ExpenseCategory.utilities:
        return 'Bills & Utilities';
      case ExpenseCategory.shopping:
        return 'Shopping';
      case ExpenseCategory.entertainment:
        return 'Entertainment & Leisure';
      case ExpenseCategory.healthAndFitness:
        return 'Health & Fitness';
      case ExpenseCategory.education:
        return 'Education';
      case ExpenseCategory.travel:
        return 'Travel & Vacation';
      case ExpenseCategory.personalCare:
        return 'Personal Care';
      case ExpenseCategory.familyAndKids:
        return 'Family & Kids';
      case ExpenseCategory.giftsAndDonations:
        return 'Gifts & Donations';
      case ExpenseCategory.financial:
        return 'Financial (Taxes/Fees)';
      case ExpenseCategory.business:
        return 'Business Expense';
      case ExpenseCategory.other:
        return 'Other Expense';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.foodAndDining:
        return Icons.fastfood_rounded;
      case ExpenseCategory.transportation:
        return Icons.directions_transit_rounded;
      case ExpenseCategory.utilities:
        return Icons.receipt_rounded;
      case ExpenseCategory.shopping:
        return Icons.local_mall_rounded;
      case ExpenseCategory.entertainment:
        return Icons.celebration_rounded;
      case ExpenseCategory.healthAndFitness:
        return Icons.medical_services_rounded;
      case ExpenseCategory.education:
        return Icons.school_rounded;
      case ExpenseCategory.travel:
        return Icons.flight_takeoff_rounded;
      case ExpenseCategory.personalCare:
        return Icons.face_rounded;
      case ExpenseCategory.familyAndKids:
        return Icons.child_care_rounded;
      case ExpenseCategory.giftsAndDonations:
        return Icons.volunteer_activism_rounded;
      case ExpenseCategory.financial:
        return Icons.monetization_on_rounded;
      case ExpenseCategory.business:
        return Icons.business_center_rounded;
      case ExpenseCategory.other:
        return Icons.widgets_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.foodAndDining:
        return const Color(0xFFFF6B6B);
      case ExpenseCategory.transportation:
        return const Color(0xFF2ECC71);
      case ExpenseCategory.utilities:
        return const Color(0xFF9B59B6);
      case ExpenseCategory.shopping:
        return const Color(0xFF3498DB);
      case ExpenseCategory.entertainment:
        return const Color(0xFFF1C40F);
      case ExpenseCategory.healthAndFitness:
        return const Color(0xFF1ABC9C);
      case ExpenseCategory.education:
        return const Color(0xFFE67E22);
      case ExpenseCategory.travel:
        return const Color(0xFF34495E);
      case ExpenseCategory.personalCare:
        return const Color(0xFFE91E63);
      case ExpenseCategory.familyAndKids:
        return const Color(0xFF9C27B0);
      case ExpenseCategory.giftsAndDonations:
        return const Color(0xFFE74C3C);
      case ExpenseCategory.financial:
        return const Color(0xFF7F8C8D);
      case ExpenseCategory.business:
        return const Color(0xFF3F51B5);
      case ExpenseCategory.other:
        return const Color(0xFF95A5A6);
    }
  }
}

/// A highly detailed list of all possible income categories.
enum IncomeCategory {
  salary,
  freelance,
  business,
  investments,
  gifts,
  rental,
  refunds,
  sideHustle,
  benefits,
  other,
}

extension IncomeCategoryExtension on IncomeCategory {
  String get displayName {
    switch (this) {
      case IncomeCategory.salary:
        return 'Salary & Wages';
      case IncomeCategory.freelance:
        return 'Freelance / Consulting';
      case IncomeCategory.business:
        return 'Business Revenue';
      case IncomeCategory.investments:
        return 'Investment Returns';
      case IncomeCategory.gifts:
        return 'Gifts & Grants';
      case IncomeCategory.rental:
        return 'Rental Income';
      case IncomeCategory.refunds:
        return 'Refunds & Cashbacks';
      case IncomeCategory.sideHustle:
        return 'Side Hustle';
      case IncomeCategory.benefits:
        return 'Government Benefits';
      case IncomeCategory.other:
        return 'Other Income';
    }
  }

  IconData get icon {
    switch (this) {
      case IncomeCategory.salary:
        return Icons.work_rounded;
      case IncomeCategory.freelance:
        return Icons.laptop_mac_rounded;
      case IncomeCategory.business:
        return Icons.store_rounded;
      case IncomeCategory.investments:
        return Icons.trending_up_rounded;
      case IncomeCategory.gifts:
        return Icons.card_giftcard_rounded;
      case IncomeCategory.rental:
        return Icons.home_work_rounded;
      case IncomeCategory.refunds:
        return Icons.replay_rounded;
      case IncomeCategory.sideHustle:
        return Icons.storefront_rounded;
      case IncomeCategory.benefits:
        return Icons.account_balance_rounded;
      case IncomeCategory.other:
        return Icons.account_balance_wallet_rounded;
    }
  }

  Color get color {
    switch (this) {
      case IncomeCategory.salary:
        return const Color(0xFF2ECC71);
      case IncomeCategory.freelance:
        return const Color(0xFF1ABC9C);
      case IncomeCategory.business:
        return const Color(0xFF27AE60);
      case IncomeCategory.investments:
        return const Color(0xFFF1C40F);
      case IncomeCategory.gifts:
        return const Color(0xFFE74C3C);
      case IncomeCategory.rental:
        return const Color(0xFF3498DB);
      case IncomeCategory.refunds:
        return const Color(0xFF9B59B6);
      case IncomeCategory.sideHustle:
        return const Color(0xFFE67E22);
      case IncomeCategory.benefits:
        return const Color(0xFF7F8C8D);
      case IncomeCategory.other:
        return const Color(0xFF95A5A6);
    }
  }
}

/// Represents a financial transaction (either Expense or Income) in the domain layer.
class TransactionEntity {
  final String id;
  final String title;
  final double amount;
  final TransactionType type;
  final ExpenseCategory? expenseCategory;
  final IncomeCategory? incomeCategory;
  final DateTime date;
  final String notes;
  final PaymentMethod paymentMethod;
  final String? attachmentUrl;

  const TransactionEntity({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    this.expenseCategory,
    this.incomeCategory,
    required this.date,
    this.notes = '',
    required this.paymentMethod,
    this.attachmentUrl,
  }) : assert(
          (type == TransactionType.expense && expenseCategory != null) ||
              (type == TransactionType.income && incomeCategory != null),
          'A transaction must have the category corresponding to its type.',
        );

  /// Helper to get the display category name
  String get categoryName {
    if (type == TransactionType.expense) {
      return expenseCategory!.displayName;
    } else {
      return incomeCategory!.displayName;
    }
  }

  /// Helper to get the display category icon
  IconData get categoryIcon {
    if (type == TransactionType.expense) {
      return expenseCategory!.icon;
    } else {
      return incomeCategory!.icon;
    }
  }

  /// Helper to get the category color
  Color get categoryColor {
    if (type == TransactionType.expense) {
      return expenseCategory!.color;
    } else {
      return incomeCategory!.color;
    }
  }
}
