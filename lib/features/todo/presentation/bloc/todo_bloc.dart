import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/create_todo.dart';
import '../../domain/usecases/delete_todo.dart';
import '../../domain/usecases/get_todos_by_date.dart';
import '../../domain/usecases/toggle_todo_status.dart';
import '../../domain/usecases/update_todo.dart';
import 'todo_event.dart';
import 'todo_state.dart';

class TodoBloc extends Bloc<TodoEvent, TodoState> {
  final GetTodosByDate getTodosByDate;
  final CreateTodo createTodo;
  final UpdateTodo updateTodo;
  final DeleteTodo deleteTodo;
  final ToggleTodoStatus toggleTodoStatus;

  TodoBloc({
    required this.getTodosByDate,
    required this.createTodo,
    required this.updateTodo,
    required this.deleteTodo,
    required this.toggleTodoStatus,
  }) : super(TodoState.initial()) {
    on<LoadTodosByDate>(_onLoad);
    on<ChangeSelectedDate>(_onChangeDate);
    on<CreateTodoEvent>(_onCreate);
    on<UpdateTodoEvent>(_onUpdate);
    on<DeleteTodoEvent>(_onDelete);
    on<ToggleTodoStatusEvent>(_onToggle);
    on<ChangeTodoFilter>(_onChangeFilter);
  }

  Future<void> _onLoad(LoadTodosByDate event, Emitter<TodoState> emit) async {
    emit(state.copyWith(status: TodoStatus.loading, clearError: true));
    try {
      final todos = await getTodosByDate(event.date);
      emit(state.copyWith(
        selectedDate: _normalize(event.date),
        todos: todos,
        status: TodoStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: TodoStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onChangeDate(
      ChangeSelectedDate event, Emitter<TodoState> emit) async {
    final normalized = _normalize(event.date);
    emit(state.copyWith(selectedDate: normalized));
    add(LoadTodosByDate(normalized));
  }

  Future<void> _onCreate(
      CreateTodoEvent event, Emitter<TodoState> emit) async {
    try {
      await createTodo(event.todo);
      await _reload(emit, state.selectedDate);
    } catch (e) {
      emit(state.copyWith(
        status: TodoStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onUpdate(
      UpdateTodoEvent event, Emitter<TodoState> emit) async {
    try {
      await updateTodo(event.todo);
      await _reload(emit, state.selectedDate);
    } catch (e) {
      emit(state.copyWith(
        status: TodoStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onDelete(
      DeleteTodoEvent event, Emitter<TodoState> emit) async {
    try {
      await deleteTodo(event.id);
      await _reload(emit, state.selectedDate);
    } catch (e) {
      emit(state.copyWith(
        status: TodoStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onToggle(
      ToggleTodoStatusEvent event, Emitter<TodoState> emit) async {
    try {
      await toggleTodoStatus(event.id, event.isCompleted);
      await _reload(emit, state.selectedDate);
    } catch (e) {
      emit(state.copyWith(
        status: TodoStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onChangeFilter(ChangeTodoFilter event, Emitter<TodoState> emit) {
    emit(state.copyWith(filter: event.filter));
  }

  Future<void> _reload(Emitter<TodoState> emit, DateTime date) async {
    final todos = await getTodosByDate(date);
    emit(state.copyWith(
      todos: todos,
      status: TodoStatus.success,
      clearError: true,
    ));
  }

  DateTime _normalize(DateTime d) => DateTime(d.year, d.month, d.day);
}
