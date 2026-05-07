import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:changmeeting/common/theme.dart';
import 'package:changmeeting/recording/models/recording_model.dart';
import 'package:changmeeting/recording/services/upload_service.dart';
import 'package:changmeeting/recording/services/audio_player_service.dart';
import 'package:changmeeting/recording/services/file_manager_service.dart';
import '../bloc/recordings_list_bloc.dart';
import 'recording_item_widget.dart';

class RecordingsListScreen extends StatefulWidget {
  const RecordingsListScreen({super.key});

  @override
  State<RecordingsListScreen> createState() => _RecordingsListScreenState();
}

class _RecordingsListScreenState extends State<RecordingsListScreen> {
  final RecordingsListBloc _bloc = RecordingsListBloc();
  final UploadService _uploadService = UploadService();
  final AudioPlayerService _audioPlayerService = AudioPlayerService();
  final FileManagerService _fileManagerService = FileManagerService();
  
  StreamSubscription<RecordingModel>? _uploadSubscription;
  StreamSubscription<String?>? _playingIdSubscription;
  StreamSubscription<Duration>? _positionSubscription;
  StreamSubscription<Duration>? _durationSubscription;
  
  final Map<String, RecordingModel> _uploadingRecordings = {};
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _listenToUploadProgress();
    _listenToAudioPlayer();
  }

  void _listenToAudioPlayer() {
    _playingIdSubscription = _audioPlayerService.playingIdStream.listen((playingId) {
      if (mounted) {
        setState(() {
          // Update UI when playing ID changes
        });
      }
    });

    _positionSubscription = _audioPlayerService.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _currentPosition = position;
        });
      }
    });

    _durationSubscription = _audioPlayerService.durationStream.listen((duration) {
      if (mounted) {
        setState(() {
          _totalDuration = duration;
        });
      }
    });
  }
  @override
  void dispose() {
    _uploadSubscription?.cancel();
    _playingIdSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _bloc.dispose();
    super.dispose();
  }

  void _listenToUploadProgress() {
    _uploadSubscription = _uploadService.uploadProgressStream.listen((recording) {
      if (mounted) {
        setState(() {
          _uploadingRecordings[recording.id] = recording;
        });

        if (recording.isUploaded) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Đã upload audio cuộc họp thành công lên server, Vui lòng chờ xử lý',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppColors.primary,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              action: SnackBarAction(
                label: 'OK',
                textColor: Colors.white,
                onPressed: () {},
              ),
            ),
          );
        }

        if (recording.uploadError != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Lỗi upload: ${recording.uploadError}',
                style: const TextStyle(color: Colors.white),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 4),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    });
  }
  Future<void> _handleRetryUpload(RecordingModel recording) async {
    // Show confirmation dialog first
    final shouldUpload = await _showReuploadConfirmationDialog(recording);
    if (shouldUpload != true) return;

    try {
      final resetRecording = recording.resetForRetry();
      await _fileManagerService.saveRecordingMetadata(resetRecording);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
                SizedBox(width: 12),
                Text(
                  'Đang upload lại...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 2),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }

      await _uploadService.uploadRecording(resetRecording, context: context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Lỗi upload: ${e.toString()}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }
  Future<void> _pickAndUploadAudioFile() async {
    try {
      // Hiển thị dialog hướng dẫn user về thư mục Meobeo
      final shouldShowMeobeoInfo = await _showFolderInfoDialog();
      if (shouldShowMeobeoInfo != true) return;

      // Pick audio file - chấp nhận tất cả file để tránh filter issue
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.any, // Thay đổi từ FileType.custom
        allowMultiple: false,
      );

      if (result == null || result.files.isEmpty) return;

      final pickedFile = result.files.first;
      if (pickedFile.path == null) {
        throw Exception('Không thể truy cập file');
      }

      final file = File(pickedFile.path!);
      if (!await file.exists()) {
        throw Exception('File không tồn tại');
      }

      final fileSize = await file.length();
      final fileName = pickedFile.name;

      // Validate file extension
      final extension = fileName.toLowerCase().split('.').last;
      final supportedExtensions = ['mp3', 'webm', 'm4a', 'wav', 'aac', 'ogg'];
      
      if (!supportedExtensions.contains(extension)) {
        throw Exception('File không được hỗ trợ. Chỉ hỗ trợ: ${supportedExtensions.join(', ').toUpperCase()}');
      }

      final shouldUpload = await _showUploadConfirmationDialog(fileName, fileSize);
      if (shouldUpload != true) return;

      setState(() {
        _isUploading = true;
      });

      final recordingId = _fileManagerService.generateRecordingId();
      final recordingsDir = await _fileManagerService.getRecordingsDirectory();
      final destinationPath = '${recordingsDir.path}/$fileName';
      
      await file.copy(destinationPath);

      final recording = RecordingModel(
        id: recordingId,
        fileName: fileName,
        filePath: destinationPath,
        duration: 0,
        createdAt: DateTime.now(),
        fileSize: fileSize,
      );

      await _fileManagerService.saveRecordingMetadata(recording);
      await _uploadService.uploadRecording(recording, context: context);

      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'File đã được thêm và đang upload',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Lỗi: ${e.toString()}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<bool?> _showFolderInfoDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.upload_file,
              color: AppColors.primary,
              size: 28,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Upload file audio',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Chọn file audio để upload lên server.',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.audio_file,
                  color: Colors.orange,
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hỗ trợ: MP3, M4A, WAV, AAC, OGG, WEBM',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.file_open, size: 20),
                SizedBox(width: 8),
                Text(
                  'Chọn file',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
  Future<bool?> _showReuploadConfirmationDialog(RecordingModel recording) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.upload_file,
              color: AppColors.primary,
              size: 28,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Upload lại file',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bạn có muốn upload file này lên server không?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.audio_file,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recording.fileName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${recording.formattedDuration} • ${recording.formattedFileSize}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.upload, size: 20),
                SizedBox(width: 8),
                Text(
                  'Upload',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Future<bool?> _showUploadConfirmationDialog(String fileName, int fileSize) async {
    return await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(
              Icons.upload_file,
              color: AppColors.primary,
              size: 28,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Xác nhận upload',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bạn có muốn upload file audio này?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.audio_file,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatFileSize(fileSize),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.upload, size: 20),
                SizedBox(width: 8),
                Text(
                  'Upload',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }
  Future<void> _handlePlayPause(RecordingModel recording) async {
    try {
      final isCurrentlyPlaying = _audioPlayerService.isPlayingRecording(recording.id);
      final isCurrentlyPaused = _audioPlayerService.isPausedRecording(recording.id);

      if (isCurrentlyPlaying) {
        await _audioPlayerService.pause();
      } else if (isCurrentlyPaused) {
        await _audioPlayerService.resume();
      } else {
        await _audioPlayerService.play(recording.id, recording.filePath);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Không thể phát file: ${e.toString()}',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        );
      }
    }
  }

  Future<void> _showDeleteConfirmation(RecordingModel recording) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.orange[700],
              size: 28,
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Xác nhận xóa',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bạn có chắc chắn muốn xóa file audio này?',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.audio_file,
                    color: AppColors.primary,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recording.fileName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${recording.formattedDuration} • ${recording.formattedFileSize}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'File sẽ bị xóa vĩnh viễn và không thể khôi phục.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.red[700],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Hủy',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.delete, size: 20),
                SizedBox(width: 8),
                Text(
                  'Xóa',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );

    if (shouldDelete == true) {
      final success = await _bloc.deleteRecording(recording.id);

      if (mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Đã xóa file "${recording.fileName}"',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Row(
                children: [
                  Icon(Icons.error, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Không thể xóa file. Vui lòng thử lại.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          );
        }
      }
    }
  }
  Widget _buildStorageInfo() {
    return FutureBuilder<int>(
      future: _bloc.getTotalStorageUsed(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final totalSize = snapshot.data!;
          return Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.storage,
                  color: AppColors.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tổng dung lượng: ${_formatFileSize(totalSize)}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Material(
                  color: _isUploading ? Colors.grey[300] : AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: _isUploading ? null : _pickAndUploadAudioFile,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _isUploading ? Icons.hourglass_empty : Icons.upload_file,
                            color: Colors.white,
                            size: 20,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _isUploading ? 'Đang upload...' : 'Upload',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildRecordingsList(List<RecordingModel> recordings) {
    return ListView.builder(
      itemCount: recordings.length,
      itemBuilder: (context, index) {
        final recording = recordings[index];
        final displayRecording = _uploadingRecordings[recording.id] ?? recording;
        // final isPlaying = _audioPlayerService.isPlayingRecording(recording.id);
        // final isPaused = _audioPlayerService.isPausedRecording(recording.id);

        return RecordingItemWidget(
          recording: displayRecording,
          // isPlaying: isPlaying,
          // isPaused: isPaused,
          // currentPosition: (isPlaying || isPaused) ? _currentPosition : null,
          // totalDuration: (isPlaying || isPaused) ? _totalDuration : null,
          // onTap: () => _handlePlayPause(recording),
          onDelete: () => _showDeleteConfirmation(recording),
          onRetryUpload: () => _handleRetryUpload(recording), // Always show retry upload button
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách ghi âm'),
      ),
      body: Column(
        children: [
          _buildStorageInfo(),
          Expanded(
            child: StreamBuilder<List<RecordingModel>>(
              stream: _bloc.recordingsStream,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Lỗi: ${snapshot.error}',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.red[600],
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => _bloc.refreshRecordings(),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  );
                }

                final recordings = snapshot.data ?? [];

                if (recordings.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.mic_off,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Chưa có file ghi âm nào',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Sử dụng bubble ghi âm để tạo file ghi âm đầu tiên',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: _bloc.refreshRecordings,
                  child: _buildRecordingsList(recordings),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}