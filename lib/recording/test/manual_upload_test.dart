import 'package:flutter/material.dart';
import 'package:changmeeting/recording/services/file_manager_service.dart';
import 'package:changmeeting/recording/services/upload_service.dart';
import 'package:changmeeting/recording/services/consent_service.dart';
import 'package:changmeeting/recording/models/recording_model.dart';
import 'package:changmeeting/common/theme.dart';

/// Test screen để trigger upload manual và test consent dialog
class ManualUploadTest extends StatefulWidget {
  const ManualUploadTest({super.key});

  @override
  State<ManualUploadTest> createState() => _ManualUploadTestState();
}

class _ManualUploadTestState extends State<ManualUploadTest> {
  final FileManagerService _fileManagerService = FileManagerService();
  final UploadService _uploadService = UploadService();
  final ConsentService _consentService = ConsentService();
  
  List<RecordingModel> _recordings = [];
  bool _isLoading = false;
  bool _hasConsent = false;

  @override
  void initState() {
    super.initState();
    _loadRecordings();
    _checkConsent();
  }

  Future<void> _loadRecordings() async {
    final recordings = await _fileManagerService.getAllRecordings();
    setState(() {
      _recordings = recordings;
    });
  }

  Future<void> _checkConsent() async {
    final hasConsent = await _consentService.hasUserConsent();
    setState(() {
      _hasConsent = hasConsent;
    });
  }

  Future<void> _testUploadWithConsent(RecordingModel recording) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // This should show consent dialog if user hasn't agreed yet
      final success = await _uploadService.uploadRecording(
        recording, 
        context: context,
      );
      
      // Update consent status
      await _checkConsent();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              success 
                ? '✅ Upload thành công!' 
                : '❌ Upload bị hủy (user từ chối consent)',
            ),
            backgroundColor: success ? Colors.green : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _resetConsent() async {
    await _consentService.revokeConsent();
    await _checkConsent();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🔄 Consent đã được reset'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  Future<void> _createMockRecording() async {
    final mockRecording = RecordingModel(
      id: 'mock_${DateTime.now().millisecondsSinceEpoch}',
      fileName: 'mock_recording_${DateTime.now().millisecondsSinceEpoch}.m4a',
      filePath: '/path/to/mock_recording.m4a',
      duration: 180, // 3 minutes
      createdAt: DateTime.now(),
      fileSize: 1024 * 1024, // 1MB
    );

    await _fileManagerService.saveRecordingMetadata(mockRecording);
    await _loadRecordings();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📁 Mock recording created'),
          backgroundColor: Colors.blue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manual Upload Test'),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _createMockRecording,
            tooltip: 'Create Mock Recording',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Consent status
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _hasConsent ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _hasConsent ? Colors.green : Colors.orange,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _hasConsent ? Icons.check_circle : Icons.warning,
                        color: _hasConsent ? Colors.green : Colors.orange,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Upload Consent: ${_hasConsent ? "Granted" : "Not granted"}',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _hasConsent ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _hasConsent 
                      ? 'User đã đồng ý upload. Upload sẽ không hiện dialog.'
                      : 'User chưa đồng ý. Upload sẽ hiện consent dialog.',
                    style: TextStyle(
                      fontSize: 12,
                      color: _hasConsent ? Colors.green[700] : Colors.orange[700],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Reset button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _resetConsent,
                child: const Text('Reset Consent (để test lại)'),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Recordings list
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Recordings:',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_recordings.length} files',
                  style: TextStyle(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            Expanded(
              child: _recordings.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Không có recording nào',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Hãy ghi âm hoặc tạo mock recording',
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    itemCount: _recordings.length,
                    itemBuilder: (context, index) {
                      final recording = _recordings[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(Icons.audiotrack),
                          title: Text(
                            recording.fileName,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Duration: ${_formatDuration(recording.duration)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              Text(
                                'Created: ${_formatDate(recording.createdAt)}',
                                style: const TextStyle(fontSize: 12),
                              ),
                              if (recording.isUploaded)
                                const Text(
                                  '✅ Uploaded',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.green,
                                  ),
                                )
                              else if (recording.isUploading)
                                const Text(
                                  '⏳ Uploading...',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.blue,
                                  ),
                                )
                              else
                                const Text(
                                  '📁 Local only',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.orange,
                                  ),
                                ),
                            ],
                          ),
                          trailing: ElevatedButton(
                            onPressed: _isLoading || recording.isUploaded || recording.isUploading
                              ? null
                              : () => _testUploadWithConsent(recording),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                            child: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Upload',
                                  style: TextStyle(fontSize: 12),
                                ),
                          ),
                        ),
                      );
                    },
                  ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}