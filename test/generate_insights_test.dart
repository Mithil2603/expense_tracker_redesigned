import 'package:flutter_test/flutter_test.dart';
import 'package:fingo/features/analytics/domain/entities/financial_report.dart';
import 'package:fingo/features/analytics/domain/usecases/generate_insights.dart';
import 'package:fingo/features/expenses/domain/entities/transaction_entity.dart';

void main() {
  final usecase = GenerateInsights();

  group('GenerateInsights Use Case Tests', () {
    test('Should calculate correct health score normalized for quarterly and yearly reports', () {
      final now = DateTime.now();

      // Monthly Period: Income 10,000, Expense 8,000 (Savings 2,000, Savings Rate 20%)
      final monthlyReport = FinancialReport(
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
        totalIncome: 10000.0,
        totalExpense: 8000.0,
        netSavings: 2000.0,
        savingsRate: 20.0,
        categoryExpenses: {
          ExpenseCategory.foodAndDining: 3000.0,
          ExpenseCategory.shoppingAndFashion: 2000.0,
        },
        categoryIncomes: {
          IncomeCategory.salary: 10000.0,
        },
        filteredTransactions: [
          TransactionEntity(
            id: 't1',
            userId: 'user',
            title: 'Salary',
            amount: 10000.0,
            type: TransactionType.income,
            date: DateTime(now.year, now.month, 5),
            incomeCategory: IncomeCategory.salary,
            paymentMethod: PaymentMethod.bankTransfer,
            createdAt: now,
            updatedAt: now,
          ),
          TransactionEntity(
            id: 't2',
            userId: 'user',
            title: 'Rent',
            amount: 3000.0,
            type: TransactionType.expense,
            date: DateTime(now.year, now.month, 10),
            expenseCategory: ExpenseCategory.housingAndRent,
            paymentMethod: PaymentMethod.bankTransfer,
            createdAt: now,
            updatedAt: now,
          ),
          TransactionEntity(
            id: 't3',
            userId: 'user',
            title: 'Food',
            amount: 5000.0,
            type: TransactionType.expense,
            date: DateTime(now.year, now.month, 15),
            expenseCategory: ExpenseCategory.foodAndDining,
            paymentMethod: PaymentMethod.upi,
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );

      // Yearly Period: 12x identical behavior (Income 120,000, Expense 96,000)
      final yearlyReport = FinancialReport(
        startDate: DateTime(now.year, 1, 1),
        endDate: DateTime(now.year, 12, 31),
        totalIncome: 120000.0,
        totalExpense: 96000.0,
        netSavings: 24000.0,
        savingsRate: 20.0,
        categoryExpenses: {
          ExpenseCategory.foodAndDining: 36000.0,
          ExpenseCategory.shoppingAndFashion: 24000.0,
        },
        categoryIncomes: {
          IncomeCategory.salary: 120000.0,
        },
        filteredTransactions: [],
      );

      final monthlyResult = usecase.call(
        report: monthlyReport,
        allTransactions: monthlyReport.filteredTransactions,
        monthlyBudget: 9000.0,
      );

      final yearlyResult = usecase.call(
        report: yearlyReport,
        allTransactions: [],
        monthlyBudget: 9000.0,
      );

      // Health Score should remain highly similar across periods under normalized budgets
      expect((monthlyResult.intelligence.healthScore.score - yearlyResult.intelligence.healthScore.score).abs(), lessThanOrEqualTo(5));
    });

    test('Should generate separate spending and income stories in story timeline', () {
      final now = DateTime.now();

      final report = FinancialReport(
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
        totalIncome: 15000.0,
        totalExpense: 5000.0,
        netSavings: 10000.0,
        savingsRate: 66.6,
        categoryExpenses: {
          ExpenseCategory.foodAndDining: 3000.0,
          ExpenseCategory.shoppingAndFashion: 2000.0,
        },
        categoryIncomes: {
          IncomeCategory.salary: 15000.0,
        },
        filteredTransactions: [
          TransactionEntity(
            id: 't1',
            userId: 'user',
            title: 'Monthly Salary Payment',
            amount: 15000.0,
            type: TransactionType.income,
            date: DateTime(now.year, now.month, 1),
            incomeCategory: IncomeCategory.salary,
            paymentMethod: PaymentMethod.bankTransfer,
            createdAt: now,
            updatedAt: now,
          ),
          TransactionEntity(
            id: 't2',
            userId: 'user',
            title: 'Dinner at Restaurant',
            amount: 3000.0,
            type: TransactionType.expense,
            date: DateTime(now.year, now.month, 10),
            expenseCategory: ExpenseCategory.foodAndDining,
            paymentMethod: PaymentMethod.upi,
            createdAt: now,
            updatedAt: now,
          ),
          TransactionEntity(
            id: 't3',
            userId: 'user',
            title: 'New Clothes',
            amount: 2000.0,
            type: TransactionType.expense,
            date: DateTime(now.year, now.month, 20),
            expenseCategory: ExpenseCategory.shoppingAndFashion,
            paymentMethod: PaymentMethod.creditCard,
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );

      final result = usecase.call(
        report: report,
        allTransactions: report.filteredTransactions,
        monthlyBudget: 6000.0,
      );

      final timeline = result.intelligence.timelineEvents;

      // Verify spending and income are separate, e.g. Salary is primary income stream
      final hasSalaryAsIncomeStreamText = timeline.any((s) => s.contains('Salary & Wages remained the primary income stream'));
      final hasDominantExpenseText = timeline.any((s) => s.contains('spending became the dominant expense category'));

      expect(hasSalaryAsIncomeStreamText, isTrue);
      expect(hasDominantExpenseText, isTrue);

      // Verify that income category is never labeled as a spending shift/focus
      for (final event in timeline) {
        if (event.contains('spending became the dominant') || event.contains('spending activity peaked')) {
          expect(event.contains('Salary'), isFalse);
          expect(event.contains('Wages'), isFalse);
        }
      }
    });

    test('Should assign correct Savings Opportunity parameters', () {
      final now = DateTime.now();

      final currentReport = FinancialReport(
        startDate: DateTime(now.year, now.month, 1),
        endDate: DateTime(now.year, now.month + 1, 0),
        totalIncome: 10000.0,
        totalExpense: 6000.0,
        netSavings: 4000.0,
        savingsRate: 40.0,
        categoryExpenses: {
          ExpenseCategory.foodAndDining: 4000.0,
        },
        categoryIncomes: {
          IncomeCategory.salary: 10000.0,
        },
        filteredTransactions: [
          TransactionEntity(
            id: 't_curr',
            userId: 'user',
            title: 'Food Delivery',
            amount: 4000.0,
            type: TransactionType.expense,
            date: DateTime(now.year, now.month, 15),
            expenseCategory: ExpenseCategory.foodAndDining,
            paymentMethod: PaymentMethod.upi,
            createdAt: now,
            updatedAt: now,
          ),
        ],
      );

      // Previous period transactions
      final prevTransactions = <TransactionEntity>[
        TransactionEntity(
          id: 't_prev',
          userId: 'user',
          title: 'Food Delivery Old',
          amount: 2000.0,
          type: TransactionType.expense,
          date: DateTime(now.year, now.month, 1).subtract(const Duration(days: 15)),
          expenseCategory: ExpenseCategory.foodAndDining,
          paymentMethod: PaymentMethod.upi,
          createdAt: now,
          updatedAt: now,
        ),
      ];

      final allTransactions = <TransactionEntity>[...currentReport.filteredTransactions, ...prevTransactions];

      final result = usecase.call(
        report: currentReport,
        allTransactions: allTransactions,
        monthlyBudget: 5000.0,
      );

      final leaks = result.intelligence.moneyLeaks;
      expect(leaks, isNotEmpty);

      final leak = leaks.first;
      expect(leak.category, equals('Food & Dining'));
      expect(leak.confidenceLevel, equals('High')); // growth from 2000 to 4000 is 100% growth
      expect(leak.leakReason, contains('spending increased 100%'));
      expect(leak.leakReason, contains('this is a High impact expense')); // 4000 is 40% of 10000 income
      expect(leak.potentialMonthlySavings, greaterThan(0.0));
      expect(leak.potentialAnnualSavings, equals(leak.potentialMonthlySavings * 12));
    });
  });
}
