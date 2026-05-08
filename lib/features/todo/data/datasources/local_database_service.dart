import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class LocalDatabaseService {
  LocalDatabaseService._();

  static final LocalDatabaseService instance = LocalDatabaseService._();

  Database? _db;

  static const _fileName = 'tool4life.db';
  static const _version = 1;
  static const todoTable = 'todos';

  Future<Database> open() async {
    if (_db != null && _db!.isOpen) return _db!;
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _fileName);
    _db = await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
    );
    return _db!;
  }

  Database get db {
    final d = _db;
    if (d == null || !d.isOpen) {
      throw StateError(
        'LocalDatabaseService chưa được mở. Gọi LocalDatabaseService.instance.open() trong main() trước khi dùng.',
      );
    }
    return d;
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $todoTable (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        date INTEGER NOT NULL,
        priority TEXT NOT NULL,
        is_completed INTEGER NOT NULL,
        created_at INTEGER NOT NULL,
        updated_at INTEGER NOT NULL
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_${todoTable}_date ON $todoTable(date)',
    );
  }
}
