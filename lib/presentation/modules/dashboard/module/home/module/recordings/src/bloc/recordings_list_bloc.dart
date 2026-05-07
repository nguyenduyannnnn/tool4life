import 'dart:async';
import 'package:rxdart/rxdart.dart';
import 'package:changmeeting/recording/services/file_manager_service.dart';
import 'package:changmeeting/recording/models/recording_model.dart';

class RecordingsListBloc {
  final FileManagerService _fileManagerService = FileManagerService();

  // Streams
  final BehaviorSubject<List<RecordingModel>> _recordingsSubject =
      BehaviorSubject<List<RecordingModel>>.seeded([]);
  final BehaviorSubject<bool> _isLoadingSubject =
      BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<String> _errorSubject =
      BehaviorSubject<String>.seeded('');

  StreamSubscription<List<RecordingModel>>? _fileManagerSubscription;

  // Getters
  Stream<List<RecordingModel>> get recordingsStream =>
      _recordingsSubject.stream;
  Stream<bool> get isLoadingStream => _isLoadingSubject.stream;
  Stream<String> get errorStream => _errorSubject.stream;

  List<RecordingModel> get currentRecordings => _recordingsSubject.value;
  bool get isLoading => _isLoadingSubject.value;

  RecordingsListBloc() {
    loadRecordings();
    _listenToFileManagerChanges();
  }

  void _listenToFileManagerChanges() {
    // Listen to real-time updates from FileManagerService
    _fileManagerSubscription = _fileManagerService.recordingsStream.listen((recordings) {
      _recordingsSubject.add(recordings);
    });
  }

  Future<void> loadRecordings() async {
    try {
      _isLoadingSubject.add(true);
      _errorSubject.add('');

      final recordings = await _fileManagerService.getAllRecordings();
      _recordingsSubject.add(recordings);
    } catch (e) {
      _errorSubject.add('Failed to load recordings: $e');
    } finally {
      _isLoadingSubject.add(false);
    }
  }

  Future<void> refreshRecordings() async {
    await loadRecordings();
  }

  Future<bool> deleteRecording(String recordingId) async {
    try {
      _errorSubject.add('');

      final success = await _fileManagerService.deleteRecording(recordingId);

      if (success) {
        // Remove from current list
        final currentRecordings =
            List<RecordingModel>.from(_recordingsSubject.value);
        currentRecordings
            .removeWhere((recording) => recording.id == recordingId);
        _recordingsSubject.add(currentRecordings);
      }

      return success;
    } catch (e) {
      _errorSubject.add('Failed to delete recording: $e');
      return false;
    }
  }

  Future<void> clearAllRecordings() async {
    try {
      _isLoadingSubject.add(true);
      _errorSubject.add('');

      await _fileManagerService.clearAllRecordings();
      _recordingsSubject.add([]);
    } catch (e) {
      _errorSubject.add('Failed to clear recordings: $e');
    } finally {
      _isLoadingSubject.add(false);
    }
  }

  Future<int> getTotalStorageUsed() async {
    try {
      return await _fileManagerService.getTotalStorageUsed();
    } catch (e) {
      return 0;
    }
  }

  String formatStorageSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  void clearError() {
    _errorSubject.add('');
  }

  void dispose() {
    _fileManagerSubscription?.cancel();
    _recordingsSubject.close();
    _isLoadingSubject.close();
    _errorSubject.close();
  }
}
