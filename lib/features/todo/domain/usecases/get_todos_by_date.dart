import '../entities/todo_entity.dart';
import '../repositories/todo_repository.dart';

class GetTodosByDate {
  final TodoRepository repository;

  GetTodosByDate(this.repository);

  Future<List<TodoEntity>> call(DateTime date) {
    return repository.getTodosByDate(date);
  }
}
