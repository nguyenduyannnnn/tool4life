import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:changmeeting/common/design_system/ds.dart';
import '../bloc/dashboard_bloc.dart';
import '../bloc/dashboard_event.dart';
import '../bloc/dashboard_state.dart';
import '../widgets/dashboard_featured_place_card.dart';
import '../widgets/dashboard_finance_card.dart';
import '../widgets/dashboard_header.dart';
import '../widgets/dashboard_todo_card.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  @override
  void initState() {
    super.initState();
    context.read<DashboardBloc>().add(const LoadDashboard());
  }

  Future<void> _refresh() async {
    final DashboardBloc bloc = context.read<DashboardBloc>();
    bloc.add(const RefreshDashboard());
    await bloc.stream.firstWhere(
      (s) => s.status != DashboardStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return DSScaffold(
      safeAreaTop: false,
      body: BlocConsumer<DashboardBloc, DashboardState>(
        listenWhen: (prev, curr) =>
            prev.errorMessage != curr.errorMessage &&
            curr.status == DashboardStatus.failure,
        listener: (context, state) {
          if (state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.errorMessage!)),
            );
          }
        },
        builder: (context, state) {
          final bool showInitialLoader =
              state.status == DashboardStatus.loading && !state.hasInitialData;

          final List<Widget> items = <Widget>[
            DashboardHeader(
              totalIncome: state.summary.totalIncome,
              totalExpense: state.summary.totalExpense,
              balance: state.summary.balance,
            ).animate().fadeIn(
                  duration: 400.ms,
                  curve: Curves.easeOutCubic,
                ),
          ];

          if (showInitialLoader) {
            items.add(
              const Padding(
                padding: EdgeInsets.symmetric(vertical: DSSpacing.huge),
                child: Center(child: CircularProgressIndicator()),
              ),
            );
          } else {
            items.addAll(<Widget>[
              DashboardTodoCard(
                visibleTodos: state.visibleTodos,
                totalTodos: state.summary.totalTodos,
                completedTodos: state.summary.completedTodos,
                isExpanded: state.isTodoExpanded,
                onToggleExpand: () => context
                    .read<DashboardBloc>()
                    .add(const ToggleTodoExpand()),
                onOpenTodoTab: () =>
                    context.read<DashboardBloc>().add(const OpenTodoTab()),
              )
                  .animate(delay: 100.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
              DashboardFinanceCard(
                totalIncome: state.summary.totalIncome,
                totalExpense: state.summary.totalExpense,
                balance: state.summary.balance,
                recentTransactions: state.summary.recentTransactions,
                categories: state.summary.financeCategories,
                onQuickAdd: () => context
                    .read<DashboardBloc>()
                    .add(const OpenFinanceQuickCreate()),
                onOpenFinanceTab: () =>
                    context.read<DashboardBloc>().add(const OpenFinanceTab()),
              )
                  .animate(delay: 170.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
              DashboardFeaturedPlaceCard(
                featuredPlace: state.summary.featuredPlace,
                imagePath: state.summary.featuredImagePath,
                onOpenPlace: () {
                  final featured = state.summary.featuredPlace;
                  if (featured != null) {
                    context
                        .read<DashboardBloc>()
                        .add(OpenPlaceDetail(featured));
                  } else {
                    context
                        .read<DashboardBloc>()
                        .add(const OpenPlacesTab());
                  }
                },
              )
                  .animate(delay: 240.ms)
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: 0.1, end: 0, curve: Curves.easeOutCubic),
            ]);
          }

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: DSSpacing.xxl),
              children: items,
            ),
          );
        },
      ),
    );
  }
}
