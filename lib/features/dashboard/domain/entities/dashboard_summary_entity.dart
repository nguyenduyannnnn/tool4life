import 'package:equatable/equatable.dart';

import '../../../finance/domain/entities/finance_category_entity.dart';
import '../../../finance/domain/entities/transaction_entity.dart';
import '../../../places/domain/entities/place_entity.dart';
import '../../../todo/domain/entities/todo_entity.dart';

class DashboardSummaryEntity extends Equatable {
  final List<TodoEntity> todayTodos;
  final int totalTodos;
  final int completedTodos;
  final double todoProgress;

  final double totalIncome;
  final double totalExpense;
  final double balance;
  final List<TransactionEntity> recentTransactions;
  final List<FinanceCategoryEntity> financeCategories;

  final PlaceEntity? featuredPlace;
  final String? featuredImagePath;

  final DateTime generatedAt;

  const DashboardSummaryEntity({
    required this.todayTodos,
    required this.totalTodos,
    required this.completedTodos,
    required this.todoProgress,
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    this.recentTransactions = const [],
    this.financeCategories = const [],
    this.featuredPlace,
    this.featuredImagePath,
    required this.generatedAt,
  });

  factory DashboardSummaryEntity.empty() => DashboardSummaryEntity(
        todayTodos: const [],
        totalTodos: 0,
        completedTodos: 0,
        todoProgress: 0,
        totalIncome: 0,
        totalExpense: 0,
        balance: 0,
        generatedAt: DateTime.fromMillisecondsSinceEpoch(0),
      );

  bool get hasFinanceData => totalIncome != 0 || totalExpense != 0;

  @override
  List<Object?> get props => [
        todayTodos,
        totalTodos,
        completedTodos,
        todoProgress,
        totalIncome,
        totalExpense,
        balance,
        recentTransactions,
        financeCategories,
        featuredPlace,
        featuredImagePath,
        generatedAt,
      ];
}
