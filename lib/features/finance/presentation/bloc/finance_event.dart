import 'package:equatable/equatable.dart';

import '../../domain/entities/transaction_entity.dart';

abstract class FinanceEvent extends Equatable {
  const FinanceEvent();

  @override
  List<Object?> get props => [];
}

class LoadFinanceByMonth extends FinanceEvent {
  final DateTime month;

  const LoadFinanceByMonth(this.month);

  @override
  List<Object?> get props => [month];
}

class ChangeSelectedMonth extends FinanceEvent {
  final DateTime month;

  const ChangeSelectedMonth(this.month);

  @override
  List<Object?> get props => [month];
}

class CreateTransactionEvent extends FinanceEvent {
  final TransactionEntity transaction;

  const CreateTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class UpdateTransactionEvent extends FinanceEvent {
  final TransactionEntity transaction;

  const UpdateTransactionEvent(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class DeleteTransactionEvent extends FinanceEvent {
  final String id;

  const DeleteTransactionEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ChangeTransactionFilter extends FinanceEvent {
  final TransactionFilter filter;

  const ChangeTransactionFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

class LoadFinanceCategories extends FinanceEvent {
  const LoadFinanceCategories();
}

class SeedDefaultFinanceCategories extends FinanceEvent {
  const SeedDefaultFinanceCategories();
}

class LoadTwelveMonthTotals extends FinanceEvent {
  const LoadTwelveMonthTotals();
}
