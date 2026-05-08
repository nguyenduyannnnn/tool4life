import '../entities/transaction_entity.dart';
import '../repositories/finance_repository.dart';

class CreateTransaction {
  final FinanceRepository repository;

  CreateTransaction(this.repository);

  Future<void> call(TransactionEntity transaction) {
    return repository.createTransaction(transaction);
  }
}
