import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class PlaceImageStorage {
  PlaceImageStorage._();

  static final PlaceImageStorage instance = PlaceImageStorage._();

  Future<Directory> _placeDir(String placeId) async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory(p.join(docs.path, 'places', placeId));
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Copy an image picked via image_picker (in tmp/cache) into the app
  /// documents directory so the path remains valid after the OS cleans
  /// the picker cache. Returns the persistent path.
  Future<String> persist(String sourcePath, String placeId) async {
    final source = File(sourcePath);
    final dir = await _placeDir(placeId);
    final ext = p.extension(sourcePath).isEmpty
        ? '.jpg'
        : p.extension(sourcePath);
    final ts = DateTime.now().microsecondsSinceEpoch;
    final dest = File(p.join(dir.path, '$ts$ext'));
    await source.copy(dest.path);
    return dest.path;
  }

  /// Best-effort delete; ignores missing files.
  Future<void> tryDelete(String path) async {
    try {
      final f = File(path);
      if (await f.exists()) {
        await f.delete();
      }
    } catch (_) {}
  }

  Future<void> deleteAll(List<String> paths) async {
    for (final p in paths) {
      await tryDelete(p);
    }
  }
}
