import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:archive/archive_io.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../todo/data/datasources/local_database_service.dart';
import '../../domain/entities/backup_manifest.dart';

class RestoreResult {
  final BackupManifest manifest;
  final int placesPathsRewritten;

  const RestoreResult({
    required this.manifest,
    required this.placesPathsRewritten,
  });
}

class BackupException implements Exception {
  final String message;
  const BackupException(this.message);
  @override
  String toString() => message;
}

class BackupService {
  static const String _manifestEntry = 'manifest.json';
  static const String _dbEntry = 'tool4life.db';
  static const String _placesPrefix = 'places/';
  static const String _appVersion = '1.0.1';

  BackupService();

  Future<File> createBackup() async {
    final db = LocalDatabaseService.instance.db;
    await LocalDatabaseService.instance.checkpoint();

    final counts = await _countRows(db);

    final dbFilePath = await LocalDatabaseService.instance.getDbFilePath();
    final dbFile = File(dbFilePath);
    if (!await dbFile.exists()) {
      throw const BackupException('Không tìm thấy file database để sao lưu.');
    }
    final dbBytes = await dbFile.readAsBytes();

    final docsDir = await getApplicationDocumentsDirectory();
    final placesDir = Directory(p.join(docsDir.path, 'places'));

    final archive = Archive();

    final manifest = BackupManifest(
      version: BackupManifest.currentVersion,
      appVersion: _appVersion,
      dbVersion: 3,
      createdAt: DateTime.now(),
      counts: counts,
    );
    final manifestBytes = utf8.encode(manifest.encode());
    archive.addFile(
      ArchiveFile(_manifestEntry, manifestBytes.length, manifestBytes),
    );
    archive.addFile(ArchiveFile(_dbEntry, dbBytes.length, dbBytes));

    if (await placesDir.exists()) {
      await for (final entity in placesDir.list(recursive: true)) {
        if (entity is File) {
          final rel = p.relative(entity.path, from: docsDir.path);
          final normalized = rel.replaceAll('\\', '/');
          final bytes = await entity.readAsBytes();
          archive.addFile(ArchiveFile(normalized, bytes.length, bytes));
        }
      }
    }

    final tmpDir = await getTemporaryDirectory();
    final ts = _timestamp();
    final outFile = File(p.join(tmpDir.path, 'tool4life_backup_$ts.zip'));
    final encoded = ZipEncoder().encode(archive);
    if (encoded == null) {
      throw const BackupException('Không thể tạo file zip sao lưu.');
    }
    await outFile.writeAsBytes(encoded, flush: true);
    return outFile;
  }

