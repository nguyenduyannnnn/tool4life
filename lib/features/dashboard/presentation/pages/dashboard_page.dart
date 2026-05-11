import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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
    final bloc = context.read<DashboardBloc>();
    bloc.add(const RefreshDashboard());
    await bloc.stream.firstWhere(
      (s) => s.status != DashboardStatus.loading,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        top: false,
        child: BlocConsumer<DashboardBloc, DashboardState>(
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
            final showInitialLoader =
                state.status == DashboardStatus.loading &&
                    !state.hasInitialData;
            return RefreshIndicator(
              onRefresh: _refresh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 24),
                children: [
                  const DashboardHeader(),
                  const SizedBox(height: 4),
                  if (showInitialLoader)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else ...[
                    DashboardTodoCard(
                      visibleTodos: state.visibleTodos,
                      totalTodos: state.summary.totalTodos,
                      completedTodos: state.summary.completedTodos,
                      isExpanded: state.isTodoExpanded,
                      onToggleExpand: () => context
                          .read<DashboardBloc>()
                          .add(const ToggleTodoExpand()),
                      onOpenTodoTab: () => context
                          .read<DashboardBloc>()
                          .add(const OpenTodoTab()),
                    ),
                    DashboardFinanceCard(
                      totalIncome: state.summary.totalIncome,
                      totalExpense: state.summary.totalExpense,
                      balance: state.summary.balance,
                      onQuickAdd: () => context
                          .read<DashboardBloc>()
                          .add(const OpenFinanceQuickCreate()),
                      onOpenFinanceTab: () => context
                          .read<DashboardBloc>()
                          .add(const OpenFinanceTab()),
                    ),
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
                    ),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
