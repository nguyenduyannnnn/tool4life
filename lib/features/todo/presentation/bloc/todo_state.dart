import 'package:equatable/equatable.dart';

import '../../domain/entities/todo_entity.dart';

enum TodoStatus { initial, loading, success, failure }

enum TodoViewMode { day, month }

class TodoState extends Equatable {
  final DateTime selectedDate;
  final DateTime monthAnchor;
  final List<TodoEntity> todos;
  final List<TodoEntity> monthTodos;
  final TodoFilter filter;
  final TodoViewMode viewMode;
  final TodoStatus status;
  final String? errorMessage;

  const TodoState({
    required this.selectedDate,
    required this.monthAnchor,
    this.todos = const [],
    this.monthTodos = const [],
    this.filter = TodoFilter.all,
    this.viewMode = TodoViewMode.day,
    this.status = TodoStatus.initial,
    this.errorMessage,
  });

  factory TodoState.initial() {
    final now = DateTime.now();
    return TodoState(
      selectedDate: DateTime(now.year, now.month, now.day),
      monthAnchor: DateTime(now.year, now.month, 1),
    );
  }

  TodoState copyWith({
    DateTime? selectedDate,
    DateTime? monthAnchor,
    List<TodoEntity>? todos,
    List<TodoEntity>? monthTodos,
    TodoFilter? filter,
    TodoViewMode? viewMode,
    TodoStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TodoState(
      selectedDate: selectedDate ?? this.selectedDate,
      monthAnchor: monthAnchor ?? this.monthAnchor,
      todos: todos ?? this.todos,
      monthTodos: monthTodos ?? this.monthTodos,
      filter: filter ?? this.filter,
      viewMode: viewMode ?? this.viewMode,
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  int get completedCount => todos.where((t) => t.isCompleted).length;

  int get totalCount => todos.length;

  double get progress => totalCount == 0 ? 0 : completedCount / totalCount;

  List<TodoEntity> get filteredTodos {
    final filtered = todos.where((t) {
      switch (filter) {
        case TodoFilter.all:
          return true;
        case TodoFilter.active:
          return !t.isCompleted;
        case TodoFilter.completed:
          return t.isCompleted;
      }
    }).toList();

    filtered.sort((a, b) {
      // Chưa hoàn thành lên trước
      if (a.isCompleted != b.isCompleted) {
        return a.isCompleted ? 1 : -1;
      }
      // Priority high > medium > low
      final byPriority = a.priority.sortRank.compareTo(b.priority.sortRank);
      if (byPriority != 0) return byPriority;
      // createdAt mới nhất trước
      return b.createdAt.compareTo(a.createdAt);
    });

    return filtered;
  }

  Map<DateTime, TodoDayCount> get monthCounts {
    final map = <DateTime, TodoDayCount>{};
    for (final t in monthTodos) {
      final key = DateTime(t.date.year, t.date.month, t.date.day);
      final current = map[key] ?? const TodoDayCount(0, 0);
      map[key] = TodoDayCount(
        current.completed + (t.isCompleted ? 1 : 0),
        current.pending + (t.isCompleted ? 0 : 1),
      );
    }
    return map;
  }

  @override
  List<Object?> get props => [
        selectedDate,
        monthAnchor,
        todos,
        monthTodos,
        filter,
        viewMode,
        status,
        errorMessage,
      ];
}

class TodoDayCount {
  final int completed;
  final int pending;

  const TodoDayCount(this.completed, this.pending);

  int get total => completed + pending;
}
