import 'dart:io';

import '../../data/services/backup_service.dart';

class CreateBackup {
  final BackupService service;

  const CreateBackup(this.service);

  Future<File> call() => service.createBackup();
}
