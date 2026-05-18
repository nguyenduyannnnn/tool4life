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

  Future<Map<TransactionType, Map<String, String>>> getDistinctTitlesByType();
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

  @override
  Future<Map<TransactionType, Map<String, String>>>
      getDistinctTitlesByType() async {
    // Lấy giao dịch gần nhất (theo created_at) cho mỗi cặp (title, type) để
    // suy ra category_id mới nhất gắn với tiêu đề đó.
    final rows = await db.rawQuery(
      'SELECT t.title, t.type, t.category_id, t.created_at '
      'FROM $_txTable t '
      'INNER JOIN ('
      '  SELECT title, type, MAX(created_at) AS last_used '
      '  FROM $_txTable '
      "  WHERE title IS NOT NULL AND title != '' "
      '  GROUP BY title, type'
      ') m ON t.title = m.title AND t.type = m.type '
      '   AND t.created_at = m.last_used '
      "WHERE t.title IS NOT NULL AND t.title != '' "
      'ORDER BY t.created_at DESC',
    );
    final out = <TransactionType, Map<String, String>>{
      TransactionType.income: <String, String>{},
      TransactionType.expense: <String, String>{},
    };
    for (final r in rows) {
      final title = (r['title'] as String?)?.trim();
      final typeStr = r['type'] as String?;
      final categoryId = (r['category_id'] as String?)?.trim();
      if (title == null ||
          title.isEmpty ||
          typeStr == null ||
          categoryId == null ||
          categoryId.isEmpty) {
        continue;
      }
      final type = TransactionType.values.firstWhere(
        (t) => t.name == typeStr,
        orElse: () => TransactionType.expense,
      );
      // putIfAbsent — giữ entry đầu tiên (đã ORDER BY created_at DESC nên đây
      // chính là giao dịch gần nhất; tránh ghi đè bằng giao dịch cũ hơn nếu
      // SQL JOIN trả về nhiều dòng trùng cùng created_at).
      out[type]!.putIfAbsent(title, () => categoryId);
    }
    return out;
  }
}
