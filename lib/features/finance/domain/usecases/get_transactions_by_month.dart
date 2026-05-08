import '../entities/transaction_entity.dart';
import '../repositories/finance_repository.dart';

class GetTransactionsByMonth {
  final FinanceRepository repository;

  GetTransactionsByMonth(this.repository);

  Future<List<TransactionEntity>> call(DateTime month) {
    return repository.getTransactionsByMonth(month);
  }
}
