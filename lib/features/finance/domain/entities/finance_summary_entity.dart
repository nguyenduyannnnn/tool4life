import 'package:equatable/equatable.dart';

class FinanceSummaryEntity extends Equatable {
  final double totalIncome;
  final double totalExpense;
  final Map<String, double> incomeByCategory;
  final Map<String, double> expenseByCategory;

  const FinanceSummaryEntity({
    required this.totalIncome,
    required this.totalExpense,
    required this.incomeByCategory,
    required this.expenseByCategory,
  });

  double get balance => totalIncome - totalExpense;

  factory FinanceSummaryEntity.empty() => const FinanceSummaryEntity(
        totalIncome: 0,
        totalExpense: 0,
        incomeByCategory: {},
        expenseByCategory: {},
      );

  @override
  List<Object?> get props => [
        totalIncome,
        totalExpense,
        incomeByCategory,
        expenseByCategory,
      ];
}
