class MeetingFileModel {
  final String meetingId;
  final String fileType;
  final String? filePath;
  final String objectName;
  final String fileUrl;
  final int fileSizeBytes;
  final int? durationSeconds;
  final String? mimeType;
  final String uploadedAt;
  final bool processed;
  final String processingStatus;
  final String? processingError;
  final String id;
  final String createDate;
  final String? updateDate;
  final bool isDeleted;

  MeetingFileModel({
    required this.meetingId,
    required this.fileType,
    this.filePath,
    required this.objectName,
    required this.fileUrl,
    required this.fileSizeBytes,
    this.durationSeconds,
    this.mimeType,
    required this.uploadedAt,
    required this.processed,
    required this.processingStatus,
    this.processingError,
    required this.id,
    required this.createDate,
    this.updateDate,
    required this.isDeleted,
  });

  factory MeetingFileModel.fromJson(Map<String, dynamic> json) {
    return MeetingFileModel(
      meetingId: json['meeting_id'] ?? '',
      fileType: json['file_type'] ?? '',
      filePath: json['file_path'],
      objectName: json['object_name'] ?? '',
      fileUrl: json['file_url'] ?? '',
      fileSizeBytes: json['file_size_bytes'] ?? 0,
      durationSeconds: json['duration_seconds'],
      mimeType: json['mime_type'],
      uploadedAt: json['uploaded_at'] ?? '',
      processed: json['processed'] ?? false,
      processingStatus: json['processing_status'] ?? '',
      processingError: json['processing_error'],
      id: json['id']?.toString() ?? '',
      createDate: json['create_date'] ?? '',
      updateDate: json['update_date'],
      isDeleted: json['is_deleted'] ?? false,
    );
  }
}

class MeetingFilesResponse {
  final int errorCode;
  final String message;
  final String? description;
  final List<MeetingFileModel> data;

  MeetingFilesResponse({
    required this.errorCode,
    required this.message,
    this.description,
    required this.data,
  });

  factory MeetingFilesResponse.fromJson(Map<String, dynamic> json) {
    return MeetingFilesResponse(
      errorCode: json['error_code'] ?? 0,
      message: json['message'] ?? '',
      description: json['description'],
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => MeetingFileModel.fromJson(item))
              .toList() ??
          [],
    );
  }
}
