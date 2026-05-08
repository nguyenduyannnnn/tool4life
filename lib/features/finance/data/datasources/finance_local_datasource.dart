import 'package:sqflite/sqflite.dart';

import '../../../todo/data/datasources/local_database_service.dart';
import '../../domain/entities/transaction_entity.dart';
import '../models/finance_category_model.dart';
import '../models/transaction_model.dart';

abstract class FinanceLocalDataSource {
  Future<List<TransactionModel>> getTransactionsByMonth(DateTime month);

  Future<List<FinanceCategoryModel>> getAllCategories();

  Future<List<FinanceCategoryModel>> getCategoriesByType(TransactionType type);

  Future<void> upsertTransaction(TransactionModel model);

  Future<void> deleteTransactionById(String id);

  Future<int> countCategories();

  Future<void> insertCategories(List<FinanceCategoryModel> models);
}

class FinanceLocalDataSourceImpl implements FinanceLocalDataSource {
  final Database db;

  FinanceLocalDataSourceImpl(this.db);

  static const _txTable = LocalDatabaseService.financeTransactionTable;
  static const _catTable = LocalDatabaseService.financeCategoryTable;

  @override
  Future<List<TransactionModel>> getTransactionsByMonth(DateTime month) async {
    final start = DateTime(month.year, month.month, 1);
    final end = DateTime(month.year, month.month + 1, 1);
    final rows = await db.query(
      _txTable,
      where: 'date >= ? AND date < ?',
      whereArgs: [start.millisecondsSinceEpoch, end.millisecondsSinceEpoch],
    );
    return rows.map(TransactionModel.fromMap).toList();
  }

  @override
  Future<List<FinanceCategoryModel>> getAllCategories() async {
    final rows = await db.query(_catTable);
    return rows.map(FinanceCategoryModel.fromMap).toList();
  }

  @override
  Future<List<FinanceCategoryModel>> getCategoriesByType(
      TransactionType type) async {
    final rows = await db.query(
      _catTable,
      where: 'type = ?',
      whereArgs: [type.name],
    );
    return rows.map(FinanceCategoryModel.fromMap).toList();
  }

  @override
  Future<void> upsertTransaction(TransactionModel model) async {
    await db.insert(
      _txTable,
      model.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<void> deleteTransactionById(String id) async {
    await db.delete(_txTable, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> countCategories() async {
    final result = await db.rawQuery('SELECT COUNT(*) AS c FROM $_catTable');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  @override
  Future<void> insertCategories(List<FinanceCategoryModel> models) async {
    final batch = db.batch();
    for (final m in models) {
      batch.insert(
        _catTable,
        m.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
