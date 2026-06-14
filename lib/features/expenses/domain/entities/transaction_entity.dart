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
  housingAndRent,
  utilities,
  foodAndDining,
  transportation,
  healthAndFitness,
  shoppingAndFashion,
  entertainmentAndLeisure,
  educationAndLearning,
  travelAndVacation,
  personalCare,
  familyAndKids,
  pets,
  giftsAndDonations,
  financialServices,
  businessAndWork,
  subscriptions,
  investmentsAndSavings,
  taxes,
  insurance,
  cryptoAndWeb3,
  gamingAndDigital,
  other,
}

extension ExpenseCategoryExtension on ExpenseCategory {
  String get displayName {
    switch (this) {
      case ExpenseCategory.housingAndRent:
        return 'Housing & Rent';
      case ExpenseCategory.utilities:
        return 'Bills & Utilities';
      case ExpenseCategory.foodAndDining:
        return 'Food & Dining';
      case ExpenseCategory.transportation:
        return 'Transportation';
      case ExpenseCategory.healthAndFitness:
        return 'Health & Fitness';
      case ExpenseCategory.shoppingAndFashion:
        return 'Shopping & Fashion';
      case ExpenseCategory.entertainmentAndLeisure:
        return 'Entertainment & Leisure';
      case ExpenseCategory.educationAndLearning:
        return 'Education & Learning';
      case ExpenseCategory.travelAndVacation:
        return 'Travel & Vacation';
      case ExpenseCategory.personalCare:
        return 'Personal Care';
      case ExpenseCategory.familyAndKids:
        return 'Family & Kids';
      case ExpenseCategory.pets:
        return 'Pets';
      case ExpenseCategory.giftsAndDonations:
        return 'Gifts & Donations';
      case ExpenseCategory.financialServices:
        return 'Financial Services';
      case ExpenseCategory.businessAndWork:
        return 'Business & Work';
      case ExpenseCategory.subscriptions:
        return 'Subscriptions';
      case ExpenseCategory.investmentsAndSavings:
        return 'Savings & Investments';
      case ExpenseCategory.taxes:
        return 'Taxes';
      case ExpenseCategory.insurance:
        return 'Insurance';
      case ExpenseCategory.cryptoAndWeb3:
        return 'Crypto & Web3';
      case ExpenseCategory.gamingAndDigital:
        return 'Gaming & Digital';
      case ExpenseCategory.other:
        return 'Other Expense';
    }
  }

