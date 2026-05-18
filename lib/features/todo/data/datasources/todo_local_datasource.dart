import 'package:sqflite/sqflite.dart';

import '../models/todo_model.dart';
import 'local_database_service.dart';

abstract class TodoLocalDataSource {
  Future<List<TodoModel>> getTodosByDate(DateTime date);

  Future<List<TodoModel>> getTodosByMonth(DateTime month);

  Future<void> upsert(TodoModel model);

  Future<void> deleteById(String id);

  Future<TodoModel?> findById(String id);

  Future<void> updateCompletion(String id, bool isCompleted, DateTime updatedAt);
}

class TodoLocalDataSourceImpl implements TodoLocalDataSource {
  final Database db;

  TodoLocalDataSourceImpl(this.db);

  static const _table = LocalDatabaseService.todoTable;

  @override
  Future<List<TodoModel>> getTodosByDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final rows = await db.query(
      _table,
      where: 'date >= ? AND date < ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );
    return rows.map(TodoModel.fromMap).toList();
  }

  @override
  Future<List<TodoModel>> getTodosByMonth(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final rows = await db.query(
      _table,
      where: 'date >= ? AND date < ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );
    return rows.map(TodoModel.fromMap).toList();
  }

  @override
  Future<void> upsert(TodoModel model) async {
    await db.insert(
      _table,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteById(String id) async {
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<TodoModel?> findById(String id) async {
    final rows = await db.query(
      _table,
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return TodoModel.fromMap(rows.first);
  }

  @override
  Future<void> updateCompletion(
    String id,
    bool isCompleted,
    DateTime updatedAt,
  ) async {
    await db.update(
      _table,
      {
        'is_completed': isCompleted ? 1 : 0,
        'updated_at': updatedAt.millisecondsSinceEpoch,
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
