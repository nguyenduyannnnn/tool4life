import 'package:equatable/equatable.dart';

import '../../domain/entities/todo_entity.dart';
import 'todo_state.dart';

abstract class TodoEvent extends Equatable {
  const TodoEvent();

  @override
  List<Object?> get props => [];
}

class LoadTodosByDate extends TodoEvent {
  final DateTime date;

  const LoadTodosByDate(this.date);

  @override
  List<Object?> get props => [date];
}

class ChangeSelectedDate extends TodoEvent {
  final DateTime date;

  const ChangeSelectedDate(this.date);

  @override
  List<Object?> get props => [date];
}

class CreateTodoEvent extends TodoEvent {
  final TodoEntity todo;

  const CreateTodoEvent(this.todo);

  @override
  List<Object?> get props => [todo];
}

class UpdateTodoEvent extends TodoEvent {
  final TodoEntity todo;

  const UpdateTodoEvent(this.todo);

  @override
  List<Object?> get props => [todo];
}

class DeleteTodoEvent extends TodoEvent {
  final String id;

  const DeleteTodoEvent(this.id);

  @override
  List<Object?> get props => [id];
}

class ToggleTodoStatusEvent extends TodoEvent {
  final String id;
  final bool isCompleted;

  const ToggleTodoStatusEvent(this.id, this.isCompleted);

  @override
  List<Object?> get props => [id, isCompleted];
}

class ChangeTodoFilter extends TodoEvent {
  final TodoFilter filter;

  const ChangeTodoFilter(this.filter);

  @override
  List<Object?> get props => [filter];
}

class ChangeViewMode extends TodoEvent {
  final TodoViewMode mode;

  const ChangeViewMode(this.mode);

  @override
  List<Object?> get props => [mode];
}

class ChangeMonthAnchor extends TodoEvent {
  final DateTime month;

  const ChangeMonthAnchor(this.month);

  @override
  List<Object?> get props => [month];
}

class LoadTodosByMonth extends TodoEvent {
  final DateTime month;

  const LoadTodosByMonth(this.month);

  @override
  List<Object?> get props => [month];
}