  Future<RestoreResult> restoreBackup(File zipFile) async {
    if (!await zipFile.exists()) {
      throw const BackupException('File sao lưu không tồn tại.');
    }
    final bytes = await zipFile.readAsBytes();
    final Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes);
    } catch (_) {
      throw const BackupException('File sao lưu không hợp lệ (không phải zip).');
    }

    final manifestFile = archive.findFile(_manifestEntry);
    final dbArchiveFile = archive.findFile(_dbEntry);
    if (manifestFile == null || dbArchiveFile == null) {
      throw const BackupException(
        'File sao lưu thiếu manifest hoặc database. Có thể đã hỏng.',
      );
    }

    final BackupManifest manifest;
    try {
      manifest = BackupManifest.decode(
        utf8.decode(manifestFile.content as List<int>),
      );
    } catch (_) {
      throw const BackupException('Manifest trong file sao lưu không đọc được.');
    }
    if (manifest.version != BackupManifest.currentVersion) {
      throw BackupException(
        'Phiên bản sao lưu không tương thích (v${manifest.version}). '
        'Hãy cập nhật app rồi thử lại.',
      );
    }

    final dbFilePath = await LocalDatabaseService.instance.getDbFilePath();
    final docsDir = await getApplicationDocumentsDirectory();
    final placesDir = Directory(p.join(docsDir.path, 'places'));

    await LocalDatabaseService.instance.close();

    final dbBak = File('$dbFilePath.bak');
    final placesBak = Directory('${placesDir.path}.bak');
    if (await dbBak.exists()) await dbBak.delete();
    if (await placesBak.exists()) await placesBak.delete(recursive: true);

    final originalDb = File(dbFilePath);
    if (await originalDb.exists()) {
      await originalDb.rename(dbBak.path);
    }
    if (await placesDir.exists()) {
      await placesDir.rename(placesBak.path);
    }

    try {
      await Directory(p.dirname(dbFilePath)).create(recursive: true);
      await File(dbFilePath)
          .writeAsBytes(dbArchiveFile.content as List<int>, flush: true);

      for (final entry in archive) {
        if (!entry.isFile) continue;
        if (entry.name == _manifestEntry || entry.name == _dbEntry) continue;
        if (!entry.name.startsWith(_placesPrefix)) continue;
        final safeRel = _sanitize(entry.name);
        if (safeRel == null) continue;
        final outPath = p.join(docsDir.path, safeRel);
        final outFile = File(outPath);
        await outFile.parent.create(recursive: true);
        await outFile.writeAsBytes(entry.content as List<int>, flush: true);
      }

      await LocalDatabaseService.instance.open();
      final rewritten = await _rewritePlaceImagePaths(docsDir.path);

      if (await dbBak.exists()) await dbBak.delete();
      if (await placesBak.exists()) await placesBak.delete(recursive: true);

      return RestoreResult(
        manifest: manifest,
        placesPathsRewritten: rewritten,
      );
    } catch (e) {
      await _rollback(dbFilePath, placesDir, dbBak, placesBak);
      try {
        await LocalDatabaseService.instance.open();
      } catch (_) {}
      throw BackupException('Khôi phục thất bại: $e. Đã rollback dữ liệu cũ.');
    }
  }

  Future<Map<String, int>> _countRows(dynamic db) async {
    final counts = <String, int>{};
    for (final table in const [
      LocalDatabaseService.todoTable,
      LocalDatabaseService.financeTransactionTable,
      LocalDatabaseService.placesTable,
    ]) {
      final rows = await db.rawQuery('SELECT COUNT(*) AS c FROM $table');
      counts[table] = (rows.first['c'] as num).toInt();
    }
    return counts;
  }

  Future<int> _rewritePlaceImagePaths(String docsPath) async {
    final db = LocalDatabaseService.instance.db;
    final rows = await db.query(
      LocalDatabaseService.placesTable,
      columns: const ['id', 'image_paths'],
    );
    var updated = 0;
    for (final row in rows) {
      final id = row['id'] as String;
      final raw = row['image_paths'] as String? ?? '[]';
      final list = (jsonDecode(raw) as List).cast<String>();
      if (list.isEmpty) continue;
      final rebuilt = list.map((oldPath) {
        final filename = p.basename(oldPath);
        final placeFolder = p.basename(p.dirname(oldPath));
        return p.join(docsPath, 'places', placeFolder, filename);
      }).toList();
      await db.update(
        LocalDatabaseService.placesTable,
        {'image_paths': jsonEncode(rebuilt)},
        where: 'id = ?',
        whereArgs: [id],
      );
      updated++;
    }
    return updated;
  }

  Future<void> _rollback(
    String dbFilePath,
    Directory placesDir,
    File dbBak,
    Directory placesBak,
  ) async {
    try {
      final current = File(dbFilePath);
      if (await current.exists()) await current.delete();
    } catch (_) {}
    try {
      if (await placesDir.exists()) await placesDir.delete(recursive: true);
    } catch (_) {}
    try {
      if (await dbBak.exists()) await dbBak.rename(dbFilePath);
    } catch (_) {}
    try {
      if (await placesBak.exists()) await placesBak.rename(placesDir.path);
    } catch (_) {}
  }

  String? _sanitize(String relPath) {
    final norm = relPath.replaceAll('\\', '/');
    if (norm.contains('..')) return null;
    if (norm.startsWith('/')) return null;
    return norm;
  }

  String _timestamp() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${now.year}${two(now.month)}${two(now.day)}_'
        '${two(now.hour)}${two(now.minute)}${two(now.second)}';
  }
}
