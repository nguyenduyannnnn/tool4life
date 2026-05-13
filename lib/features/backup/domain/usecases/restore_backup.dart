import 'dart:io';

import '../../data/services/backup_service.dart';

class RestoreBackup {
  final BackupService service;

  const RestoreBackup(this.service);

  Future<RestoreResult> call(File zipFile) => service.restoreBackup(zipFile);
}
