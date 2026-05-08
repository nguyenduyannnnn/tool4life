import '../entities/finance_category_entity.dart';
import '../entities/finance_summary_entity.dart';
import '../entities/transaction_entity.dart';

abstract class FinanceRepository {
  Future<List<TransactionEntity>> getTransactionsByMonth(DateTime month);

  Future<List<FinanceCategoryEntity>> getCategories();

  Future<List<FinanceCategoryEntity>> getCategoriesByType(TransactionType type);

  Future<FinanceSummaryEntity> getMonthlySummary(DateTime month);

  Future<void> createTransaction(TransactionEntity transaction);

  Future<void> updateTransaction(TransactionEntity transaction);

  Future<void> deleteTransaction(String id);

  Future<void> seedDefaultCategories();
}
