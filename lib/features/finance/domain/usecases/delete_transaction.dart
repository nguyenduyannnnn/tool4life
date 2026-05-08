import '../repositories/finance_repository.dart';

class DeleteTransaction {
  final FinanceRepository repository;

  DeleteTransaction(this.repository);

  Future<void> call(String id) {
    return repository.deleteTransaction(id);
  }
}
