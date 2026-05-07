import 'package:flutter/material.dart';
import 'package:changmeeting/recording/services/permission_service.dart';
import 'package:changmeeting/recording/services/consent_service.dart';
import 'package:changmeeting/recording/services/upload_service.dart';
import 'package:changmeeting/recording/models/recording_model.dart';
import 'package:changmeeting/common/theme.dart';
import 'package:permission_handler/permission_handler.dart';

/// Example screen demonstrating Apple App Store compliant recording flow
/// 
/// COMPLIANCE FEATURES:
/// 1. NO pre-permission dialog before system permission request
/// 2. Permission requested ONLY after user interaction (tap button)
/// 3. Consent dialog shown BEFORE first upload
/// 4. Passive UI for denied permissions (no aggressive re-prompting)
/// 5. "Open Settings" only for permanently denied
class CompliantRecordingExample extends StatefulWidget {
  const CompliantRecordingExample({super.key});

  @override
  State<CompliantRecordingExample> createState() => _CompliantRecordingExampleState();
}

class _CompliantRecordingExampleState extends State<CompliantRecordingExample> {
  final PermissionService _permissionService = PermissionService();
  final ConsentService _consentService = ConsentService();
  final UploadService _uploadService = UploadService();
  
  PermissionStatus? _permissionStatus;
  bool _hasConsent = false;
  bool _isRecording = false;

  @override
  void initState() {
    super.initState();
    _checkInitialStates();
  }

  Future<void> _checkInitialStates() async {
    final status = await _permissionService.checkPermission();
    final consent = await _consentService.hasUserConsent();
    
    setState(() {
      _permissionStatus = status;
      _hasConsent = consent;
    });
  }

  /// Apple-compliant permission request flow
  Future<void> _handleStartRecording() async {
    // Check current permission status
    final status = await _permissionService.checkPermission();
    
    if (status.isGranted) {
      // Permission already granted - start recording
      _startRecording();
    } else if (status.isPermanentlyDenied) {
      // Show passive UI for permanently denied
      setState(() {
        _permissionStatus = status;
      });
    } else {
      // Request permission directly (NO pre-permission dialog)
      final newStatus = await _permissionService.requestPermission();
      setState(() {
        _permissionStatus = newStatus;
      });
      
      if (newStatus.isGranted) {
        _startRecording();
      }
      // If denied, UI will show passive denied state
    }
  }

  void _startRecording() {
    setState(() {
      _isRecording = true;
    });
    
    // Simulate recording for demo
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        _stopRecording();
      }
    });
  }

  void _stopRecording() {
    setState(() {
      _isRecording = false;
    });
    
    // Simulate upload with consent check
    _simulateUpload();
  }

  Future<void> _simulateUpload() async {
    // Create a mock recording
    final mockRecording = RecordingModel(
      id: 'demo_${DateTime.now().millisecondsSinceEpoch}',
      fileName: 'demo_recording.m4a',
      filePath: '/path/to/demo_recording.m4a',
      duration: 180, // 3 minutes
      createdAt: DateTime.now(),
      fileSize: 1024 * 1024, // 1MB
    );

    // Upload with consent check (will show dialog if needed)
    final success = await _uploadService.uploadRecording(mockRecording, context: context);
    
    if (success) {
      // Update consent status
      final newConsent = await _consentService.hasUserConsent();
      setState(() {
        _hasConsent = newConsent;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Upload successful!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('❌ Upload cancelled or failed'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compliant Recording Demo'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status indicators
            _buildStatusCard('Permission Status', _getPermissionStatusText()),
            const SizedBox(height: 16),
            _buildStatusCard('Upload Consent', _hasConsent ? 'Granted' : 'Not granted'),
            const SizedBox(height: 32),
            
            // Main recording button
            Center(
              child: Column(
                children: [
                  if (_permissionStatus?.isGranted == true) ...[
                    // Recording interface
                    GestureDetector(
                      onTap: _isRecording ? null : _handleStartRecording,
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _isRecording ? Colors.red : AppColors.primary,
                          boxShadow: [
                            BoxShadow(
                              color: (_isRecording ? Colors.red : AppColors.primary)
                                  .withValues(alpha: 0.3),
                              blurRadius: 20,
                              spreadRadius: 5,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isRecording ? Icons.stop : Icons.play_arrow,
                          size: 50,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _isRecording ? 'Recording...' : 'Tap to Record',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else if (_permissionStatus?.isPermanentlyDenied == true) ...[
                    // Permanently denied - show settings button
                    const Icon(Icons.mic_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Microphone access is permanently denied',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _permissionService.openSettings(),
                      child: const Text('Open Settings'),
                    ),
                  ] else if (_permissionStatus?.isDenied == true) ...[
                    // Denied - show passive UI with retry option
                    const Icon(Icons.mic_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    const Text(
                      'Microphone access is denied',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _handleStartRecording,
                      child: const Text('Try Again'),
                    ),
                  ] else ...[
                    // Initial state - show start button
                    ElevatedButton.icon(
                      onPressed: _handleStartRecording,
                      icon: const Icon(Icons.mic),
                      label: const Text('Start Recording'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const Spacer(),
            
            // Compliance info
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✅ App Store Compliant',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.blue,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• No pre-permission dialogs\n'
                    '• Permission requested after user interaction\n'
                    '• Consent dialog before first upload\n'
                    '• Passive UI for denied permissions',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard(String title, String status) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Text(
            status,
            style: TextStyle(
              color: _getStatusColor(status),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getPermissionStatusText() {
    if (_permissionStatus == null) return 'Checking...';
    if (_permissionStatus!.isGranted) return 'Granted';
    if (_permissionStatus!.isPermanentlyDenied) return 'Permanently Denied';
    if (_permissionStatus!.isDenied) return 'Denied';
    return 'Unknown';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'granted':
        return Colors.green;
      case 'denied':
      case 'permanently denied':
        return Colors.red;
      case 'not granted':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}