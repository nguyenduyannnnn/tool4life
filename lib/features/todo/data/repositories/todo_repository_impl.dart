import '../../domain/entities/todo_entity.dart';
import '../../domain/repositories/todo_repository.dart';
import '../datasources/todo_local_datasource.dart';
import '../models/todo_model.dart';

class TodoRepositoryImpl implements TodoRepository {
  final TodoLocalDataSource localDataSource;

  TodoRepositoryImpl(this.localDataSource);

  @override
  Future<List<TodoEntity>> getTodosByDate(DateTime date) async {
    final models = await localDataSource.getTodosByDate(date);
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<List<TodoEntity>> getTodosByMonth(DateTime month) async {
    final models = await localDataSource.getTodosByMonth(month);
    return models.map((e) => e.toEntity()).toList();
  }

  @override
  Future<void> createTodo(TodoEntity todo) {
    return localDataSource.upsert(TodoModel.fromEntity(todo));
  }

  @override
  Future<void> updateTodo(TodoEntity todo) {
    return localDataSource.upsert(TodoModel.fromEntity(todo));
  }

  @override
  Future<void> deleteTodo(String id) {
    return localDataSource.deleteById(id);
  }

  @override
  Future<void> toggleTodoStatus(String id, bool isCompleted) async {
    final existing = await localDataSource.findById(id);
    if (existing == null) {
      throw StateError('Không tìm thấy todo với id=$id');
    }
    await localDataSource.updateCompletion(id, isCompleted, DateTime.now());
  }
}
