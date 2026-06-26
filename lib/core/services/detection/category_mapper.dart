import '../../../../features/expenses/domain/entities/transaction_entity.dart';

class MappedCategory {
  final ExpenseCategory? expenseCategory;
  final IncomeCategory? incomeCategory;
  final String method; // 'exact_merchant', 'keyword_inference', 'fallback_inference'

  const MappedCategory({
    this.expenseCategory,
    this.incomeCategory,
    required this.method,
  });
}

class CategoryMapper {
  static Map<String, ExpenseCategory> _merchantExpenseMap = {
    'zomato': ExpenseCategory.foodAndDining,
    'swiggy': ExpenseCategory.foodAndDining,
    'uber': ExpenseCategory.transportation,
    'ola': ExpenseCategory.transportation,
    'rapido': ExpenseCategory.transportation,
    'netflix': ExpenseCategory.subscriptions,
    'spotify': ExpenseCategory.subscriptions,
    'amazon': ExpenseCategory.shoppingAndFashion,
    'flipkart': ExpenseCategory.shoppingAndFashion,
    'apollo': ExpenseCategory.healthAndFitness,
    'irctc': ExpenseCategory.travelAndVacation,
    'hpcl': ExpenseCategory.transportation,
    'bpcl': ExpenseCategory.transportation,
  };

  static Map<String, ExpenseCategory> _keywordExpenseMap = {
    'rent': ExpenseCategory.housingAndRent,
    'electricity': ExpenseCategory.utilities,
    'recharge': ExpenseCategory.utilities,
    'bill': ExpenseCategory.utilities,
    'loan': ExpenseCategory.financialServices,
    'emi': ExpenseCategory.financialServices,
  };

  static Map<String, IncomeCategory> _keywordIncomeMap = {
    'salary': IncomeCategory.salary,
    'payroll': IncomeCategory.salary,
    'dividend': IncomeCategory.investments,
    'interest': IncomeCategory.investments,
    'refund': IncomeCategory.refundsAndCashbacks,
  };

  static void updateMappings({
    required Map<String, ExpenseCategory> merchantExpenseMap,
    required Map<String, ExpenseCategory> keywordExpenseMap,
    required Map<String, IncomeCategory> keywordIncomeMap,
  }) {
    _merchantExpenseMap = merchantExpenseMap;
    _keywordExpenseMap = keywordExpenseMap;
    _keywordIncomeMap = keywordIncomeMap;
  }

  static MappedCategory mapCategory({
    required String type,
    String? merchant,
    required String normalizedText,
  }) {
    if (type == 'expense') {
      // 1. Exact merchant match
      if (merchant != null && merchant.isNotEmpty) {
        final lowerMerchant = merchant.toLowerCase();
        for (final key in _merchantExpenseMap.keys) {
          if (lowerMerchant.contains(key)) {
            return MappedCategory(
              expenseCategory: _merchantExpenseMap[key],
              method: 'exact_merchant',
            );
          }
        }
      }

      // 2. Keyword inference
      for (final key in _keywordExpenseMap.keys) {
        if (normalizedText.contains(key)) {
          return MappedCategory(
            expenseCategory: _keywordExpenseMap[key],
            method: 'keyword_inference',
          );
        }
      }

      // 3. Fallback
      return const MappedCategory(
        expenseCategory: ExpenseCategory.other,
        method: 'fallback_inference',
      );
    } else {
      // Income
      // 1. Keyword inference (incomes usually don't have merchants in the same way)
      for (final key in _keywordIncomeMap.keys) {
        if (normalizedText.contains(key)) {
          return MappedCategory(
            incomeCategory: _keywordIncomeMap[key],
            method: 'keyword_inference',
          );
        }
      }

      // 2. Fallback
      return const MappedCategory(
        incomeCategory: IncomeCategory.other,
        method: 'fallback_inference',
      );
    }
  }
}
