class SimpleMeetingNoteModel {
  final String meetingId;
  final String transcriptId;
  final Map<String, dynamic> content;
  final int version;
  final bool isLatest;
  final bool isEncrypted;
  final String? encryptionKey;
  final String id;
  final String createDate;
  final String? updateDate;
  final bool isDeleted;

  SimpleMeetingNoteModel({
    required this.meetingId,
    required this.transcriptId,
    required this.content,
    required this.version,
    required this.isLatest,
    required this.isEncrypted,
    this.encryptionKey,
    required this.id,
    required this.createDate,
    this.updateDate,
    required this.isDeleted,
  });

  factory SimpleMeetingNoteModel.fromJson(Map<String, dynamic> json) {
    return SimpleMeetingNoteModel(
      meetingId: json['meeting_id'].toString() ?? '',
      transcriptId: json['transcript_id'].toString() ?? '',
      content: json['content'] ?? {},
      version: json['version'] ?? 1,
      isLatest: json['is_latest'] ?? false,
      isEncrypted: json['is_encrypted'] ?? false,
      encryptionKey: json['encryption_key'],
      id: json['id']?.toString() ?? '',
      createDate: json['create_date'] ?? '',
      updateDate: json['update_date'],
      isDeleted: json['is_deleted'] ?? false,
    );
  }

  String get markdownText => content['text'] ?? '';
}

class SimpleMeetingNotesResponse {
  final int errorCode;
  final String message;
  final String? description;
  final List<SimpleMeetingNoteModel> data;

  SimpleMeetingNotesResponse({
    required this.errorCode,
    required this.message,
    this.description,
    required this.data,
  });

  factory SimpleMeetingNotesResponse.fromJson(Map<String, dynamic> json) {
    return SimpleMeetingNotesResponse(
      errorCode: json['error_code'] ?? 0,
      message: json['message'] ?? '',
      description: json['description'],
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => SimpleMeetingNoteModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}
