import '../repositories/todo_repository.dart';

class ToggleTodoStatus {
  final TodoRepository repository;

  ToggleTodoStatus(this.repository);

  Future<void> call(String id, bool isCompleted) {
    return repository.toggleTodoStatus(id, isCompleted);
  }
}
