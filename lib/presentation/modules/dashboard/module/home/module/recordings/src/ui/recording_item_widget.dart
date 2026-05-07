import 'package:flutter/material.dart';
import 'package:changmeeting/common/theme.dart';
import 'package:changmeeting/recording/models/recording_model.dart';

class RecordingItemWidget extends StatelessWidget {
  final RecordingModel recording;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;
  final VoidCallback? onRetryUpload;
  final bool isPlaying;
  final bool isPaused;
  final Duration? currentPosition;
  final Duration? totalDuration;

  const RecordingItemWidget({
    super.key,
    required this.recording,
    this.onTap,
    this.onDelete,
    this.onRetryUpload,
    this.isPlaying = false,
    this.isPaused = false,
    this.currentPosition,
    this.totalDuration,
  });

  Widget _buildPlaybackProgress() {
    if (!isPlaying && !isPaused) {
      return const SizedBox.shrink();
    }

    final position = currentPosition ?? Duration.zero;
    final duration = totalDuration ?? Duration(seconds: recording.duration);
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    String formatDuration(Duration d) {
      final minutes = d.inMinutes;
      final seconds = d.inSeconds % 60;
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: Colors.grey[300],
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  minHeight: 4,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${formatDuration(position)} / ${formatDuration(duration)}',
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        if (isPlaying)
          const Padding(
            padding: EdgeInsets.only(top: 4),
            child: Row(
              children: [
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
                SizedBox(width: 6),
                Text(
                  'Đang phát...',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.primary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildUploadStatus() {
    if (recording.isUploading) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: recording.uploadProgress,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${(recording.uploadProgress * 100).toInt()}%',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Row(
            children: [
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                ),
              ),
              SizedBox(width: 6),
              Text(
                'Đang upload...',
                style: TextStyle(
                  fontSize: 11,
                  color: AppColors.primary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ],
      );
    } else if (recording.isUploaded) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              size: 14,
              color: Colors.green,
            ),
            const SizedBox(width: 4),
            Text(
              'Đã upload',
              style: TextStyle(
                fontSize: 11,
                color: Colors.green[700],
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            // Upload button for successful uploads
            InkWell(
              onTap: onRetryUpload,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.upload,
                      size: 12,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Upload',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else if (recording.uploadError != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            const Icon(
              Icons.error,
              size: 14,
              color: Colors.red,
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                'Lỗi upload: ${recording.uploadError}',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.red[700],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            // Retry upload button for failed uploads
            InkWell(
              onTap: onRetryUpload,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh,
                      size: 12,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Thử lại',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // For files that haven't been uploaded yet, show upload button
      return Padding(
        padding: const EdgeInsets.only(top: 8),
        child: Row(
          children: [
            const Icon(
              Icons.cloud_upload,
              size: 14,
              color: Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              'Chưa upload',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            // Upload button for new files
            InkWell(
              onTap: onRetryUpload,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.primary, width: 1),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.upload,
                      size: 12,
                      color: AppColors.primary,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Upload',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Recording icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.mic,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),

              const SizedBox(width: 16),

              // Recording info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // File name
                    Text(
                      recording.fileName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Date and time
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${recording.formattedDate} ${recording.formattedTime}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    // Duration and size
                    Row(
                      children: [
                        Icon(
                          Icons.timer,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recording.formattedDuration,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 16),
                        Icon(
                          Icons.storage,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          recording.formattedFileSize,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),

                    // Playback progress
                    _buildPlaybackProgress(),

                    // Upload status
                    _buildUploadStatus(),
                  ],
                ),
              ),

              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Play/Pause button
                  IconButton(
                    onPressed: onTap,
                    icon: Icon(
                      isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    color: AppColors.primary,
                    tooltip: isPlaying ? 'Tạm dừng' : 'Phát',
                  ),

                  // Delete button
                  IconButton(
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete),
                    color: Colors.red,
                    tooltip: 'Xóa ghi âm',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
