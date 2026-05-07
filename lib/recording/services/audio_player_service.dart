import 'dart:async';
import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:changmeeting/common/utilities.dart';

class AudioPlayerService {
  // Singleton instance
  static final AudioPlayerService _instance = AudioPlayerService._internal();
  factory AudioPlayerService() => _instance;
  AudioPlayerService._internal() {
    _setupListeners();
  }

  final AudioPlayer _audioPlayer = AudioPlayer();

  // Current playing state
  String? _currentPlayingId;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  // Streams
  final StreamController<String?> _playingIdController =
      StreamController<String?>.broadcast();
  final StreamController<Duration> _positionController =
      StreamController<Duration>.broadcast();
  final StreamController<Duration> _durationController =
      StreamController<Duration>.broadcast();
  final StreamController<bool> _playingStateController =
      StreamController<bool>.broadcast();

  Stream<String?> get playingIdStream => _playingIdController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<bool> get playingStateStream => _playingStateController.stream;

  String? get currentPlayingId => _currentPlayingId;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  void _setupListeners() {
    // Listen to player state changes
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _isPlaying = state == PlayerState.playing;
      _playingStateController.add(_isPlaying);

      if (state == PlayerState.completed) {
        _handlePlaybackCompleted();
      }
    });

    // Listen to position changes
    _audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
      _positionController.add(position);
    });

    // Listen to duration changes
    _audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      _durationController.add(duration);
    });
  }

  Future<void> play(String recordingId, String filePath) async {
    try {
      Utilities.customPrint("🎵 AUDIO PLAYER: Playing $filePath");

      // If playing a different file, stop current playback
      if (_currentPlayingId != null && _currentPlayingId != recordingId) {
        await stop();
      }

      // Check if file exists
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Audio file not found: $filePath');
      }

      // If same file and paused, resume
      if (_currentPlayingId == recordingId && !_isPlaying) {
        await _audioPlayer.resume();
        _currentPlayingId = recordingId;
        _playingIdController.add(recordingId);
        return;
      }

      // Play new file
      _currentPlayingId = recordingId;
      _playingIdController.add(recordingId);

      await _audioPlayer.play(DeviceFileSource(filePath));

      Utilities.customPrint("🎵 AUDIO PLAYER: Started playing");
    } catch (e) {
      Utilities.customPrint("❌ AUDIO PLAYER: Error - ${e.toString()}");
      _currentPlayingId = null;
      _playingIdController.add(null);
      rethrow;
    }
  }

  Future<void> pause() async {
    try {
      await _audioPlayer.pause();
      Utilities.customPrint("⏸️ AUDIO PLAYER: Paused");
    } catch (e) {
      Utilities.customPrint("❌ AUDIO PLAYER: Pause error - ${e.toString()}");
    }
  }

  Future<void> resume() async {
    try {
      await _audioPlayer.resume();
      Utilities.customPrint("▶️ AUDIO PLAYER: Resumed");
    } catch (e) {
      Utilities.customPrint("❌ AUDIO PLAYER: Resume error - ${e.toString()}");
    }
  }

  Future<void> stop() async {
    try {
      await _audioPlayer.stop();
      _currentPlayingId = null;
      _currentPosition = Duration.zero;
      _playingIdController.add(null);
      _positionController.add(Duration.zero);
      Utilities.customPrint("⏹️ AUDIO PLAYER: Stopped");
    } catch (e) {
      Utilities.customPrint("❌ AUDIO PLAYER: Stop error - ${e.toString()}");
    }
  }

  Future<void> seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
      Utilities.customPrint("⏩ AUDIO PLAYER: Seeked to ${position.inSeconds}s");
    } catch (e) {
      Utilities.customPrint("❌ AUDIO PLAYER: Seek error - ${e.toString()}");
    }
  }

  void _handlePlaybackCompleted() {
    Utilities.customPrint("✅ AUDIO PLAYER: Playback completed");
    _currentPlayingId = null;
    _currentPosition = Duration.zero;
    _playingIdController.add(null);
    _positionController.add(Duration.zero);
  }

  bool isPlayingRecording(String recordingId) {
    return _currentPlayingId == recordingId && _isPlaying;
  }

  bool isPausedRecording(String recordingId) {
    return _currentPlayingId == recordingId && !_isPlaying;
  }
}
