import 'package:sqflite/sqflite.dart';

import '../../../todo/data/datasources/local_database_service.dart';
import '../models/place_model.dart';

abstract class PlacesLocalDataSource {
  Future<List<PlaceModel>> getAll();

  Future<List<PlaceModel>> search(String keyword);

  Future<List<PlaceModel>> getByTag(String tag);

  Future<void> upsert(PlaceModel model);

  Future<void> deleteById(String id);
}

class PlacesLocalDataSourceImpl implements PlacesLocalDataSource {
  final Database db;

  PlacesLocalDataSourceImpl(this.db);

  static const _table = LocalDatabaseService.placesTable;

  @override
  Future<List<PlaceModel>> getAll() async {
    final rows = await db.query(_table, orderBy: 'visited_at DESC');
    return rows.map(PlaceModel.fromMap).toList();
  }

  @override
  Future<List<PlaceModel>> search(String keyword) async {
    final like = '%${keyword.toLowerCase()}%';
    final rows = await db.query(
      _table,
      where: 'LOWER(name) LIKE ? OR LOWER(description) LIKE ?',
      whereArgs: [like, like],
      orderBy: 'visited_at DESC',
    );
    return rows.map(PlaceModel.fromMap).toList();
  }

  @override
  Future<List<PlaceModel>> getByTag(String tag) async {
    final rows = await db.query(
      _table,
      where: 'tag = ?',
      whereArgs: [tag],
      orderBy: 'visited_at DESC',
    );
    return rows.map(PlaceModel.fromMap).toList();
  }

  @override
  Future<void> upsert(PlaceModel model) async {
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
}
