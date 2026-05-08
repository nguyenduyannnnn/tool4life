import 'package:equatable/equatable.dart';

import '../../domain/entities/todo_entity.dart';

enum TodoStatus { initial, loading, success, failure }

class TodoState extends Equatable {
  final DateTime selectedDate;
  final List<TodoEntity> todos;
  final TodoFilter filter;
  final TodoStatus status;
  final String? errorMessage;

  const TodoState({
    required this.selectedDate,
    this.todos = const [],
    this.filter = TodoFilter.all,
    this.status = TodoStatus.initial,
    this.errorMessage,
  });

  factory TodoState.initial() {
    final now = DateTime.now();
    return TodoState(
      selectedDate: DateTime(now.year, now.month, now.day),
    );
  }

  TodoState copyWith({
    DateTime? selectedDate,
    List<TodoEntity>? todos,
    TodoFilter? filter,
    TodoStatus? status,
    String? errorMessage,
    bool clearError = false,
  }) {
    return TodoState(
      selectedDate: selectedDate ?? this.selectedDate,
      todos: todos ?? this.todos,
      filter: filter ?? this.filter,
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

  @override
  List<Object?> get props => [
        selectedDate,
        todos,
        filter,
        status,
        errorMessage,
      ];
}
