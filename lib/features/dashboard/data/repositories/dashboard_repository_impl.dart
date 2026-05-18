import '../../../finance/domain/entities/finance_category_entity.dart';
import '../../../finance/domain/entities/finance_summary_entity.dart';
import '../../../finance/domain/entities/transaction_entity.dart';
import '../../../finance/domain/repositories/finance_repository.dart';
import '../../../places/domain/entities/place_entity.dart';
import '../../../places/domain/repositories/places_repository.dart';
import '../../../todo/domain/entities/todo_entity.dart';
import '../../../todo/domain/repositories/todo_repository.dart';
import '../../domain/entities/dashboard_summary_entity.dart';
import '../../domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final TodoRepository todoRepository;
  final FinanceRepository financeRepository;
  final PlacesRepository placesRepository;

  const DashboardRepositoryImpl({
    required this.todoRepository,
    required this.financeRepository,
    required this.placesRepository,
  });

  @override
  Future<DashboardSummaryEntity> getDashboardSummary() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monthStart = DateTime(now.year, now.month, 1);

    final results = await Future.wait<Object>([
      todoRepository.getTodosByDate(today),
      financeRepository.getMonthlySummary(monthStart),
      placesRepository.getAllPlaces(),
      financeRepository.getTransactionsByMonth(monthStart),
      financeRepository.getCategories(),
    ]);

    final todos = results[0] as List<TodoEntity>;
    final summary = results[1] as FinanceSummaryEntity;
    final places = results[2] as List<PlaceEntity>;
    final monthTransactions = results[3] as List<TransactionEntity>;
    final categories = results[4] as List<FinanceCategoryEntity>;

    final sortedTransactions = List<TransactionEntity>.from(monthTransactions)
      ..sort((a, b) {
        final byDate = b.date.compareTo(a.date);
        if (byDate != 0) return byDate;
        return b.createdAt.compareTo(a.createdAt);
      });
    final recentTransactions = sortedTransactions.take(5).toList();

    final withImage = places.where((p) => p.imagePaths.isNotEmpty).toList()
      ..sort((a, b) => b.visitedAt.compareTo(a.visitedAt));

    final featured = withImage.isNotEmpty ? withImage.first : null;
    final imagePath = featured != null && featured.imagePaths.isNotEmpty
        ? featured.imagePaths.first
        : null;

    final totalTodos = todos.length;
    final completedTodos = todos.where((t) => t.isCompleted).length;
    final progress = totalTodos == 0 ? 0.0 : completedTodos / totalTodos;

    return DashboardSummaryEntity(
      todayTodos: todos,
      totalTodos: totalTodos,
      completedTodos: completedTodos,
      todoProgress: progress,
      totalIncome: summary.totalIncome,
      totalExpense: summary.totalExpense,
      balance: summary.balance,
      recentTransactions: recentTransactions,
      financeCategories: categories,
      featuredPlace: featured,
      featuredImagePath: imagePath,
      generatedAt: DateTime.now(),
    );
  }
}
