import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_dashboard_summary.dart';
import 'dashboard_event.dart';
import 'dashboard_state.dart';
import 'main_navigation_cubit.dart';

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final GetDashboardSummary getDashboardSummary;
  final MainNavigationCubit mainNavigationCubit;

  DashboardBloc({
    required this.getDashboardSummary,
    required this.mainNavigationCubit,
  }) : super(DashboardState.initial()) {
    on<LoadDashboard>(_onLoad);
    on<RefreshDashboard>(_onRefresh);
    on<ToggleTodoExpand>(_onToggleExpand);
    on<OpenFinanceQuickCreate>(_onOpenFinanceCreate);
    on<OpenFinanceTab>(_onOpenFinanceTab);
    on<OpenTodoTab>(_onOpenTodoTab);
    on<OpenPlacesTab>(_onOpenPlacesTab);
    on<OpenPlaceDetail>(_onOpenPlaceDetail);
  }

  Future<void> _onLoad(
      LoadDashboard event, Emitter<DashboardState> emit) async {
    emit(state.copyWith(status: DashboardStatus.loading, clearError: true));
    try {
      final summary = await getDashboardSummary();
      emit(state.copyWith(
        status: DashboardStatus.success,
        summary: summary,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onRefresh(
      RefreshDashboard event, Emitter<DashboardState> emit) async {
    try {
      final summary = await getDashboardSummary();
      emit(state.copyWith(
        status: DashboardStatus.success,
        summary: summary,
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: DashboardStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onToggleExpand(
      ToggleTodoExpand event, Emitter<DashboardState> emit) {
    emit(state.copyWith(isTodoExpanded: !state.isTodoExpanded));
  }

  void _onOpenFinanceCreate(
      OpenFinanceQuickCreate event, Emitter<DashboardState> emit) {
    mainNavigationCubit.openFinanceCreateForm();
  }

  void _onOpenFinanceTab(
      OpenFinanceTab event, Emitter<DashboardState> emit) {
    mainNavigationCubit.openFinanceTab();
  }

  void _onOpenTodoTab(OpenTodoTab event, Emitter<DashboardState> emit) {
    mainNavigationCubit.openTodoTab();
  }

  void _onOpenPlacesTab(
      OpenPlacesTab event, Emitter<DashboardState> emit) {
    mainNavigationCubit.openPlacesTab();
  }

  void _onOpenPlaceDetail(
      OpenPlaceDetail event, Emitter<DashboardState> emit) {
    mainNavigationCubit.openPlaceDetail(event.place);
  }
}
