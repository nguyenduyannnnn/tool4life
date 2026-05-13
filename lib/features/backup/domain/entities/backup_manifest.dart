import 'dart:convert';

class BackupManifest {
  static const int currentVersion = 1;

  final int version;
  final String appVersion;
  final int dbVersion;
  final DateTime createdAt;
  final Map<String, int> counts;

  const BackupManifest({
    required this.version,
    required this.appVersion,
    required this.dbVersion,
    required this.createdAt,
    required this.counts,
  });

  Map<String, dynamic> toJson() => {
        'version': version,
        'app_version': appVersion,
        'db_version': dbVersion,
        'created_at': createdAt.toIso8601String(),
        'counts': counts,
      };

  String encode() => jsonEncode(toJson());

  factory BackupManifest.decode(String raw) {
    final json = jsonDecode(raw) as Map<String, dynamic>;
    return BackupManifest(
      version: json['version'] as int,
      appVersion: json['app_version'] as String? ?? '',
      dbVersion: json['db_version'] as int? ?? 0,
      createdAt: DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.now(),
      counts: (json['counts'] as Map?)?.map(
            (k, v) => MapEntry(k as String, (v as num).toInt()),
          ) ??
          const {},
    );
  }
}
