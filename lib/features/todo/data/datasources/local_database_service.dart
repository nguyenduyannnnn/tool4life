import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

class LocalDatabaseService {
  LocalDatabaseService._();

  static final LocalDatabaseService instance = LocalDatabaseService._();

  Database? _db;

  static const _fileName = 'tool4life.db';
  static const _version = 3;
  static const todoTable = 'todos';
  static const financeTransactionTable = 'finance_transactions';
  static const financeCategoryTable = 'finance_categories';
  static const placesTable = 'places';

  Future<Database> open() async {
    if (_db != null && _db!.isOpen) return _db!;
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, _fileName);
    _db = await openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
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

  Future<String> getDbFilePath() async {
    final dbPath = await getDatabasesPath();
    return p.join(dbPath, _fileName);
  }

  /// Flush WAL into the main db file so a raw file copy contains every commit.
  Future<void> checkpoint() async {
    final d = _db;
    if (d == null || !d.isOpen) return;
    await d.rawQuery('PRAGMA wal_checkpoint(FULL)');
  }

  Future<void> _onCreate(Database db, int version) async {
    await _createTodoSchema(db);
    await _createFinanceSchema(db);
    await _createPlacesSchema(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createFinanceSchema(db);
    }
    if (oldVersion < 3) {
      await _createPlacesSchema(db);
    }
  }

  Future<void> _createTodoSchema(Database db) async {
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

  Future<void> _createFinanceSchema(Database db) async {
    await db.execute('''
      CREATE TABLE $financeCategoryTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        type TEXT NOT NULL,
        icon TEXT NOT NULL,
        is_default INTEGER NOT NULL
      )
    ''');
    await db.execute('''
      CREATE TABLE $financeTransactionTable (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category_id TEXT NOT NULL,
        date INTEGER NOT NULL,
        note TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_${financeTransactionTable}_date ON $financeTransactionTable(date)',
    );
    await db.execute(
      'CREATE INDEX idx_${financeTransactionTable}_type ON $financeTransactionTable(type)',
    );
  }

  Future<void> _createPlacesSchema(Database db) async {
    await db.execute('''
      CREATE TABLE $placesTable (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        image_paths TEXT NOT NULL,
        visited_at INTEGER NOT NULL,
        tag TEXT,
        created_at INTEGER NOT NULL,
        updated_at INTEGER
      )
    ''');
    await db.execute(
      'CREATE INDEX idx_${placesTable}_visited_at ON $placesTable(visited_at)',
    );
    await db.execute(
      'CREATE INDEX idx_${placesTable}_tag ON $placesTable(tag)',
    );
  }
}