  IconData get icon {
    switch (this) {
      case ExpenseCategory.housingAndRent:
        return Icons.home_rounded;
      case ExpenseCategory.utilities:
        return Icons.receipt_rounded;
      case ExpenseCategory.foodAndDining:
        return Icons.fastfood_rounded;
      case ExpenseCategory.transportation:
        return Icons.directions_transit_rounded;
      case ExpenseCategory.healthAndFitness:
        return Icons.medical_services_rounded;
      case ExpenseCategory.shoppingAndFashion:
        return Icons.local_mall_rounded;
      case ExpenseCategory.entertainmentAndLeisure:
        return Icons.celebration_rounded;
      case ExpenseCategory.educationAndLearning:
        return Icons.school_rounded;
      case ExpenseCategory.travelAndVacation:
        return Icons.flight_takeoff_rounded;
      case ExpenseCategory.personalCare:
        return Icons.face_rounded;
      case ExpenseCategory.familyAndKids:
        return Icons.child_care_rounded;
      case ExpenseCategory.pets:
        return Icons.pets_rounded;
      case ExpenseCategory.giftsAndDonations:
        return Icons.volunteer_activism_rounded;
      case ExpenseCategory.financialServices:
        return Icons.monetization_on_rounded;
      case ExpenseCategory.businessAndWork:
        return Icons.business_center_rounded;
      case ExpenseCategory.subscriptions:
        return Icons.subscriptions_rounded;
      case ExpenseCategory.investmentsAndSavings:
        return Icons.trending_up_rounded;
      case ExpenseCategory.taxes:
        return Icons.account_balance_rounded;
      case ExpenseCategory.insurance:
        return Icons.admin_panel_settings_rounded;
      case ExpenseCategory.cryptoAndWeb3:
        return Icons.currency_bitcoin_rounded;
      case ExpenseCategory.gamingAndDigital:
        return Icons.sports_esports_rounded;
      case ExpenseCategory.other:
        return Icons.widgets_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ExpenseCategory.housingAndRent:
        return const Color(0xFFE74C3C);
      case ExpenseCategory.utilities:
        return const Color(0xFF9B59B6);
      case ExpenseCategory.foodAndDining:
        return const Color(0xFFFF6B6B);
      case ExpenseCategory.transportation:
        return const Color(0xFF2ECC71);
      case ExpenseCategory.healthAndFitness:
        return const Color(0xFF1ABC9C);
      case ExpenseCategory.shoppingAndFashion:
        return const Color(0xFF3498DB);
      case ExpenseCategory.entertainmentAndLeisure:
        return const Color(0xFFF1C40F);
      case ExpenseCategory.educationAndLearning:
        return const Color(0xFFE67E22);
      case ExpenseCategory.travelAndVacation:
        return const Color(0xFF34495E);
      case ExpenseCategory.personalCare:
        return const Color(0xFFE91E63);
      case ExpenseCategory.familyAndKids:
        return const Color(0xFF9C27B0);
      case ExpenseCategory.pets:
        return const Color(0xFF8B4513);
      case ExpenseCategory.giftsAndDonations:
        return const Color(0xFFF39C12);
      case ExpenseCategory.financialServices:
        return const Color(0xFF7F8C8D);
      case ExpenseCategory.businessAndWork:
        return const Color(0xFF3F51B5);
      case ExpenseCategory.subscriptions:
        return const Color(0xFF16A085);
      case ExpenseCategory.investmentsAndSavings:
        return const Color(0xFF27AE60);
      case ExpenseCategory.taxes:
        return const Color(0xFFD35400);
      case ExpenseCategory.insurance:
        return const Color(0xFF2980B9);
      case ExpenseCategory.cryptoAndWeb3:
        return const Color(0xFFF39C12);
      case ExpenseCategory.gamingAndDigital:
        return const Color(0xFF8E44AD);
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
  sideHustle,
  rental,
  giftsAndInheritance,
  refundsAndCashbacks,
  grantsAndScholarships,
  governmentBenefits,
  cryptoAndWeb3,
  contentCreation,
  royalties,
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
      case IncomeCategory.sideHustle:
        return 'Side Hustle';
      case IncomeCategory.rental:
        return 'Rental Income';
      case IncomeCategory.giftsAndInheritance:
        return 'Gifts & Inheritance';
      case IncomeCategory.refundsAndCashbacks:
        return 'Refunds & Cashbacks';
      case IncomeCategory.grantsAndScholarships:
        return 'Grants & Scholarships';
      case IncomeCategory.governmentBenefits:
        return 'Government Benefits';
      case IncomeCategory.cryptoAndWeb3:
        return 'Crypto & Web3 Income';
      case IncomeCategory.contentCreation:
        return 'Content Creation';
      case IncomeCategory.royalties:
        return 'Royalties';
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
      case IncomeCategory.sideHustle:
        return Icons.storefront_rounded;
      case IncomeCategory.rental:
        return Icons.home_work_rounded;
      case IncomeCategory.giftsAndInheritance:
        return Icons.card_giftcard_rounded;
      case IncomeCategory.refundsAndCashbacks:
        return Icons.replay_rounded;
      case IncomeCategory.grantsAndScholarships:
        return Icons.card_membership_rounded;
      case IncomeCategory.governmentBenefits:
        return Icons.account_balance_rounded;
      case IncomeCategory.cryptoAndWeb3:
        return Icons.currency_bitcoin_rounded;
      case IncomeCategory.contentCreation:
        return Icons.videocam_rounded;
      case IncomeCategory.royalties:
        return Icons.menu_book_rounded;
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
      case IncomeCategory.sideHustle:
        return const Color(0xFFE67E22);
      case IncomeCategory.rental:
        return const Color(0xFF3498DB);
      case IncomeCategory.giftsAndInheritance:
        return const Color(0xFFE74C3C);
      case IncomeCategory.refundsAndCashbacks:
        return const Color(0xFF9B59B6);
      case IncomeCategory.grantsAndScholarships:
        return const Color(0xFF34495E);
      case IncomeCategory.governmentBenefits:
        return const Color(0xFF7F8C8D);
      case IncomeCategory.cryptoAndWeb3:
        return const Color(0xFFF39C12);
      case IncomeCategory.contentCreation:
        return const Color(0xFFE91E63);
      case IncomeCategory.royalties:
        return const Color(0xFF8E44AD);
      case IncomeCategory.other:
        return const Color(0xFF95A5A6);
    }
  }
}

/// Represents a financial transaction (either Expense or Income) in the domain layer.
class TransactionEntity {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final TransactionType type;
  final ExpenseCategory? expenseCategory;
  final IncomeCategory? incomeCategory;
  final DateTime date;
  final String notes;
  final PaymentMethod paymentMethod;
  final String? attachmentUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isRecurring;
  final String? recurringId;
  final bool processedForXp;

  const TransactionEntity({
    required this.id,
    required this.userId,
    required this.title,
    required this.amount,
    required this.type,
    this.expenseCategory,
    this.incomeCategory,
    required this.date,
    this.notes = '',
    required this.paymentMethod,
    this.attachmentUrl,
    required this.createdAt,
    required this.updatedAt,
    this.isRecurring = false,
    this.recurringId,
    this.processedForXp = false,
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
