import 'dart:async';
import 'package:flutter/material.dart';
import 'package:changmeeting/recording/services/recording_foreground_service.dart';

/// Singleton service để đồng bộ state ghi âm giữa tab và floating button
class RecordingStateService {
  static final RecordingStateService _instance = RecordingStateService._internal();
  factory RecordingStateService() => _instance;
  RecordingStateService._internal();

  final RecordingForegroundService _foregroundService = RecordingForegroundService();
  
  // Stream controllers
  final StreamController<bool> _isRecordingController = StreamController<bool>.broadcast();
  final StreamController<int> _durationController = StreamController<int>.broadcast();
  final StreamController<bool> _isInRecordingTabController = StreamController<bool>.broadcast();

  // Streams
  Stream<bool> get isRecordingStream => _isRecordingController.stream;
  Stream<int> get durationStream => _durationController.stream;
  Stream<bool> get isInRecordingTabStream => _isInRecordingTabController.stream;

  // Current state
  bool _isRecording = false;
  int _duration = 0;
  bool _isInRecordingTab = false;
  Timer? _updateTimer;

  bool get isRecording => _isRecording;
  int get duration => _duration;
  bool get isInRecordingTab => _isInRecordingTab;

  void initialize() {
    _foregroundService.initialize();
    _setupUpdateTimer();
  }

  void _setupUpdateTimer() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      final newIsRecording = _foregroundService.isRecording;
      final newDuration = _foregroundService.duration;

      if (newIsRecording != _isRecording) {
        _isRecording = newIsRecording;
        _isRecordingController.add(_isRecording);
      }

      if (newDuration != _duration) {
        _duration = newDuration;
        _durationController.add(_duration);
      }
    });
  }

  void setInRecordingTab(bool isInTab) {
    if (_isInRecordingTab != isInTab) {
      _isInRecordingTab = isInTab;
      _isInRecordingTabController.add(_isInRecordingTab);
    }
  }

  Future<bool> startRecording(BuildContext context) async {
    return await _foregroundService.startRecording(context);
  }

  Future<bool> startRecordingSimple(BuildContext context) async {
    return await _foregroundService.startRecordingSimple(context);
  }

  Future<String?> stopRecording() async {
    final result = await _foregroundService.stopRecording();
    
    // Reset timer về 0 sau khi dừng ghi âm thành công
    if (result != null) {
      _duration = 0;
      _durationController.add(_duration);
    }
    
    return result;
  }

  void resetTimer() {
    _duration = 0;
    _durationController.add(_duration);
  }

  void dispose() {
    _updateTimer?.cancel();
    _isRecordingController.close();
    _durationController.close();
    _isInRecordingTabController.close();
    _foregroundService.dispose();
  }
}