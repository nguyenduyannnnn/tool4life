import '../../domain/entities/finance_category_entity.dart';
import '../../domain/entities/finance_summary_entity.dart';
import '../../domain/entities/transaction_entity.dart';
import '../../domain/repositories/finance_repository.dart';
import '../datasources/finance_local_datasource.dart';
import '../models/finance_category_model.dart';
import '../models/transaction_model.dart';

class FinanceRepositoryImpl implements FinanceRepository {
  final FinanceLocalDataSource localDataSource;

  FinanceRepositoryImpl(this.localDataSource);

  @override
  Future<List<TransactionEntity>> getTransactionsByMonth(
      DateTime month) async {
    final models = await localDataSource.getTransactionsByMonth(month);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<FinanceCategoryEntity>> getCategories() async {
    final models = await localDataSource.getAllCategories();
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<List<FinanceCategoryEntity>> getCategoriesByType(
      TransactionType type) async {
    final models = await localDataSource.getCategoriesByType(type);
    return models.map((m) => m.toEntity()).toList();
  }

  @override
  Future<FinanceSummaryEntity> getMonthlySummary(DateTime month) async {
    final txs = await localDataSource.getTransactionsByMonth(month);
    double totalIncome = 0;
    double totalExpense = 0;
    final incomeByCat = <String, double>{};
    final expenseByCat = <String, double>{};

    for (final tx in txs) {
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
        incomeByCat.update(
          tx.categoryId,
          (v) => v + tx.amount,
          ifAbsent: () => tx.amount,
        );
      } else {
        totalExpense += tx.amount;
        expenseByCat.update(
          tx.categoryId,
          (v) => v + tx.amount,
          ifAbsent: () => tx.amount,
        );
      }
    }

    return FinanceSummaryEntity(
      totalIncome: totalIncome,
      totalExpense: totalExpense,
      incomeByCategory: incomeByCat,
      expenseByCategory: expenseByCat,
    );
  }

  @override
  Future<void> createTransaction(TransactionEntity transaction) {
    return localDataSource
        .upsertTransaction(TransactionModel.fromEntity(transaction));
  }

  @override
  Future<void> updateTransaction(TransactionEntity transaction) {
    return localDataSource.upsertTransaction(
      TransactionModel.fromEntity(transaction.copyWith(
        updatedAt: DateTime.now(),
      )),
    );
  }

  @override
  Future<void> deleteTransaction(String id) {
    return localDataSource.deleteTransactionById(id);
  }

  @override
  Future<void> seedDefaultCategories() async {
    final count = await localDataSource.countCategories();
    if (count > 0) return;

    final defaults = <FinanceCategoryModel>[
      // Income
      FinanceCategoryModel(
        id: 'inc_salary',
        name: 'Lương tháng',
        type: TransactionType.income,
        icon: 'work',
        isDefault: true,
      ),
      FinanceCategoryModel(
        id: 'inc_bonus',
        name: 'Thưởng',
        type: TransactionType.income,
        icon: 'card_giftcard',
        isDefault: true,
      ),
      FinanceCategoryModel(
        id: 'inc_freelance',
        name: 'Freelance',
        type: TransactionType.income,
        icon: 'laptop',
        isDefault: true,
      ),
      FinanceCategoryModel(
        id: 'inc_invest',
        name: 'Đầu tư',
        type: TransactionType.income,
        icon: 'trending_up',
        isDefault: true,
      ),
      FinanceCategoryModel(
        id: 'inc_other',
        name: 'Khác',
        type: TransactionType.income,
        icon: 'more_horiz',
        isDefault: true,
      ),
      // Expense
      FinanceCategoryModel(
        id: 'exp_food',
        name: 'Ăn uống',
        type: TransactionType.expense,
        icon: 'restaurant',
        isDefault: true,
      ),
      FinanceCategoryModel(
        id: 'exp_transport',
        name: 'Di chuyển',
        type: TransactionType.expense,
        icon: 'directions_car',
        isDefault: true,
      ),
      FinanceCategoryModel(
        id: 'exp_home',
        name: 'Nhà cửa',
        type: TransactionType.expense,
        icon: 'home',
        isDefault: true,
      ),
      FinanceCategoryModel(
        id: 'exp_shopping',
        name: 'Mua sắm',
        type: TransactionType.expense,
        icon: 'shopping_bag',
        isDefault: true,
      ),
      FinanceCategoryModel(
        id: 'exp_health',
        name: 'Sức khỏe',
        type: TransactionType.expense,
        icon: 'favorite',
        isDefault: true,
      ),
      FinanceCategoryModel(
        id: 'exp_entertainment',
        name: 'Giải trí',
        type: TransactionType.expense,
        icon: 'movie',
        isDefault: true,
      ),
      FinanceCategoryModel(
        id: 'exp_education',
        name: 'Học tập',
        type: TransactionType.expense,
        icon: 'school',
        isDefault: true,
      ),
      FinanceCategoryModel(
        id: 'exp_other',
        name: 'Khác',
        type: TransactionType.expense,
        icon: 'more_horiz',
        isDefault: true,
      ),
    ];

    await localDataSource.insertCategories(defaults);
  }

  @override
  Future<Map<TransactionType, List<String>>> getDistinctTitlesByType() {
    return localDataSource.getDistinctTitlesByType();
  }
}
