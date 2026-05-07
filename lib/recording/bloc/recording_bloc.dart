import 'dart:async';
import 'package:rxdart/rxdart.dart';
import '../../common/utils/custom_permission_request.dart';
import '../services/recording_service.dart';
import '../services/file_manager_service.dart';
import '../models/recording_model.dart';
import 'package:permission_handler/permission_handler.dart';

enum RecordingState {
  idle,
  recording,
  saving,
  error,
}

class RecordingBloc {
  final RecordingService _recordingService = RecordingService();
  final FileManagerService _fileManagerService = FileManagerService();

  // Streams
  final BehaviorSubject<RecordingState> _stateSubject =
      BehaviorSubject<RecordingState>.seeded(RecordingState.idle);
  final BehaviorSubject<int> _durationSubject = BehaviorSubject<int>.seeded(0);
  final BehaviorSubject<bool> _isRecordingSubject =
      BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<String> _errorSubject =
      BehaviorSubject<String>.seeded('');

  // Subscriptions
  StreamSubscription<int>? _durationSubscription;
  StreamSubscription<bool>? _recordingSubscription;

  // Getters
  Stream<RecordingState> get stateStream => _stateSubject.stream;
  Stream<int> get durationStream => _durationSubject.stream;
  Stream<bool> get isRecordingStream => _isRecordingSubject.stream;
  Stream<String> get errorStream => _errorSubject.stream;

  RecordingState get currentState => _stateSubject.value;
  int get currentDuration => _durationSubject.value;
  bool get isRecording => _isRecordingSubject.value;

  RecordingBloc() {
    _setupStreams();
  }

  void _setupStreams() {
    _durationSubscription = _recordingService.durationStream.listen((duration) {
      _durationSubject.add(duration);
    });

    _recordingSubscription =
        _recordingService.isRecordingStream.listen((isRecording) {
      _isRecordingSubject.add(isRecording);
      if (isRecording) {
        _stateSubject.add(RecordingState.recording);
      } else if (_stateSubject.value == RecordingState.recording) {
        _stateSubject.add(RecordingState.idle);
      }
    });
  }

  Future<bool> checkMicrophonePermission() async {
    try {
      return await CustomPermissionRequest.check(Permission.microphone);
    } catch (e) {
      _errorSubject.add('Permission check failed: $e');
      return false;
    }
  }

  Future<void> openPermissionSettings() async {
    try {
      await _recordingService.openPermissionSettings();
    } catch (e) {
      _errorSubject.add('Failed to open permission settings: $e');
    }
  }

  Future<void> startRecording() async {
    try {
      _stateSubject.add(RecordingState.recording);
      _errorSubject.add('');

      await _recordingService.startRecording();
    } catch (e) {
      _stateSubject.add(RecordingState.error);
      _errorSubject.add('Failed to start recording: $e');
    }
  }

  Future<void> stopRecording() async {
    try {
      _stateSubject.add(RecordingState.saving);
      _errorSubject.add('');

      final filePath = await _recordingService.stopRecording();

      if (filePath != null) {
        await _saveRecording(filePath);
      }

      _stateSubject.add(RecordingState.idle);
    } catch (e) {
      _stateSubject.add(RecordingState.error);
      _errorSubject.add('Failed to stop recording: $e');
    }
  }

  Future<void> _saveRecording(String filePath) async {
    try {
      // Generate filename and move file
      final fileName = _fileManagerService.generateFileName();
      final finalPath = await _fileManagerService.moveFileToRecordingsDirectory(
          filePath, fileName);

      // Get file size
      final fileSize = await _fileManagerService.getFileSize(finalPath);

      // Create recording model
      final recording = RecordingModel(
        id: _fileManagerService.generateRecordingId(),
        fileName: fileName,
        filePath: finalPath,
        duration: _durationSubject.value,
        createdAt: DateTime.now(),
        fileSize: fileSize,
      );

      // Save metadata
      await _fileManagerService.saveRecordingMetadata(recording);
    } catch (e) {
      throw Exception('Failed to save recording: $e');
    }
  }

  Future<void> pauseRecording() async {
    try {
      await _recordingService.pauseRecording();
    } catch (e) {
      _errorSubject.add('Failed to pause recording: $e');
    }
  }

  Future<void> resumeRecording() async {
    try {
      await _recordingService.resumeRecording();
    } catch (e) {
      _errorSubject.add('Failed to resume recording: $e');
    }
  }

  String formatDuration(int seconds) {
    return _recordingService.formatDuration(seconds);
  }

  void clearError() {
    _errorSubject.add('');
  }

  void resetState() {
    _stateSubject.add(RecordingState.idle);
    _durationSubject.add(0);
    _isRecordingSubject.add(false);
    _errorSubject.add('');
  }

  void dispose() {
    _durationSubscription?.cancel();
    _recordingSubscription?.cancel();
    _recordingService.dispose();
    _stateSubject.close();
    _durationSubject.close();
    _isRecordingSubject.close();
    _errorSubject.close();
  }
}
