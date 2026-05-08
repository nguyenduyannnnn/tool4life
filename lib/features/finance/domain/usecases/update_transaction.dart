import '../entities/transaction_entity.dart';
import '../repositories/finance_repository.dart';

class UpdateTransaction {
  final FinanceRepository repository;

  UpdateTransaction(this.repository);

  Future<void> call(TransactionEntity transaction) {
    return repository.updateTransaction(transaction);
  }
}
