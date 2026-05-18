import 'package:equatable/equatable.dart';

import '../../domain/entities/finance_category_entity.dart';
import '../../domain/entities/finance_month_totals_entity.dart';
import '../../domain/entities/finance_summary_entity.dart';
import '../../domain/entities/transaction_entity.dart';

enum FinanceStatus { initial, loading, success, failure }

class FinanceState extends Equatable {
  final DateTime selectedMonth;
  final List<TransactionEntity> transactions;
  final List<FinanceCategoryEntity> categories;
  final FinanceSummaryEntity summary;
  final TransactionFilter filter;
  final FinanceStatus status;
  final String? errorMessage;
  final List<FinanceMonthTotalsEntity> twelveMonthTotals;
  final bool twelveMonthLoading;

  const FinanceState({
    required this.selectedMonth,
    this.transactions = const [],
    this.categories = const [],
    required this.summary,
    this.filter = TransactionFilter.all,
    this.status = FinanceStatus.initial,
    this.errorMessage,
    this.twelveMonthTotals = const [],
    this.twelveMonthLoading = false,
  });

  factory FinanceState.initial() {
    final now = DateTime.now();
    return FinanceState(
      selectedMonth: DateTime(now.year, now.month, 1),
      summary: FinanceSummaryEntity.empty(),
    );
  }

  FinanceState copyWith({
    DateTime? selectedMonth,
    List<TransactionEntity>? transactions,
    List<FinanceCategoryEntity>? categories,
    FinanceSummaryEntity? summary,
    TransactionFilter? filter,
    FinanceStatus? status,
    String? errorMessage,
    bool clearError = false,
    List<FinanceMonthTotalsEntity>? twelveMonthTotals,
    bool? twelveMonthLoading,
  }) {
    return FinanceState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
      transactions: transactions ?? this.transactions,
      categories: categories ?? this.categories,
      summary: summary ?? this.summary,
      filter: filter ?? this.filter,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      twelveMonthTotals: twelveMonthTotals ?? this.twelveMonthTotals,
      twelveMonthLoading: twelveMonthLoading ?? this.twelveMonthLoading,
    );
  }

  List<TransactionEntity> get filteredTransactions {
    final list = transactions.where((t) {
      switch (filter) {
        case TransactionFilter.all:
          return true;
        case TransactionFilter.income:
          return t.type == TransactionType.income;
        case TransactionFilter.expense:
          return t.type == TransactionType.expense;
      }
    }).toList();

    list.sort((a, b) {
      final byDate = b.date.compareTo(a.date);
      if (byDate != 0) return byDate;
      return b.createdAt.compareTo(a.createdAt);
    });

    return list;
  }

  FinanceCategoryEntity? findCategoryById(String id) {
    for (final c in categories) {
      if (c.id == id) return c;
    }
    return null;
  }

  @override
  List<Object?> get props => [
        selectedMonth,
        transactions,
        categories,
        summary,
        filter,
        status,
        errorMessage,
        twelveMonthTotals,
        twelveMonthLoading,
      ];
}
