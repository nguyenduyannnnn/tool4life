import 'package:equatable/equatable.dart';

enum TodoPriority {
  low,
  medium,
  high;

  String get label {
    switch (this) {
      case TodoPriority.low:
        return 'Thấp';
      case TodoPriority.medium:
        return 'Trung bình';
      case TodoPriority.high:
        return 'Cao';
    }
  }

  int get sortRank {
    switch (this) {
      case TodoPriority.high:
        return 0;
      case TodoPriority.medium:
        return 1;
      case TodoPriority.low:
        return 2;
    }
  }
}

enum TodoFilter {
  all,
  active,
  completed;

  String get label {
    switch (this) {
      case TodoFilter.all:
        return 'Tất cả';
      case TodoFilter.active:
        return 'Chưa hoàn thành';
      case TodoFilter.completed:
        return 'Đã hoàn thành';
    }
  }
}

class TodoEntity extends Equatable {
  final String id;
  final String title;
  final String? description;
  final DateTime date;
  final TodoPriority priority;
  final bool isCompleted;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TodoEntity({
    required this.id,
    required this.title,
    this.description,
    required this.date,
    required this.priority,
    required this.isCompleted,
    required this.createdAt,
    required this.updatedAt,
  });

  TodoEntity copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? date,
    TodoPriority? priority,
    bool? isCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TodoEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      priority: priority ?? this.priority,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        date,
        priority,
        isCompleted,
        createdAt,
        updatedAt,
      ];
}
