import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:changmeeting/common/design_system/ds.dart';
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
  final Map<String, bool> _expandedOverride = <String, bool>{};
  late final TabController _tabController =
      TabController(length: 2, vsync: this);

  bool _calendarMode = false;
  _CalendarViewMode _calendarView = _CalendarViewMode.day;
  final Map<String, GlobalKey> _dayGroupKeys = <String, GlobalKey>{};
  String? _highlightDayKey;
  Timer? _highlightTimer;

  String _dayKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  bool _isDayExpanded(DateTime day) {
    final String key = _dayKey(day);
    final bool? override = _expandedOverride[key];
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
    final FinanceBloc bloc = context.read<FinanceBloc>();
    final DateTime now = DateTime.now();
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
    final String key = _dayKey(day);
    setState(() {
      _calendarMode = false;
      _expandedOverride[key] = true;
      _highlightDayKey = key;
    });
    _tabController.animateTo(0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final BuildContext? ctx = _dayGroupKeys[key]?.currentContext;
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
    final MainNavigationCubit nav = context.read<MainNavigationCubit>();
    if (!nav.state.pendingFinanceCreate) return;
    _autoOpenedFromDashboard = true;
    nav.consumeFinanceCreate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _openForm();
    });
  }

  Future<void> _openForm({TransactionEntity? initial}) async {
    final FinanceBloc bloc = context.read<FinanceBloc>();
    final FinanceState state = bloc.state;
    if (state.categories.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đang khởi tạo danh mục, vui lòng đợi')),
      );
      return;
    }
    Map<TransactionType, Map<String, String>> titlesByType =
        const <TransactionType, Map<String, String>>{};
    try {
      titlesByType = await bloc.repository.getDistinctTitlesByType();
    } catch (_) {}
    if (!mounted) return;
    final TransactionEntity? result = await TransactionFormBottomSheet.show(
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
    final colors = context.dsColors;
    final bool? ok = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Xóa giao dịch?'),
        content: const Text('Bạn chắc chắn muốn xóa giao dịch này?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Xóa', style: TextStyle(color: colors.danger)),
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
    final tokens = context.tokens;
    return DSScaffold(
      appBar: AppBar(
        backgroundColor: DSPalette.neutral0,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const DSText.h2('Thu chi'),
        centerTitle: true,
        actions: <Widget>[
          Padding(
            padding: const EdgeInsets.only(right: DSSpacing.md),
            child: DSIconButton(
              icon: _calendarMode
                  ? Icons.list_alt_outlined
                  : Icons.calendar_today_outlined,
              variant: DSIconButtonVariant.soft,
              size: DSIconButtonSize.sm,
              onTap: _toggleCalendar,
            ),
          ),
        ],
      ),
      body: BlocConsumer<FinanceBloc, FinanceState>(
        listener: (BuildContext context, FinanceState state) {
          if (state.status == FinanceStatus.failure &&
              state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
          _maybeAutoOpenCreate(state);
        },
        builder: (BuildContext context, FinanceState state) {
          if (_calendarMode) {
            return Column(
              children: <Widget>[
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
            children: <Widget>[
              MonthSelector(
                selectedMonth: state.selectedMonth,
                onMonthChanged: (DateTime m) =>
                    context.read<FinanceBloc>().add(ChangeSelectedMonth(m)),
              ),
              FinanceSummaryCard(
                totalIncome: state.summary.totalIncome,
                totalExpense: state.summary.totalExpense,
                balance: state.summary.balance,
              )
                  .animate()
                  .fadeIn(duration: 400.ms, delay: 80.ms)
                  .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
              Container(
                margin: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.lg, vertical: DSSpacing.sm),
                decoration: BoxDecoration(
                  color: tokens.colors.surfaceVariant,
                  borderRadius: DSRadius.brPill,
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: tokens.colors.textOnBrand,
                  unselectedLabelColor: tokens.colors.textSecondary,
                  indicator: BoxDecoration(
                    gradient: tokens.brandHeroGradient,
                    borderRadius: DSRadius.brPill,
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: DSTypography.bodyBold,
                  unselectedLabelStyle: DSTypography.body,
                  tabs: const <Widget>[
                    Tab(text: 'Giao dịch', height: 40),
                    Tab(text: 'Biểu đồ', height: 40),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: <Widget>[
                    _buildTransactionsTab(state),
                    _buildChartsTab(state),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: _GradientFab(
        icon: Icons.add,
        onTap: () => _openForm(),
      ),
    );
  }

  Widget _buildCalendarBody(FinanceState state) {
    if (_calendarView == _CalendarViewMode.day) {
      final Map<DateTime, FinanceDayTotals> dayTotals =
          <DateTime, FinanceDayTotals>{};
      final Map<DateTime, double> incomeByDay = <DateTime, double>{};
      final Map<DateTime, double> expenseByDay = <DateTime, double>{};
      for (final TransactionEntity tx in state.filteredTransactions) {
        final DateTime d = DateTime(tx.date.year, tx.date.month, tx.date.day);
        if (tx.type == TransactionType.income) {
          incomeByDay[d] = (incomeByDay[d] ?? 0) + tx.amount;
        } else {
          expenseByDay[d] = (expenseByDay[d] ?? 0) + tx.amount;
        }
      }
      final Set<DateTime> allDays = <DateTime>{
        ...incomeByDay.keys,
        ...expenseByDay.keys
      };
      for (final DateTime d in allDays) {
        dayTotals[d] = FinanceDayTotals(
          incomeByDay[d] ?? 0,
          expenseByDay[d] ?? 0,
        );
      }
      return FinanceMonthCalendar(
        monthAnchor: state.selectedMonth,
        dayTotals: dayTotals,
        onMonthChanged: (DateTime m) =>
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
    final List<TransactionEntity> items = state.filteredTransactions;
    final Map<DateTime, List<TransactionEntity>> groups =
        <DateTime, List<TransactionEntity>>{};
    for (final TransactionEntity tx in items) {
      final DateTime day = DateTime(tx.date.year, tx.date.month, tx.date.day);
      groups.putIfAbsent(day, () => <TransactionEntity>[]).add(tx);
    }
    final List<DateTime> sortedDays = groups.keys.toList()
      ..sort((DateTime a, DateTime b) => b.compareTo(a));

    return ListView(
      padding: const EdgeInsets.only(top: DSSpacing.xs, bottom: 100),
      children: <Widget>[
        for (int i = 0; i < sortedDays.length; i++)
          _buildDayGroup(state, sortedDays[i], groups[sortedDays[i]]!)
              .animate(delay: (i * 50).ms)
              .fadeIn(duration: 350.ms)
              .slideY(begin: 0.08, end: 0, curve: Curves.easeOutCubic),
      ],
    );
  }

  Widget _buildChartsTab(FinanceState state) {
    if (state.status == FinanceStatus.loading && state.transactions.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    final colors = context.dsColors;
    final bool hasIncomeExpense =
        state.summary.totalIncome > 0 || state.summary.totalExpense > 0;
    final bool hasCategoryData = state.summary.expenseByCategory.isNotEmpty;
    if (!hasIncomeExpense && !hasCategoryData) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(Icons.pie_chart_outline,
                size: 64, color: colors.textTertiary),
            const SizedBox(height: DSSpacing.md),
            DSText.body('Chưa có dữ liệu để hiển thị biểu đồ',
                color: colors.textSecondary),
          ],
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.only(top: DSSpacing.xs, bottom: 100),
      children: <Widget>[
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
    final colors = context.dsColors;
    final bool expanded = _isDayExpanded(day);
    final String label = DateFormat('dd/MM/yyyy').format(day);
    double dayIncome = 0;
    double dayExpense = 0;
    for (final TransactionEntity tx in txs) {
      if (tx.type == TransactionType.income) {
        dayIncome += tx.amount;
      } else {
        dayExpense += tx.amount;
      }
    }

    final String key = _dayKey(day);
    final bool highlight = _highlightDayKey == key;
    final GlobalKey groupKey =
        _dayGroupKeys.putIfAbsent(key, () => GlobalKey());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          key: groupKey,
          margin: const EdgeInsets.fromLTRB(
              DSSpacing.lg, DSSpacing.sm, DSSpacing.lg, DSSpacing.xs),
          decoration: BoxDecoration(
            color: highlight ? colors.accentMuted : colors.surface,
            borderRadius: DSRadius.brLg,
            border: Border.all(
              color: highlight ? colors.accent : colors.outline,
              width: highlight ? 2 : 1,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: DSRadius.brLg,
              onTap: () => _toggleDay(day),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: DSSpacing.md, vertical: DSSpacing.md),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          DSText.bodyBold(label),
                          const SizedBox(height: DSSpacing.xs),
                          Row(
                            children: <Widget>[
                              if (dayIncome > 0)
                                _DayTotalLabel(
                                  amount: dayIncome,
                                  isIncome: true,
                                ),
                              if (dayIncome > 0 && dayExpense > 0)
                                const SizedBox(width: DSSpacing.md),
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
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: expanded ? 0.5 : 0,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 26,
                        color: colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        if (expanded)
          ...txs.map((TransactionEntity tx) => TransactionItem(
                transaction: tx,
                category: state.findCategoryById(tx.categoryId),
                onEdit: () => _openForm(initial: tx),
                onDelete: () => _confirmDelete(tx.id),
              )),
      ],
    );
  }

  Widget _emptyState() {
    final colors = context.dsColors;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.account_balance_wallet_outlined,
              size: 64, color: colors.textTertiary),
          const SizedBox(height: DSSpacing.md),
          DSText.body('Chưa có giao dịch nào trong tháng này',
              color: colors.textSecondary),
          const SizedBox(height: DSSpacing.lg),
          DSButton.primary(
            label: 'Thêm giao dịch',
            leadingIcon: Icons.add,
            onPressed: () => _openForm(),
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
    final tokens = context.tokens;
    return Container(
      color: tokens.colors.background,
      padding: const EdgeInsets.symmetric(
          horizontal: DSSpacing.lg, vertical: DSSpacing.sm),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: tokens.colors.surfaceVariant,
                borderRadius: DSRadius.brPill,
              ),
              padding: const EdgeInsets.all(DSSpacing.xs),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: _SegmentButton(
                      label: 'Ngày',
                      icon: Icons.calendar_view_month_outlined,
                      selected: viewMode == _CalendarViewMode.day,
                      onTap: () => onChanged(_CalendarViewMode.day),
                    ),
                  ),
                  Expanded(
                    child: _SegmentButton(
                      label: 'Tháng',
                      icon: Icons.grid_view_outlined,
                      selected: viewMode == _CalendarViewMode.month,
                      onTap: () => onChanged(_CalendarViewMode.month),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SegmentButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: tokens.motionFast,
        padding: const EdgeInsets.symmetric(vertical: DSSpacing.sm),
        decoration: BoxDecoration(
          gradient: selected ? tokens.brandHeroGradient : null,
          borderRadius: DSRadius.brPill,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              icon,
              size: 16,
              color: selected
                  ? tokens.colors.textOnBrand
                  : tokens.colors.textSecondary,
            ),
            const SizedBox(width: DSSpacing.xs),
            Text(
              label,
              style: DSTypography.label.copyWith(
                color: selected
                    ? tokens.colors.textOnBrand
                    : tokens.colors.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
    final colors = context.dsColors;
    final Color color = isIncome ? colors.income : colors.expense;
    final IconData icon = isIncome
        ? Icons.arrow_upward_rounded
        : Icons.arrow_downward_rounded;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 2),
        Text(
          CurrencyFormatter.format(amount),
          style: DSTypography.caption.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _GradientFab extends StatefulWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _GradientFab({required this.icon, required this.onTap});

  @override
  State<_GradientFab> createState() => _GradientFabState();
}

class _GradientFabState extends State<_GradientFab> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final tokens = context.tokens;
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        duration: tokens.motionFast,
        scale: _pressed ? 0.94 : 1.0,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            gradient: tokens.brandHeroGradient,
            shape: BoxShape.circle,
            boxShadow: tokens.brandGlow,
          ),
          alignment: Alignment.center,
          child: Icon(widget.icon, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
