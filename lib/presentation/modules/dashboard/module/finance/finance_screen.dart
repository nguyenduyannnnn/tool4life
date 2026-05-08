import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:changmeeting/features/finance/data/datasources/finance_local_datasource.dart';
import 'package:changmeeting/features/finance/data/repositories/finance_repository_impl.dart';
import 'package:changmeeting/features/finance/domain/repositories/finance_repository.dart';
import 'package:changmeeting/features/finance/domain/usecases/create_transaction.dart';
import 'package:changmeeting/features/finance/domain/usecases/delete_transaction.dart';
import 'package:changmeeting/features/finance/domain/usecases/get_finance_categories.dart';
import 'package:changmeeting/features/finance/domain/usecases/get_monthly_finance_summary.dart';
import 'package:changmeeting/features/finance/domain/usecases/get_transactions_by_month.dart';
import 'package:changmeeting/features/finance/domain/usecases/update_transaction.dart';
import 'package:changmeeting/features/finance/presentation/bloc/finance_bloc.dart';
import 'package:changmeeting/features/finance/presentation/pages/finance_page.dart';
import 'package:changmeeting/features/todo/data/datasources/local_database_service.dart';

class FinanceScreen extends StatelessWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<FinanceBloc>(
      create: (_) {
        final db = LocalDatabaseService.instance.db;
        final FinanceRepository repository = FinanceRepositoryImpl(
          FinanceLocalDataSourceImpl(db),
        );
        return FinanceBloc(
          getTransactionsByMonth: GetTransactionsByMonth(repository),
          getFinanceCategories: GetFinanceCategories(repository),
          getMonthlyFinanceSummary: GetMonthlyFinanceSummary(repository),
          createTransaction: CreateTransaction(repository),
          updateTransaction: UpdateTransaction(repository),
          deleteTransaction: DeleteTransaction(repository),
          repository: repository,
        );
      },
      child: const FinancePage(),
    );
  }
}
