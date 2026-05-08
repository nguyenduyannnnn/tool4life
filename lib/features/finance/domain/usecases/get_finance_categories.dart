import '../entities/finance_category_entity.dart';
import '../entities/transaction_entity.dart';
import '../repositories/finance_repository.dart';

class GetFinanceCategories {
  final FinanceRepository repository;

  GetFinanceCategories(this.repository);

  Future<List<FinanceCategoryEntity>> call({TransactionType? type}) {
    if (type == null) return repository.getCategories();
    return repository.getCategoriesByType(type);
  }
}
