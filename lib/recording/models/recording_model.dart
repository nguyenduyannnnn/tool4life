class RecordingModel {
  final String id;
  final String fileName;
  final String filePath;
  final int duration; // in seconds
  final DateTime createdAt;
  final int fileSize; // in bytes
  final bool isUploading;
  final bool isUploaded;
  final double uploadProgress;
  final String? uploadError;

  RecordingModel({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.duration,
    required this.createdAt,
    required this.fileSize,
    this.isUploading = false,
    this.isUploaded = false,
    this.uploadProgress = 0.0,
    this.uploadError,
  });

  factory RecordingModel.fromJson(Map<String, dynamic> json) {
    return RecordingModel(
      id: json['id'] ?? '',
      fileName: json['fileName'] ?? '',
      filePath: json['filePath'] ?? '',
      duration: json['duration'] ?? 0,
      createdAt:
          DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      fileSize: json['fileSize'] ?? 0,
      isUploading: json['isUploading'] ?? false,
      isUploaded: json['isUploaded'] ?? false,
      uploadProgress: (json['uploadProgress'] ?? 0.0).toDouble(),
      uploadError: json['uploadError'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fileName': fileName,
      'filePath': filePath,
      'duration': duration,
      'createdAt': createdAt.toIso8601String(),
      'fileSize': fileSize,
      'isUploading': isUploading,
      'isUploaded': isUploaded,
      'uploadProgress': uploadProgress,
      'uploadError': uploadError,
    };
  }

  RecordingModel copyWith({
    String? id,
    String? fileName,
    String? filePath,
    int? duration,
    DateTime? createdAt,
    int? fileSize,
    bool? isUploading,
    bool? isUploaded,
    double? uploadProgress,
    String? uploadError,
    bool clearUploadError = false,
  }) {
    return RecordingModel(
      id: id ?? this.id,
      fileName: fileName ?? this.fileName,
      filePath: filePath ?? this.filePath,
      duration: duration ?? this.duration,
      createdAt: createdAt ?? this.createdAt,
      fileSize: fileSize ?? this.fileSize,
      isUploading: isUploading ?? this.isUploading,
      isUploaded: isUploaded ?? this.isUploaded,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      uploadError: clearUploadError ? null : (uploadError ?? this.uploadError),
    );
  }

  // Check if recording can be retried for upload
  bool get canRetryUpload {
    return !isUploading && !isUploaded && uploadError != null;
  }

  // Reset upload status for retry
  RecordingModel resetForRetry() {
    return copyWith(
      isUploading: false,
      isUploaded: false,
      uploadProgress: 0.0,
      clearUploadError: true,
    );
  }

  String get formattedDuration {
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  String get formattedFileSize {
    if (fileSize < 1024) {
      return '${fileSize}B';
    } else if (fileSize < 1024 * 1024) {
      return '${(fileSize / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/${createdAt.month.toString().padLeft(2, '0')}/${createdAt.year}';
  }

  String get formattedTime {
    return '${createdAt.hour.toString().padLeft(2, '0')}:${createdAt.minute.toString().padLeft(2, '0')}';
  }
}
