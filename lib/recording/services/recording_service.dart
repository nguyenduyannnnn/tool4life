import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:record/record.dart';

class RecordingService {
  final AudioRecorder _recorder = AudioRecorder();
  String? _currentPath;
  DateTime? _startTime;
  Timer? _timer;
  int _duration = 0;

  // Streams
  final StreamController<int> _durationController =
      StreamController<int>.broadcast();
  final StreamController<bool> _isRecordingController =
      StreamController<bool>.broadcast();

  Stream<int> get durationStream => _durationController.stream;
  Stream<bool> get isRecordingStream => _isRecordingController.stream;

  bool _isRecording = false;
  bool get isRecording => _isRecording;

  /// Mở Settings app để user có thể cấp quyền thủ công
  /// Note: Permission handling is now done by RecordingForegroundService
  Future<void> openPermissionSettings() async {
    try {
      await openAppSettings();
    } catch (e) {
      print('🎤 Error opening app settings: $e');
    }
  }

  Future<String?> startRecording() async {
    // Permission check is handled by RecordingForegroundService
    // No need to check here to avoid duplicate permission requests
    
    if (isRecording) {
      throw Exception('Already recording');
    }

    try {
      final Directory dir = await getApplicationDocumentsDirectory();
      final String filename = _formatNowForFile();
      final String path =
          File('${dir.path}/meobeo-recording-$filename.m4a').path;

      await _recorder.start(
        RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      _currentPath = path;
      _startTime = DateTime.now();
      _duration = 0;
      _isRecording = true;

      // Start timer
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _duration++;
        _durationController.add(_duration);
      });

      _isRecordingController.add(true);
      return path;
    } catch (e) {
      throw Exception('Failed to start recording: $e');
    }
  }

  Future<String?> stopRecording() async {
    if (!isRecording) {
      return _currentPath;
    }

    try {
      await _recorder.stop();
      _timer?.cancel();
      _isRecording = false;
      _isRecordingController.add(false);

      final String? result = _currentPath;
      _currentPath = null;
      _startTime = null;
      _duration = 0;

      return result;
    } catch (e) {
      throw Exception('Failed to stop recording: $e');
    }
  }

  Future<void> pauseRecording() async {
    if (isRecording) {
      await _recorder.pause();
      _timer?.cancel();
    }
  }

  Future<void> resumeRecording() async {
    if (isRecording) {
      await _recorder.resume();
      _timer = Timer.periodic(const Duration(seconds: 1), (_) {
        _duration++;
        _durationController.add(_duration);
      });
    }
  }

  int get currentDuration => _duration;

  String get currentPath => _currentPath ?? '';

  Future<void> dispose() async {
    if (isRecording) {
      await _recorder.stop();
    }
    _timer?.cancel();
    _currentPath = null;
    _startTime = null;
    _duration = 0;
    _isRecording = false;
    await _durationController.close();
    await _isRecordingController.close();
  }

  String _formatNowForFile() {
    final now = DateTime.now();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${now.year}${two(now.month)}${two(now.day)}_${two(now.hour)}${two(now.minute)}${two(now.second)}';
  }

  String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
