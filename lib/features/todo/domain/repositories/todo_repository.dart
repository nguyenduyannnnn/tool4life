import '../entities/todo_entity.dart';

abstract class TodoRepository {
  Future<List<TodoEntity>> getTodosByDate(DateTime date);

  Future<List<TodoEntity>> getTodosByMonth(DateTime month);

  Future<void> createTodo(TodoEntity todo);

  Future<void> updateTodo(TodoEntity todo);

  Future<void> deleteTodo(String id);

  Future<void> toggleTodoStatus(String id, bool isCompleted);
}
