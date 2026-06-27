import '../../features/expenses/domain/entities/transaction_entity.dart';

/// [ParsedSmsTransaction] — represents details parsed from an SMS transaction alert.
class ParsedSmsTransaction {
  final String title;
  final double amount;
  final TransactionType type;
  final ExpenseCategory? expenseCategory;
  final IncomeCategory? incomeCategory;
  final PaymentMethod paymentMethod;

  ParsedSmsTransaction({
    required this.title,
    required this.amount,
    required this.type,
    this.expenseCategory,
    this.incomeCategory,
    required this.paymentMethod,
  });
}

/// [SmsParser] — parsing utility equipped with advanced false-positive filters to distinguish banking SMS alerts from promotional materials.
class SmsParser {
  // Negative keywords indicating promotional offers or non-transactions.
  static const List<String> _promoKeywords = [
    'offer', 'apply', 'pre-approved', 'pre approved', 'eligible', 'discount',
    'cashback of', 'win', 'avail', 'limit', 'recharge now', 'congratulations',
    'gift', 'bonus', 'otp', 'verification code', 'valid till', 'code is',
    'verify', 'recharge for', 'upgrade', 'loan up to', 'claim', 'renew', 'recharge'
  ];

  // Positive references required to verify the message is related to a card or bank account.
  static const List<String> _accountReferences = [
    'a/c', 'acc', 'account', 'ending', 'xx', 'card', 'vpa', 'upi', 'wallet', 'bank', 'no.'
  ];

  // Offline category keyword mapping
  static final Map<String, ExpenseCategory> _expenseCategoryMap = {
    'zomato': ExpenseCategory.foodAndDining,
    'swiggy': ExpenseCategory.foodAndDining,
    'mcdonald': ExpenseCategory.foodAndDining,
    'starbucks': ExpenseCategory.foodAndDining,
    'kfc': ExpenseCategory.foodAndDining,
    'burger king': ExpenseCategory.foodAndDining,
    'pizza': ExpenseCategory.foodAndDining,
    'restaurant': ExpenseCategory.foodAndDining,
    'cafe': ExpenseCategory.foodAndDining,
    'food': ExpenseCategory.foodAndDining,
    
    'uber': ExpenseCategory.transportation,
    'ola': ExpenseCategory.transportation,
    'rapido': ExpenseCategory.transportation,
    'metro': ExpenseCategory.transportation,
    'petrol': ExpenseCategory.fuel,
    'fuel': ExpenseCategory.fuel,
    'shell': ExpenseCategory.fuel,
    'hpcl': ExpenseCategory.fuel,
    'bpcl': ExpenseCategory.fuel,
    
    'netflix': ExpenseCategory.subscriptions,
    'spotify': ExpenseCategory.subscriptions,
    'youtube': ExpenseCategory.subscriptions,
    'prime': ExpenseCategory.subscriptions,
    'disney': ExpenseCategory.subscriptions,
    
    'amazon': ExpenseCategory.shoppingAndFashion,
    'flipkart': ExpenseCategory.shoppingAndFashion,
    'myntra': ExpenseCategory.shoppingAndFashion,
    'ajio': ExpenseCategory.shoppingAndFashion,
    'zara': ExpenseCategory.shoppingAndFashion,
    'nike': ExpenseCategory.shoppingAndFashion,
    'decathlon': ExpenseCategory.shoppingAndFashion,
    
    'hospital': ExpenseCategory.healthAndFitness,
    'pharmacy': ExpenseCategory.healthAndFitness,
    'apollo': ExpenseCategory.healthAndFitness,
    'doctor': ExpenseCategory.healthAndFitness,
    'medical': ExpenseCategory.healthAndFitness,
    'gym': ExpenseCategory.healthAndFitness,
    'fitness': ExpenseCategory.healthAndFitness,
  };

  static final Map<String, IncomeCategory> _incomeCategoryMap = {
    'salary': IncomeCategory.salary,
    'wages': IncomeCategory.salary,
    'payroll': IncomeCategory.salary,
    'freelance': IncomeCategory.freelance,
    'upwork': IncomeCategory.freelance,
    'fiverr': IncomeCategory.freelance,
    'dividend': IncomeCategory.investments,
    'mutual fund': IncomeCategory.investments,
    'groww': IncomeCategory.investments,
    'zerodha': IncomeCategory.investments,
    'airdrop': IncomeCategory.cryptoAndWeb3,
    'staking': IncomeCategory.cryptoAndWeb3,
    'patreon': IncomeCategory.contentCreation,
    'ko-fi': IncomeCategory.contentCreation,
    'youtube payout': IncomeCategory.contentCreation,
  };

