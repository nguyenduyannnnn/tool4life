import '../entities/finance_summary_entity.dart';
import '../repositories/finance_repository.dart';

class GetMonthlyFinanceSummary {
  final FinanceRepository repository;

  GetMonthlyFinanceSummary(this.repository);

  Future<FinanceSummaryEntity> call(DateTime month) {
    return repository.getMonthlySummary(month);
  }
}
