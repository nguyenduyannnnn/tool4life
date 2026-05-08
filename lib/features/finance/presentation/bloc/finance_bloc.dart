import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/finance_repository.dart';
import '../../domain/usecases/create_transaction.dart';
import '../../domain/usecases/delete_transaction.dart';
import '../../domain/usecases/get_finance_categories.dart';
import '../../domain/usecases/get_monthly_finance_summary.dart';
import '../../domain/usecases/get_transactions_by_month.dart';
import '../../domain/usecases/update_transaction.dart';
import 'finance_event.dart';
import 'finance_state.dart';

class FinanceBloc extends Bloc<FinanceEvent, FinanceState> {
  final GetTransactionsByMonth getTransactionsByMonth;
  final GetFinanceCategories getFinanceCategories;
  final GetMonthlyFinanceSummary getMonthlyFinanceSummary;
  final CreateTransaction createTransaction;
  final UpdateTransaction updateTransaction;
  final DeleteTransaction deleteTransaction;
  final FinanceRepository repository;

  FinanceBloc({
    required this.getTransactionsByMonth,
    required this.getFinanceCategories,
    required this.getMonthlyFinanceSummary,
    required this.createTransaction,
    required this.updateTransaction,
    required this.deleteTransaction,
    required this.repository,
  }) : super(FinanceState.initial()) {
    on<LoadFinanceByMonth>(_onLoad);
    on<ChangeSelectedMonth>(_onChangeMonth);
    on<CreateTransactionEvent>(_onCreate);
    on<UpdateTransactionEvent>(_onUpdate);
    on<DeleteTransactionEvent>(_onDelete);
    on<ChangeTransactionFilter>(_onChangeFilter);
    on<LoadFinanceCategories>(_onLoadCategories);
    on<SeedDefaultFinanceCategories>(_onSeed);
  }

  Future<void> _onLoad(
      LoadFinanceByMonth event, Emitter<FinanceState> emit) async {
    emit(state.copyWith(status: FinanceStatus.loading, clearError: true));
    try {
      final normalized = _normalize(event.month);
      final txs = await getTransactionsByMonth(normalized);
      final summary = await getMonthlyFinanceSummary(normalized);
      emit(state.copyWith(
        selectedMonth: normalized,
        transactions: txs,
        summary: summary,
        status: FinanceStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: FinanceStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onChangeMonth(
      ChangeSelectedMonth event, Emitter<FinanceState> emit) async {
    add(LoadFinanceByMonth(event.month));
  }

  Future<void> _onCreate(
      CreateTransactionEvent event, Emitter<FinanceState> emit) async {
    try {
      await createTransaction(event.transaction);
      await _reload(emit);
    } catch (e) {
      emit(state.copyWith(
        status: FinanceStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdate(
      UpdateTransactionEvent event, Emitter<FinanceState> emit) async {
    try {
      await updateTransaction(event.transaction);
      await _reload(emit);
    } catch (e) {
      emit(state.copyWith(
        status: FinanceStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDelete(
      DeleteTransactionEvent event, Emitter<FinanceState> emit) async {
    try {
      await deleteTransaction(event.id);
      await _reload(emit);
    } catch (e) {
      emit(state.copyWith(
        status: FinanceStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onChangeFilter(
      ChangeTransactionFilter event, Emitter<FinanceState> emit) {
    emit(state.copyWith(filter: event.filter));
  }

  Future<void> _onLoadCategories(
      LoadFinanceCategories event, Emitter<FinanceState> emit) async {
    try {
      final cats = await getFinanceCategories();
      emit(state.copyWith(categories: cats));
    } catch (e) {
      emit(state.copyWith(
        status: FinanceStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onSeed(
      SeedDefaultFinanceCategories event, Emitter<FinanceState> emit) async {
    try {
      await repository.seedDefaultCategories();
      add(const LoadFinanceCategories());
    } catch (e) {
      emit(state.copyWith(
        status: FinanceStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _reload(Emitter<FinanceState> emit) async {
    final txs = await getTransactionsByMonth(state.selectedMonth);
    final summary = await getMonthlyFinanceSummary(state.selectedMonth);
    emit(state.copyWith(
      transactions: txs,
      summary: summary,
      status: FinanceStatus.success,
      clearError: true,
    ));
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, 1);
}
