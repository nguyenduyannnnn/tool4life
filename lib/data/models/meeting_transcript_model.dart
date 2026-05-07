class MeetingTranscriptsResponse {
  final String id;
  final String meetingId;
  final dynamic content; // Can be Map<String, dynamic> or String or null
  final String? source;
  final String language;
  final String createDate;
  final String updateDate;
  final bool isDeleted;
  final int? version;
  final String? status;
  final String?
      processingStatus; // 'queued' | 'processing' | 'completed' | 'failed'
  final Map<String, dynamic>? metadata;

  MeetingTranscriptsResponse({
    required this.id,
    required this.meetingId,
    required this.content,
    this.source,
    required this.language,
    required this.createDate,
    required this.updateDate,
    required this.isDeleted,
    this.version,
    this.status,
    this.processingStatus,
    this.metadata,
  });

  factory MeetingTranscriptsResponse.fromJson(Map<String, dynamic> json) {
    return MeetingTranscriptsResponse(
      id: json['id']?.toString() ?? '',
      meetingId: json['meeting_id'].toString() ?? '',
      content: json['content'],
      source: json['source'],
      language: json['language'] ?? '',
      createDate: json['create_date'] ?? '',
      updateDate: json['update_date'] ?? '',
      isDeleted: json['is_deleted'] ?? false,
      version: json['version'],
      status: json['status'],
      processingStatus: json['processing_status'],
      metadata: json['metadata'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'meeting_id': meetingId,
      'content': content,
      'source': source,
      'language': language,
      'create_date': createDate,
      'update_date': updateDate,
      'is_deleted': isDeleted,
      'version': version,
      'status': status,
      'processing_status': processingStatus,
      'metadata': metadata,
    };
  }

  // Helper getter to extract text content
  String get textContent {
    if (content == null) return '';

    if (content is Map<String, dynamic>) {
      final Map<String, dynamic> contentMap = content as Map<String, dynamic>;
      return contentMap['text']?.toString() ?? '';
    } else if (content is String) {
      return content as String;
    }

    return '';
  }

  // Helper getter for formatted create date
  String get formattedCreateDate {
    try {
      final DateTime dateTime = DateTime.parse(createDate);
      return '${dateTime.day.toString().padLeft(2, '0')}/${dateTime.month.toString().padLeft(2, '0')}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return createDate;
    }
  }

  // Helper to check if transcript is ready
  bool get isReady => processingStatus == 'completed';
  bool get isProcessing =>
      processingStatus == 'queued' || processingStatus == 'processing';
  bool get isFailed => processingStatus == 'failed';

  // Helper to generate version dropdown items
  static List<String> generateVersionDropdownItems(
      List<MeetingTranscriptsResponse> transcripts) {
    return transcripts.asMap().entries.map((entry) {
      final int index = entry.key;
      return 'Bản ghi #${index + 1}';
    }).toList();
  }

  // Helper to parse transcript content into speaker segments
  List<TranscriptSegment> parseTranscriptSegments() {
    final String content = textContent;
    if (content.isEmpty) return [];

    final List<TranscriptSegment> segments = [];

    // Split by double newlines to get speaker segments
    final List<String> rawSegments =
        content.split('\n\n').where((s) => s.trim().isNotEmpty).toList();

    for (String segment in rawSegments) {
      final String trimmedSegment = segment.trim();
      if (trimmedSegment.isEmpty) continue;

      // Parse speaker and timestamp using regex
      final RegExp speakerRegex = RegExp(r'^(SPEAKER_\d+)\s*\[(.*?)\]\s*(.*)$',
          multiLine: true, dotAll: true);
      final Match? match = speakerRegex.firstMatch(trimmedSegment);

      if (match != null) {
        final String speaker = match.group(1) ?? '';
        final String timestamp = match.group(2) ?? '';
        final String text = match.group(3)?.trim() ?? '';

        if (speaker.isNotEmpty && text.isNotEmpty) {
          segments.add(TranscriptSegment(
            speaker: speaker,
            timestamp: timestamp,
            text: text,
          ));
        }
      } else {
        // Fallback: treat entire segment as unknown speaker
        segments.add(TranscriptSegment(
          speaker: 'SPEAKER_UNKNOWN',
          timestamp: '',
          text: trimmedSegment,
        ));
      }
    }

    return segments;
  }
}

// Model for individual transcript segments
class TranscriptSegment {
  final String speaker;
  final String timestamp;
  final String text;

  TranscriptSegment({
    required this.speaker,
    required this.timestamp,
    required this.text,
  });

  // Helper to format speaker name
  String get formattedSpeaker {
    if (speaker.startsWith('SPEAKER_')) {
      final String speakerNumber = speaker.replaceFirst('SPEAKER_', '');
      return 'Người nói $speakerNumber';
    }
    return speaker;
  }
}

// Response wrapper for transcript API
class MeetingTranscriptsApiResponse {
  final List<MeetingTranscriptsResponse> data;

  MeetingTranscriptsApiResponse({
    required this.data,
  });

  factory MeetingTranscriptsApiResponse.fromJson(Map<String, dynamic> json) {
    final List<dynamic> dataList = json['data'] ?? [];
    return MeetingTranscriptsApiResponse(
      data: dataList
          .map((item) => MeetingTranscriptsResponse.fromJson(item))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': data.map((item) => item.toJson()).toList(),
    };
  }
}