  /// Parses sender and SMS message body to extract structured transaction data.
  /// Returns null if the message is promotional, lacks account verification, or is unparsable.
  static ParsedSmsTransaction? parse(String sender, String body) {
    final lowerBody = body.toLowerCase();
    final lowerSender = sender.toLowerCase();

    // 1. Source Filter (Ensure sender aligns with typical financial broadcast formats)
    final isPersonalMobile = RegExp(r'^\+?[0-9]{10,12}$').hasMatch(sender);
    final hasFinancialKeywords = lowerSender.contains('bk') ||
        lowerSender.contains('bnk') ||
        lowerSender.contains('pay') ||
        lowerSender.contains('sbi') ||
        lowerSender.contains('hdfc') ||
        lowerSender.contains('icici') ||
        lowerSender.contains('axis') ||
        lowerSender.contains('kotak') ||
        lowerSender.contains('card') ||
        lowerSender.contains('upi') ||
        lowerSender.contains('bank');

    if (isPersonalMobile && !hasFinancialKeywords) {
      final hasStrongMarkers = lowerBody.contains('debited') || lowerBody.contains('credited');
      if (!hasStrongMarkers) return null; // Ignore standard personal messages unless formatted as alerts
    }

    // 2. Exclusion Match: Discard promotional alerts immediately
    for (final word in _promoKeywords) {
      if (lowerBody.contains(word)) {
        return null;
      }
    }

    // 3. Double-Confirmation: Verify message references an account or card
    bool hasAccountRef = false;
    for (final ref in _accountReferences) {
      if (lowerBody.contains(ref)) {
        hasAccountRef = true;
        break;
      }
    }
    if (!hasAccountRef) {
      return null;
    }

    // 4. Extract Action Verb (Transaction Type)
    TransactionType? type;
    if (RegExp(r'\b(?:debited|spent|paid|withdrawn|charged|sent|dr\b)', caseSensitive: false).hasMatch(lowerBody)) {
      type = TransactionType.expense;
    } else if (RegExp(r'\b(?:credited|received|deposited|added|cr\b)', caseSensitive: false).hasMatch(lowerBody)) {
      type = TransactionType.income;
    }

    if (type == null) {
      return null;
    }

    // 5. Extract Amount (Strip commas and capture digits following currency marks)
    final amountMatch = RegExp(
      r'(?:inr|rs\.?|rs)\s*([0-9,]+(?:\.[0-9]{1,2})?)',
      caseSensitive: false,
    ).firstMatch(lowerBody);

    if (amountMatch == null) {
      return null;
    }

    final amountString = amountMatch.group(1)!.replaceAll(',', '');
    final amount = double.tryParse(amountString);
    if (amount == null || amount <= 0) {
      return null;
    }

    // 6. Extract Recipient / Merchant Name
    String merchant = '';
    final merchantMatch = RegExp(
      r'(?:to|at|at\s+merchant|info|vpa|to\s+vpa)\s+([A-Za-z0-9\s\.\*]+?)(?:\s+on|\s+using|\s+for|\s+Ref|\.|$)',
      caseSensitive: false,
    ).firstMatch(lowerBody);

    if (merchantMatch != null) {
      merchant = merchantMatch.group(1)!.trim();
      merchant = merchant.replaceAll(RegExp(r'\s+'), ' ');
      if (merchant.length > 20) {
        merchant = merchant.substring(0, 20);
      }
    }

    // 7. Map Payment Method
    PaymentMethod paymentMethod = PaymentMethod.other;
    if (lowerBody.contains('upi') || lowerBody.contains('vpa') || lowerBody.contains('gpay') || lowerBody.contains('phonepe') || lowerBody.contains('paytm')) {
      paymentMethod = PaymentMethod.upi;
    } else if (lowerBody.contains('credit card') || lowerBody.contains('cc')) {
      paymentMethod = PaymentMethod.creditCard;
    } else if (lowerBody.contains('debit card') || lowerBody.contains('dc') || lowerBody.contains('card')) {
      paymentMethod = PaymentMethod.debitCard;
    } else if (lowerBody.contains('transfer') || lowerBody.contains('neft') || lowerBody.contains('rtgs') || lowerBody.contains('imps')) {
      paymentMethod = PaymentMethod.bankTransfer;
    }

    // 8. Offline Classification mapping
    ExpenseCategory? expenseCategory;
    IncomeCategory? incomeCategory;

    final lookupText = '$lowerBody $merchant'.toLowerCase();
    
    if (type == TransactionType.expense) {
      expenseCategory = ExpenseCategory.other;
      for (final entry in _expenseCategoryMap.entries) {
        if (lookupText.contains(entry.key)) {
          expenseCategory = entry.value;
          break;
        }
      }
    } else {
      incomeCategory = IncomeCategory.other;
      for (final entry in _incomeCategoryMap.entries) {
        if (lookupText.contains(entry.key)) {
          incomeCategory = entry.value;
          break;
        }
      }
    }

    return ParsedSmsTransaction(
      title: merchant.isNotEmpty ? merchant.toUpperCase() : (type == TransactionType.expense ? 'AUTO EXPENSE' : 'AUTO INCOME'),
      amount: amount,
      type: type,
      expenseCategory: expenseCategory,
      incomeCategory: incomeCategory,
      paymentMethod: paymentMethod,
    );
  }
}
