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
    'netflix': ExpenseCategory.telecomAndRecharges,
    'spotify': ExpenseCategory.telecomAndRecharges,
    'amazon': ExpenseCategory.shoppingAndFashion,
    'flipkart': ExpenseCategory.shoppingAndFashion,
    'apollo': ExpenseCategory.healthAndFitness,
    'irctc': ExpenseCategory.travelAndVacation,
    'hpcl': ExpenseCategory.vehicleAndTransport,
    'bpcl': ExpenseCategory.vehicleAndTransport,
    'indianoil': ExpenseCategory.vehicleAndTransport,
    'shell': ExpenseCategory.vehicleAndTransport,
    'reliance petro': ExpenseCategory.vehicleAndTransport,
    'fasttag': ExpenseCategory.vehicleAndTransport,
    'nhai': ExpenseCategory.vehicleAndTransport,
    'jio': ExpenseCategory.telecomAndRecharges,
    'airtel': ExpenseCategory.telecomAndRecharges,
    'vi': ExpenseCategory.telecomAndRecharges,
    'bsnl': ExpenseCategory.telecomAndRecharges,
    'act': ExpenseCategory.telecomAndRecharges,
    'hathway': ExpenseCategory.telecomAndRecharges,
    'tata play': ExpenseCategory.telecomAndRecharges,
    'dish tv': ExpenseCategory.telecomAndRecharges,
    'hotstar': ExpenseCategory.telecomAndRecharges,
    'jiocinema': ExpenseCategory.telecomAndRecharges,
    'amazon prime': ExpenseCategory.telecomAndRecharges,
    'blinkit': ExpenseCategory.groceries,
    'zepto': ExpenseCategory.groceries,
    'instamart': ExpenseCategory.groceries,
    'bigbasket': ExpenseCategory.groceries,
    'dmart': ExpenseCategory.groceries,
  };

  static Map<String, ExpenseCategory> _keywordExpenseMap = {
    'rent': ExpenseCategory.housingAndRent,
    'electricity': ExpenseCategory.utilities,
    'recharge': ExpenseCategory.telecomAndRecharges,
    'prepaid': ExpenseCategory.telecomAndRecharges,
    'postpaid': ExpenseCategory.telecomAndRecharges,
    'broadband': ExpenseCategory.telecomAndRecharges,
    'dth': ExpenseCategory.telecomAndRecharges,
    'talktime': ExpenseCategory.telecomAndRecharges,
    'data pack': ExpenseCategory.telecomAndRecharges,
    'validity': ExpenseCategory.telecomAndRecharges,
    'subscription': ExpenseCategory.telecomAndRecharges,
    'bill': ExpenseCategory.utilities,
    'loan': ExpenseCategory.financialServices,
    'emi': ExpenseCategory.financialServices,
    'grocery': ExpenseCategory.groceries,
    'supermarket': ExpenseCategory.groceries,
    'mart': ExpenseCategory.groceries,
    'vegetables': ExpenseCategory.groceries,
    'fruits': ExpenseCategory.groceries,
    'sent to': ExpenseCategory.transferredToOthers,
    'paid to': ExpenseCategory.transferredToOthers,
    'transfer to': ExpenseCategory.transferredToOthers,
    'upi transfer': ExpenseCategory.transferredToOthers,
    'friend': ExpenseCategory.transferredToOthers,
    'repair': ExpenseCategory.hardwareRepair,
    'hardware': ExpenseCategory.hardwareRepair,
    'service center': ExpenseCategory.vehicleAndTransport,
    'mechanic': ExpenseCategory.vehicleAndTransport,
    'service': ExpenseCategory.vehicleAndTransport,
    'petrol': ExpenseCategory.vehicleAndTransport,
    'diesel': ExpenseCategory.vehicleAndTransport,
    'fuel': ExpenseCategory.vehicleAndTransport,
    'tyre': ExpenseCategory.vehicleAndTransport,
    'garage': ExpenseCategory.vehicleAndTransport,
    'insurance': ExpenseCategory.vehicleAndTransport,
    'fastag': ExpenseCategory.vehicleAndTransport,
    'toll': ExpenseCategory.vehicleAndTransport,
    'parking': ExpenseCategory.vehicleAndTransport,
    'rto': ExpenseCategory.vehicleAndTransport,
    'vehicle': ExpenseCategory.vehicleAndTransport,
    'fix': ExpenseCategory.hardwareRepair,
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
