import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:changmeeting/common/theme.dart';
import 'package:changmeeting/features/dashboard/presentation/bloc/main_navigation_cubit.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../bloc/finance_state.dart';
import '../widgets/category_chart.dart';
import '../widgets/finance_summary_card.dart';
import '../widgets/month_selector.dart';
import '../widgets/transaction_filter_chips.dart';
import '../widgets/transaction_item.dart';
import 'transaction_form_bottom_sheet.dart';

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage> {
  bool _autoOpenedFromDashboard = false;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<FinanceBloc>();
    final now = DateTime.now();
    bloc.add(const SeedDefaultFinanceCategories());
    bloc.add(LoadFinanceByMonth(DateTime(now.year, now.month, 1)));
  }

  void _maybeAutoOpenCreate(FinanceState financeState) {
    if (_autoOpenedFromDashboard) return;
    if (financeState.categories.isEmpty) return;
    final nav = context.read<MainNavigationCubit>();
    if (!nav.state.pendingFinanceCreate) return;
    _autoOpenedFromDashboard = true;
    nav.consumeFinanceCreate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openForm();
    });
  }

  Future<void> _openForm({TransactionEntity? initial}) async {
    final state = context.read<FinanceBloc>().state;
    if (state.categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang khởi tạo danh mục, vui lòng đợi')),
      );
      return;
    }
    final result = await TransactionFormBottomSheet.show(
      context,
      initial: initial,
      defaultDate: state.selectedMonth,
      categories: state.categories,
    );
    if (!mounted || result == null) return;
    if (initial == null) {
      context.read<FinanceBloc>().add(CreateTransactionEvent(result));
    } else {
      context.read<FinanceBloc>().add(UpdateTransactionEvent(result));
    }
  }

  Future<void> _confirmDelete(String id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Xóa giao dịch?'),
        content: const Text('Bạn chắc chắn muốn xóa giao dịch này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (ok == true) {
      context.read<FinanceBloc>().add(DeleteTransactionEvent(id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Thu chi',
          style: TextStyle(
            color: AppColors.accent,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: BlocConsumer<FinanceBloc, FinanceState>(
        listener: (context, state) {
          if (state.status == FinanceStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
          _maybeAutoOpenCreate(state);
        },
        builder: (context, state) {
          return Column(
            children: [
              MonthSelector(
                selectedMonth: state.selectedMonth,
                onMonthChanged: (m) =>
                    context.read<FinanceBloc>().add(ChangeSelectedMonth(m)),
              ),
              FinanceSummaryCard(
                totalIncome: state.summary.totalIncome,
                totalExpense: state.summary.totalExpense,
                balance: state.summary.balance,
              ),
              TransactionFilterChips(
                selected: state.filter,
                onChanged: (f) =>
                    context.read<FinanceBloc>().add(ChangeTransactionFilter(f)),
              ),
              const SizedBox(height: 8),
              Expanded(child: _buildBody(state)),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildBody(FinanceState state) {
    if (state.status == FinanceStatus.loading && state.transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final items = state.filteredTransactions;
    if (items.isEmpty && state.transactions.isEmpty) {
      return _emptyState();
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        if (state.summary.expenseByCategory.isNotEmpty)
          CategoryChart(
            title: 'Chi phí theo danh mục',
            dataByCategoryId: state.summary.expenseByCategory,
            categories: state.categories,
          ),
        ...items.map((tx) => TransactionItem(
              transaction: tx,
              category: state.findCategoryById(tx.categoryId),
              onEdit: () => _openForm(initial: tx),
              onDelete: () => _confirmDelete(tx.id),
            )),
        if (items.isEmpty)
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                'Không có giao dịch khớp với bộ lọc',
                style: TextStyle(color: AppColors.grey),
              ),
            ),
          ),
      ],
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.account_balance_wallet_outlined,
              size: 64, color: AppColors.hint),
          const SizedBox(height: 12),
          Text(
            'Chưa có giao dịch nào trong tháng này',
            style: TextStyle(color: AppColors.grey, fontSize: 14),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _openForm(),
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Thêm giao dịch',
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
