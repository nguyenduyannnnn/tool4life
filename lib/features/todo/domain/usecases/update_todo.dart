import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class UpdateTodo {
  final TodoRepository repository;

  UpdateTodo(this.repository);

  Future<void> call(TodoEntity todo) {
    return repository.updateTodo(todo);
  }
}
