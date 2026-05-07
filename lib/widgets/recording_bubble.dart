import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:changmeeting/common/localization/l10n.dart';
import 'package:changmeeting/recording/services/recording_foreground_service.dart';
import 'package:changmeeting/recording/services/recording_state_service.dart';
import 'package:changmeeting/recording/services/permission_service.dart';
import 'package:changmeeting/recording/services/consent_service.dart';
import 'package:changmeeting/common/utilities.dart';
import 'package:permission_handler/permission_handler.dart';

class RecordingBubble extends StatefulWidget {
  const RecordingBubble({super.key});

  @override
  State<RecordingBubble> createState() => _RecordingBubbleState();
}

class _RecordingBubbleState extends State<RecordingBubble>
    with TickerProviderStateMixin {
  final RecordingForegroundService _foregroundService =
      RecordingForegroundService();
  final RecordingStateService _recordingStateService = RecordingStateService();
  final PermissionService _permissionService = PermissionService();
  final ConsentService _consentService = ConsentService();

  bool _isRecording = false;
  int _duration = 0;
  bool _isInRecordingTab = false;
  Offset _position = const Offset(0, 0);
  bool _isInitialized = false;
  Timer? _updateTimer;

  // Hint animation variables - Đã tắt để tránh lỗi UI
  // late AnimationController _hintAnimationController;
  // late AnimationController _hintPulseController;
  // late Animation<double> _hintOpacityAnimation;
  // late Animation<Offset> _hintSlideAnimation;
  // late Animation<double> _hintPulseAnimation;
  // bool _showHint = false;
  // Timer? _hintTimer;

  @override
  void initState() {
    super.initState();
    _foregroundService.initialize();
    _recordingStateService.initialize();
    // _initializeHintAnimation(); // Đã tắt hint
    _initializePosition();
    _setupStreams(); // Bắt đầu theo dõi state ngay
    // _checkAndShowHint(); // Đã tắt hint
    
    // Debug log
    Utilities.customPrint("🎯 RecordingBubble: Initialized");
  }

  // void _initializeHintAnimation() { // Đã tắt hint
  //   _hintAnimationController = AnimationController(
  //     duration: const Duration(milliseconds: 1200),
  //     vsync: this,
  //   );

  //   _hintPulseController = AnimationController(
  //     duration: const Duration(milliseconds: 2000),
  //     vsync: this,
  //   );

  //   _hintOpacityAnimation = Tween<double>(
  //     begin: 0.0,
  //     end: 1.0,
  //   ).animate(CurvedAnimation(
  //     parent: _hintAnimationController,
  //     curve: const Interval(0.0, 0.6, curve: Curves.easeInOut),
  //   ));

  //   _hintSlideAnimation = Tween<Offset>(
  //     begin: const Offset(0, 0.8),
  //     end: Offset.zero,
  //   ).animate(CurvedAnimation(
  //     parent: _hintAnimationController,
  //     curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
  //   ));

  //   _hintPulseAnimation = Tween<double>(
  //     begin: 1.0,
  //     end: 1.05,
  //   ).animate(CurvedAnimation(
  //     parent: _hintPulseController,
  //     curve: Curves.easeInOut,
  //   ));
  // }

  // void _checkAndShowHint() { // Đã tắt hint để tránh lỗi UI
  //   // Tắt hint để tránh lỗi UI
  //   // Kiểm tra xem đã hiển thị hint chưa
  //   // final hasShownHint = Globals.prefs.getBool(SharedPrefsKey.recordingHintShown);
    
  //   // if (!hasShownHint) {
  //   //   // Delay một chút để đảm bảo UI đã render xong
  //   //   _hintTimer = Timer(const Duration(milliseconds: 1500), () {
  //   //     if (mounted && !_isRecording) {
  //   //       setState(() {
  //   //         _showHint = true;
  //   //       });
  //   //       _hintAnimationController.forward();
          
  //   //       // Bắt đầu pulse animation sau khi slide animation hoàn thành
  //   //       _hintTimer = Timer(const Duration(milliseconds: 1200), () {
  //   //         if (mounted && _showHint) {
  //   //           _hintPulseController.repeat(reverse: true);
  //   //         }
  //   //       });
          
  //   //       // Tự động ẩn hint sau 8 giây
  //   //       _hintTimer = Timer(const Duration(seconds: 8), () {
  //   //         _hideHint();
  //   //       });
  //   //     }
  //   //   });
  //   // }
  // }

  // void _hideHint() { // Đã tắt hint
  //   if (_showHint && mounted) {
  //     _hintPulseController.stop();
  //     _hintAnimationController.reverse().then((_) {
  //       if (mounted) {
  //         setState(() {
  //           _showHint = false;
  //         });
  //       }
  //     });
  //   }
  // }

  void _initializePosition() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final size = MediaQuery.of(context).size;
        final bottomPadding = MediaQuery.of(context).padding.bottom;
        setState(() {
          // Position higher to avoid bottom navigation bar
          _position = Offset(
            size.width - 80, 
            size.height - 200 - bottomPadding
          );
          _isInitialized = true;
        });
      }
    });
  }

  void _setupStreams() {
    // Update UI based on foreground service state
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      
      final newIsRecording = _foregroundService.isRecording;
      final newDuration = _foregroundService.duration;
      final newIsInRecordingTab = _recordingStateService.isInRecordingTab;
      
      if (newIsRecording != _isRecording || 
          newDuration != _duration || 
          newIsInRecordingTab != _isInRecordingTab) {
        setState(() {
          _isRecording = newIsRecording;
          _duration = newDuration;
          _isInRecordingTab = newIsInRecordingTab;
        });
      }
    });
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    // _hintTimer?.cancel(); // Đã tắt hint
    // _hintAnimationController.dispose(); // Đã tắt hint
    // _hintPulseController.dispose(); // Đã tắt hint
    super.dispose();
  }

  Future<void> _onBubbleTap() async {
    Utilities.customPrint('🎯 Recording bubble tapped');
    
    if (!_isRecording) {
      await _handleStartRecording();
    } else {
      await _stopRecording();
    }
  }

  Future<void> _handleStartRecording() async {
    final status = await _permissionService.checkPermission();
    Utilities.customPrint('🎤 Bubble permission status: $status');
    
    if (status.isGranted) {
      // Permission already granted, start recording
      await _startRecording();
    } else if (status.isPermanentlyDenied) {
      // Permanently denied - show settings dialog
      _showSettingsDialog();
    } else {
      // First time or denied - REQUEST PERMISSION DIRECTLY (Apple compliant)
      // NO pre-permission dialog
      await _requestPermissionDirectly();
    }
  }

  /// Request permission directly without pre-permission dialog (Apple compliant)
  Future<void> _requestPermissionDirectly() async {
    Utilities.customPrint('🔄 Bubble requesting permission directly...');
    
    final status = await _permissionService.requestPermission();
    Utilities.customPrint('🎤 Bubble permission result: $status');
    
    if (status.isGranted) {
      await _startRecording();
    } else {
      // Permission denied - show passive message
      _showPermissionDeniedMessage();
    }
  }

  void _showPermissionDeniedMessage() {
    final navigatorContext = Navigator.maybeOf(context)?.context;
    if (navigatorContext == null) return;

    ScaffoldMessenger.of(navigatorContext).showSnackBar(
      const SnackBar(
        content: Text('Quyền truy cập microphone đã bị từ chối. Bạn có thể bật lại trong Cài đặt.'),
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showSettingsDialog() {
    final navigatorContext = Navigator.maybeOf(context)?.context;
    if (navigatorContext == null) return;

    showDialog(
      context: navigatorContext,
      builder: (context) => AlertDialog(
        title: const Text('Cần quyền truy cập Microphone'),
        content: const Text(
          'Quyền truy cập microphone đã bị từ chối vĩnh viễn. Vui lòng bật lại trong Cài đặt.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await openAppSettings();
            },
            child: const Text('Mở Cài đặt'),
          ),
        ],
      ),
    );
  }

  Future<void> _startRecording() async {
    try {
      // Request overlay permission first (Android only)
      if (Platform.isAndroid) {
        final hasOverlayPermission =
            await RecordingForegroundService.requestOverlayPermission();
        if (!hasOverlayPermission) {
          if (mounted) {
            _showOverlayPermissionDialog();
          }
          // Continue anyway, just won't show overlay outside app
        }
      }

      // Start recording using simple method (permission already checked)
      final success = await _recordingStateService.startRecordingSimple(context);
      Utilities.customPrint('🎯 Bubble recording success: $success');
      if (success) {
        _setupStreams();
        if (mounted) {
          Utilities.customPrint('✅ Đã bắt đầu ghi âm từ bubble');
        }
      } else {
        if (mounted) {
          Utilities.customPrint('❌ Không thể bắt đầu ghi âm từ bubble');
        }
      }
    } catch (e) {
      if (mounted) {
        Utilities.customPrint('❌ Lỗi khi ghi âm từ bubble: $e');
      }
    }
  }

  Future<void> _stopRecording() async {
    try {
      // Show confirmation dialog
      final shouldStop = await _showStopRecordingDialog();
      if (!shouldStop) return;

      final navigatorContext = Navigator.maybeOf(context)?.context;

      // Show saving progress if navigator available
      if (navigatorContext != null && mounted) {
        showDialog(
          context: navigatorContext,
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

      // Stop recording using RecordingStateService for consistency
      final filePath = await _recordingStateService.stopRecording();

      if (filePath != null && mounted) {
        // Close progress dialog if it was shown
        if (navigatorContext != null && mounted) {
          Navigator.of(navigatorContext).pop();
        }

        // Show success message
        Utilities.customPrint('✅ File ghi âm đã được lưu: $filePath');
      }
    } catch (e) {
      final navigatorContext = Navigator.maybeOf(context)?.context;
      if (navigatorContext != null && mounted) {
        Navigator.of(navigatorContext).pop(); // Close progress dialog
      }
      Utilities.customPrint('❌ Lỗi khi ghi âm: $e');
    }
  }

  // Removed _showStartRecordingDialog() method since we start recording immediately

  Future<bool> _showStopRecordingDialog() async {
    if (!mounted) return false;
    
    final navigatorContext = Navigator.maybeOf(context)?.context;
    if (navigatorContext == null) {
      // If no navigator available, just return true to proceed
      return true;
    }
    
    // Check if user has consent
    final hasConsent = await _consentService.hasUserConsent();
    
    return await showDialog<bool>(
          context: navigatorContext,
          builder: (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              LangKey.current.attention,
              style: const TextStyle(
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
                child: Text(
                  LangKey.current.close,
                  style: const TextStyle(
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
                    Utilities.customPrint('✅ User granted consent via bubble stop dialog');
                  }
                  Navigator.of(context).pop(true);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1890FF),
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

  void _showOverlayPermissionDialog() {
    if (!mounted) return;
    
    final navigatorContext = Navigator.maybeOf(context)?.context;
    if (navigatorContext == null) return;

    showDialog(
      context: navigatorContext,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.info_outline,
              color: Color(0xFF1890FF),
              size: 28,
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Quyền hiển thị overlay',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Để hiển thị bubble ghi âm ngoài ứng dụng, bạn cần cấp quyền "Hiển thị trên các ứng dụng khác".\n\nỨng dụng sẽ tiếp tục ghi âm nhưng bubble chỉ hiển thị trong app.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Bỏ qua'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await RecordingForegroundService.requestOverlayPermission();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1890FF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Cấp quyền',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _onPanUpdate(DragUpdateDetails details) {
    if (_isRecording) return; // Only allow dragging when not recording

    final size = MediaQuery.of(context).size;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final newPosition = _position + details.delta;

    setState(() {
      _position = Offset(
        newPosition.dx.clamp(16.0, size.width - 80.0),
        newPosition.dy.clamp(100.0, size.height - 150.0 - bottomPadding),
      );
    });
  }

  // Widget _buildHintText() {
  //   return AnimatedBuilder(
  //     animation: _hintAnimationController,
  //     builder: (context, child) {
  //       return FadeTransition(
  //         opacity: _hintOpacityAnimation,
  //         child: SlideTransition(
  //           position: _hintSlideAnimation,
  //           child: AnimatedBuilder(
  //             animation: _hintPulseController,
  //             builder: (context, child) {
  //               return Transform.scale(
  //                 scale: _hintPulseAnimation.value,
  //                 child: Container(
  //                   constraints: const BoxConstraints(
  //                     maxWidth: 200, // Giới hạn width để text không bị lệch
  //                   ),
  //                   margin: const EdgeInsets.only(bottom: 12),
  //                   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
  //                   decoration: BoxDecoration(
  //                     color: const Color(0xFF1E3A8A),
  //                     borderRadius: BorderRadius.circular(16),
  //                     boxShadow: [
  //                       BoxShadow(
  //                         color: Colors.black.withValues(alpha: 0.2),
  //                         blurRadius: 8,
  //                         offset: const Offset(0, 2),
  //                       ),
  //                     ],
  //                   ),
  //                   child: Column(
  //                     mainAxisSize: MainAxisSize.min,
  //                     children: [
  //                       Row(
  //                         mainAxisSize: MainAxisSize.min,
  //                         children: [
  //                           const Icon(
  //                             Icons.lightbulb_outline,
  //                             color: Colors.white,
  //                             size: 14,
  //                           ),
  //                           const SizedBox(width: 6),
  //                           const Text(
  //                             'Gợi ý',
  //                             style: TextStyle(
  //                               color: Colors.white,
  //                               fontSize: 10,
  //                               fontWeight: FontWeight.w600,
  //                             ),
  //                           ),
  //                           const Spacer(),
  //                           GestureDetector(
  //                             onTap: () {
  //                               _hideHint();
  //                               Globals.prefs.setBool(SharedPrefsKey.recordingHintShown, true);
  //                             },
  //                             child: const Icon(
  //                               Icons.close,
  //                               color: Colors.white70,
  //                               size: 12,
  //                             ),
  //                           ),
  //                         ],
  //                       ),
  //                       const SizedBox(height: 6),
  //                       const Text(
  //                         'Sử dụng mèo béo để ghi âm cuộc họp bạn nhé!',
  //                         style: TextStyle(
  //                           color: Colors.white,
  //                           fontSize: 11,
  //                           fontWeight: FontWeight.w400,
  //                           height: 1.3,
  //                         ),
  //                         textAlign: TextAlign.center,
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               );
  //             },
  //           ),
  //         ),
  //       );
  //     },
  //   );
  // }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _isInRecordingTab) {
      // Ẩn floating button khi ở tab ghi âm
      return const SizedBox.shrink();
    }

    Utilities.customPrint("🎯 RecordingBubble: Building at position $_position");

    return Positioned(
      left: _position.dx,
      top: _position.dy,
      child: Material(
        type: MaterialType.transparency,
        child: GestureDetector(
          onTap: _onBubbleTap,
          onPanUpdate: _onPanUpdate,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Hint text - Đã tắt để tránh lỗi UI
              // if (_showHint) _buildHintText(),

              // Timer display when recording
              if (_isRecording)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    _formatDuration(_duration),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),

              const SizedBox(height: 8),

              // Recording bubble
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? Colors.red : const Color(0xFF1E3A8A),
                  boxShadow: _isRecording
                      ? [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.6),
                            blurRadius: 20,
                            spreadRadius: 3,
                          ),
                        ]
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 10,
                            spreadRadius: 2,
                          ),
                        ],
                ),
                child: _isRecording
                    ? const Icon(
                        Icons.stop,
                        color: Colors.white,
                        size: 32,
                      )
                    : ClipOval(
                        child: Image.asset(
                          'assets/image/chang_logo.png',
                          width: 64,
                          height: 64,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 64,
                              height: 64,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Color(0xFF1E3A8A),
                              ),
                              child: const Center(
                                child: Text(
                                  'M',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
