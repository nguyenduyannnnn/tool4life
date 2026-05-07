import 'package:flutter/material.dart';
import 'package:changmeeting/common/theme.dart';
import 'package:changmeeting/recording/services/recording_state_service.dart';
import 'package:changmeeting/recording/services/permission_service.dart';
import 'package:changmeeting/recording/services/consent_service.dart';
import 'package:changmeeting/recording/widgets/permission_denied_widget.dart';
import 'package:changmeeting/recording/test/consent_test_screen.dart';
import 'package:changmeeting/recording/test/final_compliance_test.dart';
import 'package:changmeeting/recording/test/manual_upload_test.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordingScreen extends StatefulWidget {
  final Function(int)? onTabChange; // Callback để chuyển tab
  
  const RecordingScreen({super.key, this.onTabChange});

  @override
  State<RecordingScreen> createState() => _RecordingScreenState();
}

class _RecordingScreenState extends State<RecordingScreen>
    with TickerProviderStateMixin {
  final RecordingStateService _recordingStateService = RecordingStateService();
  final PermissionService _permissionService = PermissionService();
  final ConsentService _consentService = ConsentService();
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  // Permission flow states - NO PRE-PERMISSION SCREEN (Apple compliant)
  PermissionStatus? _permissionStatus;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _recordingStateService.initialize();
    // Đánh dấu đang ở tab ghi âm
    _recordingStateService.setInRecordingTab(true);
    
    // Check initial permission status
    _checkPermissionStatus();
    
    // Đồng bộ animation với state hiện tại
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_recordingStateService.isRecording) {
        _pulseController.repeat(reverse: true);
      }
    });
  }

  Future<void> _checkPermissionStatus() async {
    Utilities.customPrint('🔍 Checking initial permission status...');
    final status = await _permissionService.checkPermission();
    Utilities.customPrint('📋 Initial permission status: $status');
    if (mounted) {
      setState(() {
        _permissionStatus = status;
      });
    }
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    // Đánh dấu không còn ở tab ghi âm
    _recordingStateService.setInRecordingTab(false);
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleRecording() async {
    Utilities.customPrint('🎤 _toggleRecording called');
    try {
      if (_recordingStateService.isRecording) {
        Utilities.customPrint('🛑 Currently recording, showing stop dialog');
        // Show confirmation dialog
        final shouldStop = await _showStopRecordingDialog();
        if (!shouldStop) return;

        // Show saving progress
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => const AlertDialog(
              content: Row(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Đang lưu file ghi âm...'),
                ],
              ),
            ),
          );
        }

        // Stop recording
        final filePath = await _recordingStateService.stopRecording();

        // Close progress dialog
        if (mounted) {
          Navigator.of(context).pop();
        }

        if (filePath != null && mounted) {
          // Show success message
          Utilities.customPrint('✅ File ghi âm đã được lưu: $filePath');
          
          // Reset timer về 0
          _recordingStateService.resetTimer();
          
          // Chuyển về tab "Tập tin" (index 2)
          if (widget.onTabChange != null) {
            widget.onTabChange!(2);
          }
        }
      } else {
        Utilities.customPrint('▶️ Not recording, starting permission flow');
        // Handle permission flow before starting recording
        await _handleStartRecording();
      }
    } catch (e) {
      // Close progress dialog if it's open
      if (mounted && Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }
      
      // Reset timer nếu có lỗi khi dừng ghi âm
      if (_recordingStateService.isRecording) {
        _recordingStateService.resetTimer();
      }
      
      Utilities.customPrint('🎤 Recording error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi ghi âm: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle start recording with Apple-compliant permission flow
  /// NO pre-permission dialog - directly request permission after user interaction
  Future<void> _handleStartRecording() async {
    final status = await _permissionService.checkPermission();
    Utilities.customPrint('🎤 Current permission status: $status');
    
    if (status.isGranted) {
      // Permission already granted, start recording
      Utilities.customPrint('✅ Permission already granted, starting recording');
      await _startRecording();
    } else if (status.isPermanentlyDenied) {
      // Permanently denied - update status to show denied widget
      Utilities.customPrint('❌ Permission permanently denied');
      setState(() {
        _permissionStatus = status;
      });
    } else {
      // First time (undetermined) or denied - DIRECTLY request permission
      // NO pre-permission screen (Apple compliant)
      Utilities.customPrint('🔄 Requesting permission directly after user interaction');
      await _requestPermissionDirectly();
    }
  }

  /// Request permission directly without pre-permission screen (Apple compliant)
  Future<void> _requestPermissionDirectly() async {
    Utilities.customPrint('🔄 Requesting microphone permission directly...');
    
    // Request permission immediately after user interaction
    final status = await _permissionService.requestPermission();
    Utilities.customPrint('🎤 Permission request result: $status');
    
    // Update permission status
    setState(() {
      _permissionStatus = status;
    });

    if (status.isGranted) {
      // Permission granted, start recording
      Utilities.customPrint('✅ Permission granted, starting recording');
      await _startRecording();
    } else {
      Utilities.customPrint('❌ Permission denied, showing passive denied UI');
    }
    // If denied, the UI will show the appropriate denied state
    // NO dialogs asking user to reconsider (Apple compliant)
  }

  Future<void> _startRecording() async {
    final success = await _recordingStateService.startRecordingSimple(context);
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Không thể bắt đầu ghi âm'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _showStopRecordingDialog() async {
    if (!mounted) return false;
    
    // Check if user has consent
    final hasConsent = await _consentService.hasUserConsent();
    
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Xác nhận dừng ghi âm',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bạn chắc chắn muốn dừng ghi âm?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (!hasConsent) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue, size: 16),
                            SizedBox(width: 6),
                            Text(
                              'Thông báo xử lý dữ liệu',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Bản ghi âm của bạn sẽ được tải lên máy chủ của Chang Meeting để chuyển đổi thành văn bản và tạo ghi chú cuộc họp.\n\n'
                          'Dữ liệu được xử lý hoàn toàn trên hạ tầng của Chang Meeting bằng các mô hình AI nội bộ và không được chia sẻ với bất kỳ bên thứ ba nào.',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Bạn có đồng ý tiếp tục không?',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
                child: const Text(
                  'Hủy',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  // If no consent, grant it when user agrees
                  if (!hasConsent) {
                    await _consentService.grantConsent();
                    Utilities.customPrint('✅ User granted consent via stop dialog');
                  }
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  hasConsent ? 'Dừng ghi âm' : 'Đồng ý & Dừng ghi âm',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ) ??
        false;
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    // NO PRE-PERMISSION SCREEN - Apple compliant
    // Permission is requested directly when user taps "Start Recording"

    // Show permission denied widget
    if (_permissionStatus != null && 
        (_permissionStatus!.isDenied || _permissionStatus!.isPermanentlyDenied)) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: const Text(
            'Ghi Âm',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          // actions: [
          //   // Manual upload test button
          //   IconButton(
          //     icon: const Icon(Icons.upload, color: Colors.purple),
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (context) => const ManualUploadTest()),
          //       );
          //     },
          //   ),
          //   // Final compliance test button
          //   IconButton(
          //     icon: const Icon(Icons.verified, color: Colors.green),
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (context) => const FinalComplianceTest()),
          //       );
          //     },
          //   ),
          //   // Consent test button
          //   IconButton(
          //     icon: const Icon(Icons.security, color: Colors.blue),
          //     onPressed: () {
          //       Navigator.push(
          //         context,
          //         MaterialPageRoute(builder: (context) => const ConsentTestScreen()),
          //       );
          //     },
          //   ),
          // ],
        ),
        body: PermissionDeniedWidget(
          isPermanentlyDenied: _permissionStatus!.isPermanentlyDenied,
          onRetry: _permissionStatus!.isDenied ? () async {
            Utilities.customPrint('🔄 Retry button tapped, requesting permission directly');
            // Request permission directly instead of showing pre-permission screen
            await _requestPermissionDirectly();
          } : null,
        ),
      );
    }

    // Show main recording interface
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Ghi Âm',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: StreamBuilder<bool>(
        stream: _recordingStateService.isRecordingStream,
        builder: (context, isRecordingSnapshot) {
          return StreamBuilder<int>(
            stream: _recordingStateService.durationStream,
            builder: (context, durationSnapshot) {
              final isRecording = isRecordingSnapshot.data ?? _recordingStateService.isRecording;
              final duration = durationSnapshot.data ?? _recordingStateService.duration;

              // Đồng bộ animation với state
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (isRecording && !_pulseController.isAnimating) {
                  _pulseController.repeat(reverse: true);
                } else if (!isRecording && _pulseController.isAnimating) {
                  _pulseController.stop();
                  _pulseController.reset();
                }
              });

              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Status text
                    Text(
                      isRecording ? 'Đang ghi âm...' : 'Nhấn để bắt đầu ghi âm',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: isRecording ? AppColors.primary : Colors.grey[600],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Duration display
                    if (isRecording || duration > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _formatDuration(duration),
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'monospace',
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 60),
                    
                    // Recording button
                    GestureDetector(
                      onTap: _toggleRecording,
                      child: AnimatedBuilder(
                        animation: _pulseAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: isRecording ? _pulseAnimation.value : 1.0,
                            child: Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isRecording ? Colors.red : AppColors.primary,
                                boxShadow: [
                                  BoxShadow(
                                    color: (isRecording ? Colors.red : AppColors.primary)
                                        .withValues(alpha: 0.3),
                                    blurRadius: 20,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Icon(
                                isRecording ? Icons.stop : Icons.play_arrow,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}