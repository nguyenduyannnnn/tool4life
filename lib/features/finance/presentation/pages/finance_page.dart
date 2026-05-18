import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:changmeeting/common/theme.dart';
import 'package:changmeeting/common/utils/currency_formatter.dart';
import 'package:changmeeting/features/dashboard/presentation/bloc/main_navigation_cubit.dart';
import '../../domain/entities/transaction_entity.dart';
import '../bloc/finance_bloc.dart';
import '../bloc/finance_event.dart';
import '../bloc/finance_state.dart';
import '../widgets/category_chart.dart';
import '../widgets/finance_month_calendar.dart';
import '../widgets/finance_summary_card.dart';
import '../widgets/finance_year_grid.dart';
import '../widgets/income_expense_chart.dart';
import '../widgets/month_selector.dart';
import '../widgets/transaction_item.dart';
import 'transaction_form_bottom_sheet.dart';

enum _CalendarViewMode { day, month }

class FinancePage extends StatefulWidget {
  const FinancePage({super.key});

  @override
  State<FinancePage> createState() => _FinancePageState();
}

class _FinancePageState extends State<FinancePage>
    with SingleTickerProviderStateMixin {
  bool _autoOpenedFromDashboard = false;
  final Map<String, bool> _expandedOverride = {};
  late final TabController _tabController =
      TabController(length: 2, vsync: this);

  bool _calendarMode = false;
  _CalendarViewMode _calendarView = _CalendarViewMode.day;
  final Map<String, GlobalKey> _dayGroupKeys = {};
  String? _highlightDayKey;
  Timer? _highlightTimer;

  String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isDayExpanded(DateTime day) {
    final key = _dayKey(day);
    final override = _expandedOverride[key];
    if (override != null) return override;
    return _isSameDay(day, DateTime.now());
  }

  void _toggleDay(DateTime day) {
    setState(() {
      _expandedOverride[_dayKey(day)] = !_isDayExpanded(day);
    });
  }

  @override
  void initState() {
    super.initState();
    final bloc = context.read<FinanceBloc>();
    final now = DateTime.now();
    bloc.add(const SeedDefaultFinanceCategories());
    bloc.add(LoadFinanceByMonth(DateTime(now.year, now.month, 1)));
  }

  @override
  void dispose() {
    _highlightTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  void _toggleCalendar() {
    setState(() {
      _calendarMode = !_calendarMode;
    });
    if (_calendarMode &&
        _calendarView == _CalendarViewMode.month &&
        context.read<FinanceBloc>().state.twelveMonthTotals.isEmpty) {
      context.read<FinanceBloc>().add(const LoadTwelveMonthTotals());
    }
  }

  void _setCalendarView(_CalendarViewMode mode) {
    setState(() {
      _calendarView = mode;
    });
    if (mode == _CalendarViewMode.month &&
        context.read<FinanceBloc>().state.twelveMonthTotals.isEmpty) {
      context.read<FinanceBloc>().add(const LoadTwelveMonthTotals());
    }
  }

  void _onCalendarDayTap(DateTime day) {
    final key = _dayKey(day);
    setState(() {
      _calendarMode = false;
      _expandedOverride[key] = true;
      _highlightDayKey = key;
    });
    _tabController.animateTo(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _dayGroupKeys[key]?.currentContext;
      if (ctx != null) {
        Scrollable.ensureVisible(
          ctx,
          duration: const Duration(milliseconds: 350),
          alignment: 0.1,
        );
      }
    });
    _highlightTimer?.cancel();
    _highlightTimer = Timer(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _highlightDayKey = null);
      }
    });
  }

  void _onCalendarMonthTap(DateTime month) {
    context.read<FinanceBloc>().add(ChangeSelectedMonth(month));
    setState(() {
      _calendarView = _CalendarViewMode.day;
    });
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
    final bloc = context.read<FinanceBloc>();
    final state = bloc.state;
    if (state.categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang khởi tạo danh mục, vui lòng đợi')),
      );
      return;
    }
    Map<TransactionType, List<String>> titlesByType = const {};
    try {
      titlesByType = await bloc.repository.getDistinctTitlesByType();
    } catch (_) {}
    if (!mounted) return;
    final result = await TransactionFormBottomSheet.show(
      context,
      initial: initial,
      defaultDate: state.selectedMonth,
      categories: state.categories,
      titlesByType: titlesByType,
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
        actions: [
          IconButton(
            icon: Icon(
              _calendarMode
                  ? Icons.list_alt_outlined
                  : Icons.calendar_today_outlined,
              color: AppColors.accent,
            ),
            tooltip: _calendarMode ? 'Danh sách' : 'Lịch',
            onPressed: _toggleCalendar,
          ),
        ],
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
          if (_calendarMode) {
            return Column(
              children: [
                _CalendarHeader(
                  viewMode: _calendarView,
                  onChanged: _setCalendarView,
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: _buildCalendarBody(state),
                  ),
                ),
              ],
            );
          }
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
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppColors.primary,
                  unselectedLabelColor: AppColors.grey,
                  indicatorColor: AppColors.primary,
                  indicatorWeight: 2.5,
                  labelStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'Giao dịch'),
                    Tab(text: 'Biểu đồ'),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildTransactionsTab(state),
                    _buildChartsTab(state),
                  ],
                ),
              ),
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

  Widget _buildCalendarBody(FinanceState state) {
    if (_calendarView == _CalendarViewMode.day) {
      final dayTotals = <DateTime, FinanceDayTotals>{};
      final incomeByDay = <DateTime, double>{};
      final expenseByDay = <DateTime, double>{};
      for (final tx in state.filteredTransactions) {
        final d = DateTime(tx.date.year, tx.date.month, tx.date.day);
        if (tx.type == TransactionType.income) {
          incomeByDay[d] = (incomeByDay[d] ?? 0) + tx.amount;
        } else {
          expenseByDay[d] = (expenseByDay[d] ?? 0) + tx.amount;
        }
      }
      final allDays = <DateTime>{...incomeByDay.keys, ...expenseByDay.keys};
      for (final d in allDays) {
        dayTotals[d] = FinanceDayTotals(
          incomeByDay[d] ?? 0,
          expenseByDay[d] ?? 0,
        );
      }
      return FinanceMonthCalendar(
        monthAnchor: state.selectedMonth,
        dayTotals: dayTotals,
        onMonthChanged: (m) =>
            context.read<FinanceBloc>().add(ChangeSelectedMonth(m)),
        onDayTapped: _onCalendarDayTap,
      );
    }
    return FinanceYearGrid(
      totals: state.twelveMonthTotals,
      loading: state.twelveMonthLoading,
      onMonthTapped: _onCalendarMonthTap,
    );
  }

  Widget _buildTransactionsTab(FinanceState state) {
    if (state.status == FinanceStatus.loading && state.transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state.transactions.isEmpty) {
      return _emptyState();
    }
    final items = state.filteredTransactions;
    final groups = <DateTime, List<TransactionEntity>>{};
    for (final tx in items) {
      final day = DateTime(tx.date.year, tx.date.month, tx.date.day);
      groups.putIfAbsent(day, () => []).add(tx);
    }
    final sortedDays = groups.keys.toList()..sort((a, b) => b.compareTo(a));

    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 80),
      children: [
        for (final day in sortedDays)
          _buildDayGroup(state, day, groups[day]!),
      ],
    );
  }

  Widget _buildChartsTab(FinanceState state) {
    if (state.status == FinanceStatus.loading && state.transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final hasIncomeExpense =
        state.summary.totalIncome > 0 || state.summary.totalExpense > 0;
    final hasCategoryData = state.summary.expenseByCategory.isNotEmpty;
    if (!hasIncomeExpense && !hasCategoryData) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.pie_chart_outline, size: 64, color: AppColors.hint),
            const SizedBox(height: 12),
            Text(
              'Chưa có dữ liệu để hiển thị biểu đồ',
              style: TextStyle(color: AppColors.grey, fontSize: 14),
            ),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.only(top: 4, bottom: 80),
      children: [
        if (hasIncomeExpense)
          IncomeExpenseChart(
            totalIncome: state.summary.totalIncome,
            totalExpense: state.summary.totalExpense,
          ),
        if (hasCategoryData)
          CategoryChart(
            title: 'Chi phí theo danh mục',
            dataByCategoryId: state.summary.expenseByCategory,
            categories: state.categories,
          ),
      ],
    );
  }

  Widget _buildDayGroup(
    FinanceState state,
    DateTime day,
    List<TransactionEntity> txs,
  ) {
    final expanded = _isDayExpanded(day);
    final label = DateFormat('dd/MM/yyyy').format(day);
    double dayIncome = 0;
    double dayExpense = 0;
    for (final tx in txs) {
      if (tx.type == TransactionType.income) {
        dayIncome += tx.amount;
      } else {
        dayExpense += tx.amount;
      }
    }

    final key = _dayKey(day);
    final highlight = _highlightDayKey == key;
    final groupKey = _dayGroupKeys.putIfAbsent(key, () => GlobalKey());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          key: groupKey,
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
          decoration: BoxDecoration(
            color: AppColors.primary
                .withValues(alpha: highlight ? 0.18 : 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primary
                  .withValues(alpha: highlight ? 1.0 : 0.18),
              width: highlight ? 2 : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => _toggleDay(day),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              if (dayIncome > 0)
                                _DayTotalLabel(
                                  amount: dayIncome,
                                  isIncome: true,
                                ),
                              if (dayIncome > 0 && dayExpense > 0)
                                const SizedBox(width: 12),
                              if (dayExpense > 0)
                                _DayTotalLabel(
                                  amount: dayExpense,
                                  isIncome: false,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      size: 26,
                      color: AppColors.grey,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (expanded)
          ...txs.map((tx) => TransactionItem(
                transaction: tx,
                category: state.findCategoryById(tx.categoryId),
                onEdit: () => _openForm(initial: tx),
                onDelete: () => _confirmDelete(tx.id),
              )),
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

class _CalendarHeader extends StatelessWidget {
  final _CalendarViewMode viewMode;
  final ValueChanged<_CalendarViewMode> onChanged;

  const _CalendarHeader({required this.viewMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: SegmentedButton<_CalendarViewMode>(
              segments: const [
                ButtonSegment(
                  value: _CalendarViewMode.day,
                  label: Text('Ngày'),
                  icon: Icon(Icons.calendar_view_month_outlined),
                ),
                ButtonSegment(
                  value: _CalendarViewMode.month,
                  label: Text('Tháng'),
                  icon: Icon(Icons.grid_view_outlined),
                ),
              ],
              selected: {viewMode},
              showSelectedIcon: false,
              onSelectionChanged: (sel) => onChanged(sel.first),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayTotalLabel extends StatelessWidget {
  final double amount;
  final bool isIncome;

  const _DayTotalLabel({required this.amount, required this.isIncome});

  @override
  Widget build(BuildContext context) {
    final color = isIncome ? const Color(0xFF43A047) : const Color(0xFFE53935);
    final icon =
        isIncome ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 2),
        Text(
          CurrencyFormatter.format(amount),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
