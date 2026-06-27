import '../../../expenses/domain/entities/transaction_entity.dart';
import '../entities/financial_report.dart';

class GenerateReport {
  FinancialReport call({
    required List<TransactionEntity> transactions,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    // 1. Date filtering MUST occur before any calculations
    final filtered = transactions.where((t) {
      return t.date.isAfter(startDate.subtract(const Duration(microseconds: 1))) &&
             t.date.isBefore(endDate.add(const Duration(microseconds: 1)));
    }).toList();

    double totalIncome = 0.0;
    double totalExpense = 0.0;
    final Map<ExpenseCategory, double> categoryExpenses = {};
    final Map<IncomeCategory, double> categoryIncomes = {};

    // 2. Single optimized iteration through the filtered dataset
    for (final tx in filtered) {
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
        if (tx.incomeCategory != null) {
          categoryIncomes[tx.incomeCategory!] =
              (categoryIncomes[tx.incomeCategory!] ?? 0.0) + tx.amount;
        }
      } else {
        totalExpense += tx.amount;
        if (tx.expenseCategory != null) {
          categoryExpenses[tx.expenseCategory!] =
              (categoryExpenses[tx.expenseCategory!] ?? 0.0) + tx.amount;
        }
      }
    }

    final netSavings = totalIncome - totalExpense;
    final savingsRate = totalIncome > 0
        ? ((netSavings / totalIncome) * 100.0).clamp(0.0, 100.0)
        : 0.0;

    return FinancialReport(
      startDate: startDate,
      endDate: endDate,
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      netSavings: netSavings,
      savingsRate: savingsRate,
      categoryExpenses: categoryExpenses,
      categoryIncomes: categoryIncomes,
      filteredTransactions: filtered,
    );
  }
}
