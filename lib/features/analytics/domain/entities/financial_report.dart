import '../../../expenses/domain/entities/transaction_entity.dart';

class FinancialReport {
  final DateTime startDate;
  final DateTime endDate;
  final double totalIncome;
  final double totalExpense;
  final double netSavings;
  final double savingsRate; // Percentage (0.0 to 100.0)
  final Map<ExpenseCategory, double> categoryExpenses;
  final Map<IncomeCategory, double> categoryIncomes;
  final List<TransactionEntity> filteredTransactions;

  const FinancialReport({
    required this.startDate,
    required this.endDate,
    required this.totalIncome,
    required this.totalExpense,
    required this.netSavings,
    required this.savingsRate,
    required this.categoryExpenses,
    required this.categoryIncomes,
    required this.filteredTransactions,
  });
}
