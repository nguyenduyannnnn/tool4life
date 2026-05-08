import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class CreateTodo {
  final TodoRepository repository;

  CreateTodo(this.repository);

  Future<void> call(TodoEntity todo) {
    return repository.createTodo(todo);
  }
}
