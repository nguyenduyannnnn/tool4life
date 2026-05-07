import 'package:flutter/material.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';

/// Overlay widget that displays outside the app
/// This runs in a separate isolate
class RecordingOverlayWidget extends StatefulWidget {
  const RecordingOverlayWidget({super.key});

  @override
  State<RecordingOverlayWidget> createState() => _RecordingOverlayWidgetState();
}

class _RecordingOverlayWidgetState extends State<RecordingOverlayWidget> {
  String _duration = "00:00";
  bool _isRecording = true;

  @override
  void initState() {
    super.initState();
    _listenToMessages();
  }

  void _listenToMessages() {
    // Listen to messages from main app
    FlutterOverlayWindow.overlayListener.listen((event) {
      if (event is Map) {
        if (event['action'] == 'updateDuration') {
          setState(() {
            _duration = event['duration'] ?? "00:00";
          });
        } else if (event['action'] == 'stopRecording') {
          setState(() {
            _isRecording = false;
          });
        }
      }
    });
  }

  void _onTap() {
    // Send message to main app to stop recording
    FlutterOverlayWindow.shareData({'action': 'stopRecording'});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: _onTap,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Timer display
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  _duration,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Recording bubble
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? Colors.red : Colors.grey,
                  boxShadow: _isRecording
                      ? [
                          BoxShadow(
                            color: Colors.red.withValues(alpha: 0.6),
                            blurRadius: 20,
                            spreadRadius: 3,
                          ),
                        ]
                      : [],
                ),
                child: const Icon(
                  Icons.stop,
                  color: Colors.white,
                  size: 32,
                ),
              ),

              const SizedBox(height: 4),

              // Hint text
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Tap để dừng',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
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
