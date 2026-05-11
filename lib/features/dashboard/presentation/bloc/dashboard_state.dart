import 'package:equatable/equatable.dart';

import '../../../todo/domain/entities/todo_entity.dart';
import '../../domain/entities/dashboard_summary_entity.dart';

enum DashboardStatus { initial, loading, success, failure }

class DashboardState extends Equatable {
  final DashboardStatus status;
  final DashboardSummaryEntity summary;
  final bool isTodoExpanded;
  final String? errorMessage;

  const DashboardState({
    this.status = DashboardStatus.initial,
    required this.summary,
    this.isTodoExpanded = false,
    this.errorMessage,
  });

  factory DashboardState.initial() =>
      DashboardState(summary: DashboardSummaryEntity.empty());

  DashboardState copyWith({
    DashboardStatus? status,
    DashboardSummaryEntity? summary,
    bool? isTodoExpanded,
    String? errorMessage,
    bool clearError = false,
  }) {
    return DashboardState(
      status: status ?? this.status,
      summary: summary ?? this.summary,
      isTodoExpanded: isTodoExpanded ?? this.isTodoExpanded,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  List<TodoEntity> get sortedTodos {
    final list = List<TodoEntity>.from(summary.todayTodos);
    list.sort((a, b) {
      if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
      final byPriority = a.priority.sortRank.compareTo(b.priority.sortRank);
      if (byPriority != 0) return byPriority;
      return b.createdAt.compareTo(a.createdAt);
    });
    return list;
  }

  List<TodoEntity> get visibleTodos {
    final sorted = sortedTodos;
    if (isTodoExpanded) return sorted;
    return sorted.take(3).toList();
  }

  bool get hasInitialData =>
      status == DashboardStatus.success || status == DashboardStatus.failure;

  @override
  List<Object?> get props => [status, summary, isTodoExpanded, errorMessage];
}
