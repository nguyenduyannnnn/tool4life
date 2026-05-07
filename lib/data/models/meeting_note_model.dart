class MeetingNoteItem {
  final String id;
  final String type;
  final String content;
  final int order;
  final Map<String, dynamic>? metadata;

  MeetingNoteItem({
    required this.id,
    required this.type,
    required this.content,
    required this.order,
    this.metadata,
  });

  factory MeetingNoteItem.fromJson(Map<String, dynamic> json) {
    return MeetingNoteItem(
      id: json['id']?.toString() ?? '',
      type: json['type'] ?? '',
      content: json['content'] ?? '',
      order: json['order'] ?? 0,
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'order': order,
      'metadata': metadata,
    };
  }
}

class MeetingNoteContent {
  final String text;
  final Map<String, dynamic>? additionalData;

  MeetingNoteContent({
    required this.text,
    this.additionalData,
  });

  factory MeetingNoteContent.fromJson(dynamic json) {
    if (json is String) {
      return MeetingNoteContent(text: json);
    } else if (json is Map<String, dynamic>) {
      return MeetingNoteContent(
        text: json['text'] ?? '',
        additionalData: json,
      );
    } else {
      return MeetingNoteContent(text: '');
    }
  }

  Map<String, dynamic> toJson() {
    if (additionalData != null) {
      return additionalData!;
    }
    return {'text': text};
  }
}

class MeetingNoteByTranscriptResponse {
  final String id;
  final String meetingId;
  final String? userId;
  final MeetingNoteContent content;
  final int version;
  final DateTime createDate;
  final DateTime? updateDate;
  final bool isDeleted;
  final String? transcriptId;
  final bool? isLatest;
  final bool? isEncrypted;
  final String? encryptionKey;
  final List<MeetingNoteItem>? items;

  MeetingNoteByTranscriptResponse({
    required this.id,
    required this.meetingId,
    this.userId,
    required this.content,
    required this.version,
    required this.createDate,
    this.updateDate,
    required this.isDeleted,
    this.transcriptId,
    this.isLatest,
    this.isEncrypted,
    this.encryptionKey,
    this.items,
  });

  factory MeetingNoteByTranscriptResponse.fromJson(Map<String, dynamic> json) {
    return MeetingNoteByTranscriptResponse(
      id: json['id']?.toString() ?? '',
      meetingId: json['meeting_id'] ?? '',
      userId: json['user_id'],
      content: MeetingNoteContent.fromJson(json['content']),
      version: json['version'] ?? 1,
      createDate:
          DateTime.tryParse(json['create_date'] ?? '') ?? DateTime.now(),
      updateDate: json['update_date'] != null
          ? DateTime.tryParse(json['update_date'])
          : null,
      isDeleted: json['is_deleted'] ?? false,
      transcriptId: json['transcript_id'],
      isLatest: json['is_latest'],
      isEncrypted: json['is_encrypted'],
      encryptionKey: json['encryption_key'],
      items: json['items'] != null
          ? (json['items'] as List)
              .map((item) => MeetingNoteItem.fromJson(item))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meeting_id': meetingId,
      'user_id': userId,
      'content': content.toJson(),
      'version': version,
      'create_date': createDate.toIso8601String(),
      'update_date': updateDate?.toIso8601String(),
      'is_deleted': isDeleted,
      'transcript_id': transcriptId,
      'is_latest': isLatest,
      'is_encrypted': isEncrypted,
      'encryption_key': encryptionKey,
      'items': items?.map((item) => item.toJson()).toList(),
    };
  }

  // Helper methods for UI display
  String get formattedCreateDate {
    final day = createDate.day.toString().padLeft(2, '0');
    final month = createDate.month.toString().padLeft(2, '0');
    final year = createDate.year;
    return '$day/$month/$year';
  }

  String get versionLabel => 'Ghi chú #$version ($formattedCreateDate)';

  String get markdownContent => content.text;

  bool get hasValidContent => content.text.isNotEmpty;

  // Version comparison methods
  static int compareByVersion(
      MeetingNoteByTranscriptResponse a, MeetingNoteByTranscriptResponse b) {
    return b.version.compareTo(a.version); // Descending order (latest first)
  }

  static int compareByDate(
      MeetingNoteByTranscriptResponse a, MeetingNoteByTranscriptResponse b) {
    return b.createDate
        .compareTo(a.createDate); // Descending order (latest first)
  }

  // Sort notes by version (latest first)
  static List<MeetingNoteByTranscriptResponse> sortByVersion(
      List<MeetingNoteByTranscriptResponse> notes) {
    final sortedNotes = List<MeetingNoteByTranscriptResponse>.from(notes);
    sortedNotes.sort(compareByVersion);
    return sortedNotes;
  }

  // Sort notes by date (latest first)
  static List<MeetingNoteByTranscriptResponse> sortByDate(
      List<MeetingNoteByTranscriptResponse> notes) {
    final sortedNotes = List<MeetingNoteByTranscriptResponse>.from(notes);
    sortedNotes.sort(compareByDate);
    return sortedNotes;
  }

  // Get the latest note from a list
  static MeetingNoteByTranscriptResponse? getLatestNote(
      List<MeetingNoteByTranscriptResponse> notes) {
    if (notes.isEmpty) return null;

    // First try to find explicitly marked latest
    final explicitLatest =
        notes.where((note) => note.isLatest == true).toList();
    if (explicitLatest.isNotEmpty) {
      return explicitLatest.first;
    }

    // Fallback to highest version number
    final sortedByVersion = sortByVersion(notes);
    return sortedByVersion.first;
  }

  // Generate version dropdown items
  static List<String> generateVersionDropdownItems(
      List<MeetingNoteByTranscriptResponse> notes) {
    final sortedNotes = sortByVersion(notes);
    return sortedNotes.map((note) => note.versionLabel).toList();
  }
}
