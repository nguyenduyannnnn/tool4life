import 'package:changmeeting/common/utilities.dart';
import 'package:changmeeting/data/models/meeting_model.dart';
import 'package:changmeeting/data/models/meeting_detail_model.dart';
import 'package:changmeeting/data/models/meeting_note_model.dart';
import 'package:changmeeting/data/models/meeting_transcript_model.dart';
import 'package:changmeeting/data/repository/meeting_detail_repository.dart';
import 'package:changmeeting/data/repository/meeting_transcripts_repository.dart';
import 'package:changmeeting/data/repository/simple_meeting_notes_repository.dart';
import 'package:changmeeting/data/services/meeting_download_service.dart';
import 'package:changmeeting/data/services/meeting_share_service.dart';
import 'package:rxdart/rxdart.dart';

class MeetingDetailBloc {
  late MeetingModel meeting;

  // State management streams
  final BehaviorSubject<bool> _isLoadingSubject =
      BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<String?> _errorSubject =
      BehaviorSubject<String?>.seeded(null);
  final BehaviorSubject<MeetingDetailModel?> _meetingDetailSubject =
      BehaviorSubject<MeetingDetailModel?>.seeded(null);

  // Meeting notes specific streams (NEW FLOW)
  final BehaviorSubject<bool> _isLoadingNotesSubject =
      BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<String?> _notesErrorSubject =
      BehaviorSubject<String?>.seeded(null);
  final BehaviorSubject<String?> _summaryMarkdownSubject =
      BehaviorSubject<String?>.seeded(null);

  // OLD notes streams (keep for compatibility)
  final BehaviorSubject<List<MeetingNoteByTranscriptResponse>>
      _meetingNotesSubject =
      BehaviorSubject<List<MeetingNoteByTranscriptResponse>>.seeded([]);
  final BehaviorSubject<int> _selectedNoteVersionIndexSubject =
      BehaviorSubject<int>.seeded(0);

  // Download streams
  final BehaviorSubject<bool> _isDownloadingSubject =
      BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<String?> _downloadMessageSubject =
      BehaviorSubject<String?>.seeded(null);

  // Share streams
  final BehaviorSubject<bool> _isSharingSubject =
      BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<String?> _shareMessageSubject =
      BehaviorSubject<String?>.seeded(null);

  // Meeting transcripts specific streams
  final BehaviorSubject<bool> _isLoadingTranscriptsSubject =
      BehaviorSubject<bool>.seeded(false);
  final BehaviorSubject<String?> _transcriptsErrorSubject =
      BehaviorSubject<String?>.seeded(null);
  final BehaviorSubject<List<MeetingTranscriptsResponse>>
      _meetingTranscriptsSubject =
      BehaviorSubject<List<MeetingTranscriptsResponse>>.seeded([]);
  final BehaviorSubject<int> _selectedTranscriptVersionIndexSubject =
      BehaviorSubject<int>.seeded(0);

  // Stream getters
  Stream<bool> get isLoadingStream => _isLoadingSubject.stream;
  Stream<String?> get errorStream => _errorSubject.stream;
  Stream<MeetingDetailModel?> get meetingDetailStream =>
      _meetingDetailSubject.stream;

  // Meeting notes stream getters
  Stream<bool> get isLoadingNotesStream => _isLoadingNotesSubject.stream;
  Stream<String?> get notesErrorStream => _notesErrorSubject.stream;
  Stream<String?> get summaryMarkdownStream => _summaryMarkdownSubject.stream;
  Stream<List<MeetingNoteByTranscriptResponse>> get meetingNotesStream =>
      _meetingNotesSubject.stream;
  Stream<int> get selectedNoteVersionIndexStream =>
      _selectedNoteVersionIndexSubject.stream;

  // Download stream getters
  Stream<bool> get isDownloadingStream => _isDownloadingSubject.stream;
  Stream<String?> get downloadMessageStream => _downloadMessageSubject.stream;

  // Share stream getters
  Stream<bool> get isSharingStream => _isSharingSubject.stream;
  Stream<String?> get shareMessageStream => _shareMessageSubject.stream;

  // Meeting transcripts stream getters
  Stream<bool> get isLoadingTranscriptsStream =>
      _isLoadingTranscriptsSubject.stream;
  Stream<String?> get transcriptsErrorStream => _transcriptsErrorSubject.stream;
  Stream<List<MeetingTranscriptsResponse>> get meetingTranscriptsStream =>
      _meetingTranscriptsSubject.stream;
  Stream<int> get selectedTranscriptVersionIndexStream =>
      _selectedTranscriptVersionIndexSubject.stream;

  void onInit() {
    // Initialize bloc
    Utilities.customPrint("📄 MEETING DETAIL BLOC: Initializing...");
  }

  void onReady() {
    // Called when screen is ready
  }

  void onResumed() {
    // Called when screen is resumed
  }

  void dispose() {
    _isLoadingSubject.close();
    _errorSubject.close();
    _meetingDetailSubject.close();
    _isLoadingNotesSubject.close();
    _notesErrorSubject.close();
    _summaryMarkdownSubject.close();
    _meetingNotesSubject.close();
    _selectedNoteVersionIndexSubject.close();
    _isDownloadingSubject.close();
    _downloadMessageSubject.close();
    _isSharingSubject.close();
    _shareMessageSubject.close();
    _isLoadingTranscriptsSubject.close();
    _transcriptsErrorSubject.close();
    _meetingTranscriptsSubject.close();
    _selectedTranscriptVersionIndexSubject.close();
  }

  void setMeeting(MeetingModel meetingModel) {
    meeting = meetingModel;
  }

  Future<void> loadMeetingDetail(String meetingId) async {
    if (_isLoadingSubject.value) return; // Prevent multiple simultaneous calls

    try {
      _isLoadingSubject.add(true);
      _errorSubject.add(null);

      Utilities.customPrint(
          "📄 MEETING DETAIL BLOC: Loading detail for meeting ID: $meetingId");

      final repository = MeetingDetailRepository(meetingId: meetingId);
      final result = await repository.getMeetingDetail();

      if (result.isSuccess && result.data != null) {
        _meetingDetailSubject.add(result.data);
        Utilities.customPrint(
            "✅ MEETING DETAIL BLOC: Successfully loaded meeting detail");
      } else {
        final errorMessage =
            result.message ?? 'Không thể tải chi tiết cuộc họp';
        _errorSubject.add(errorMessage);
        Utilities.customPrint(
            "❌ MEETING DETAIL BLOC: Failed to load meeting detail - $errorMessage");
      }
    } catch (e) {
      final errorMessage = 'Lỗi kết nối mạng. Vui lòng thử lại.';
      _errorSubject.add(errorMessage);
      Utilities.customPrint(
          "❌ MEETING DETAIL BLOC: Exception during load - ${e.toString()}");
    } finally {
      _isLoadingSubject.add(false);
    }
  }

  Future<void> retry() async {
    Utilities.customPrint(
        "🔄 MEETING DETAIL BLOC: Retrying load meeting detail");
    await loadMeetingDetail(meeting.id);
  }

  Future<void> loadMeetingNotes(String meetingId) async {
    Utilities.customPrint(
        "🚀 MEETING DETAIL BLOC: loadMeetingNotes called with meetingId: $meetingId");
    
    if (_isLoadingNotesSubject.value) {
      Utilities.customPrint(
          "⚠️ MEETING DETAIL BLOC: Already loading notes, skipping...");
      return; // Prevent multiple simultaneous calls
    }

    try {
      _isLoadingNotesSubject.add(true);
      _notesErrorSubject.add(null);
      _summaryMarkdownSubject.add(null);

      Utilities.customPrint(
          "📋 MEETING DETAIL BLOC: Loading meeting summary for meeting ID: $meetingId");

      // Step 1: Get meeting transcripts to find the latest transcript ID
      final transcriptsRepository = MeetingTranscriptsRepository(meetingId: meetingId);
      final transcriptsResult = await transcriptsRepository.getMeetingTranscripts();

      Utilities.customPrint(
          "📋 Transcripts result - isSuccess: ${transcriptsResult.isSuccess}, code: ${transcriptsResult.code}, message: ${transcriptsResult.message}");

      if (!transcriptsResult.isSuccess || transcriptsResult.data == null) {
        final errorMessage = transcriptsResult.message ?? 'Không thể tải danh sách transcript';
        _notesErrorSubject.add(errorMessage);
        Utilities.customPrint(
            "❌ MEETING DETAIL BLOC: Failed to load transcripts - $errorMessage");
        return;
      }

      final transcripts = transcriptsResult.data!.data;
      Utilities.customPrint(
          "✅ MEETING DETAIL BLOC: Loaded ${transcripts.length} transcripts");

      if (transcripts.isEmpty) {
        _notesErrorSubject.add('Chưa có transcript cuộc họp');
        return;
      }

      // Sort transcripts by date (newest first) or by version if available
      transcripts.sort((a, b) {
        if (a.version != null && b.version != null) {
          return b.version!.compareTo(a.version!); // Descending version
        } else {
          return b.createDate.compareTo(a.createDate); // Newest first
        }
      });

      // Step 2: Get the latest transcript ID (first in sorted list)
      final latestTranscriptId = transcripts.first.id;
      Utilities.customPrint(
          "📋 MEETING DETAIL BLOC: Latest transcript ID: $latestTranscriptId, version: ${transcripts.first.version}");

      // Step 3: Get notes by transcript ID
      final notesRepository = SimpleMeetingNotesRepository(transcriptId: latestTranscriptId);
      final notesResult = await notesRepository.getNotesByTranscriptId();

      Utilities.customPrint(
          "📋 Notes result - isSuccess: ${notesResult.isSuccess}, code: ${notesResult.code}, message: ${notesResult.message}");

      if (!notesResult.isSuccess || notesResult.data == null) {
        final errorMessage = notesResult.message ?? 'Không thể tải ghi chú cuộc họp';
        _notesErrorSubject.add(errorMessage);
        Utilities.customPrint(
            "❌ MEETING DETAIL BLOC: Failed to load notes - $errorMessage");
        return;
      }

      final notes = notesResult.data!.data;
      Utilities.customPrint(
          "✅ MEETING DETAIL BLOC: Loaded ${notes.length} notes");

      if (notes.isEmpty) {
        _notesErrorSubject.add('Chưa có ghi chú cuộc họp');
        return;
      }

      // Step 4: Get markdown text from first note
      final markdownText = notes.first.markdownText;
      Utilities.customPrint(
          "✅ MEETING DETAIL BLOC: Summary markdown loaded, length: ${markdownText.length}");
      Utilities.customPrint(
          "📝 First 200 chars: ${markdownText.substring(0, markdownText.length > 200 ? 200 : markdownText.length)}");

      _summaryMarkdownSubject.add(markdownText);

    } catch (e) {
      const errorMessage = 'Lỗi kết nối mạng. Vui lòng thử lại.';
      _notesErrorSubject.add(errorMessage);
      Utilities.customPrint(
          "❌ MEETING DETAIL BLOC: Exception during notes load - ${e.toString()}");
    } finally {
      _isLoadingNotesSubject.add(false);
    }
  }

  Future<void> retryNotes() async {
    Utilities.customPrint(
        "🔄 MEETING DETAIL BLOC: Retrying load meeting notes");
    await loadMeetingNotes(meeting.id);
  }

  void switchNoteVersion(int versionIndex) {
    final currentNotes = _meetingNotesSubject.value;

    if (versionIndex >= 0 && versionIndex < currentNotes.length) {
      _selectedNoteVersionIndexSubject.add(versionIndex);
      final selectedNote = currentNotes[versionIndex];
      Utilities.customPrint(
          "📋 MEETING DETAIL BLOC: Switched to note version ${selectedNote.version} (index: $versionIndex)");
    } else {
      Utilities.customPrint(
          "❌ MEETING DETAIL BLOC: Invalid version index: $versionIndex (available: ${currentNotes.length})");
    }
  }

  Future<void> loadMeetingTranscripts(String meetingId) async {
    if (_isLoadingTranscriptsSubject.value)
      return; // Prevent multiple simultaneous calls

    try {
      _isLoadingTranscriptsSubject.add(true);
      _transcriptsErrorSubject.add(null);

      Utilities.customPrint(
          "🎙️ MEETING DETAIL BLOC: Loading meeting transcripts for meeting ID: $meetingId");

      final repository = MeetingTranscriptsRepository(meetingId: meetingId);
      final result = await repository.getMeetingTranscripts();

      if (result.isSuccess && result.data != null) {
        final transcripts = result.data!.data;

        // Sort transcripts by date (newest first) or by version if available
        transcripts.sort((a, b) {
          if (a.version != null && b.version != null) {
            return b.version!.compareTo(a.version!); // Descending version
          } else {
            return b.createDate.compareTo(a.createDate); // Newest first
          }
        });

        _meetingTranscriptsSubject.add(transcripts);

        // Reset selected version to first (latest) transcript
        _selectedTranscriptVersionIndexSubject.add(0);

        Utilities.customPrint(
            "✅ MEETING DETAIL BLOC: Successfully loaded ${transcripts.length} meeting transcripts");

        if (transcripts.isNotEmpty) {
          final latestTranscript = transcripts.first;
          Utilities.customPrint(
              "🎙️ MEETING DETAIL BLOC: Latest transcript version: ${latestTranscript.version}, processing status: ${latestTranscript.processingStatus}, content length: ${latestTranscript.textContent.length}");
        }
      } else {
        final errorMessage = result.message ?? 'Không thể tải bản ghi cuộc họp';
        _transcriptsErrorSubject.add(errorMessage);
        Utilities.customPrint(
            "❌ MEETING DETAIL BLOC: Failed to load meeting transcripts - $errorMessage");
      }
    } catch (e) {
      final errorMessage = 'Lỗi kết nối mạng. Vui lòng thử lại.';
      _transcriptsErrorSubject.add(errorMessage);
      Utilities.customPrint(
          "❌ MEETING DETAIL BLOC: Exception during transcripts load - ${e.toString()}");
    } finally {
      _isLoadingTranscriptsSubject.add(false);
    }
  }

  Future<void> retryTranscripts() async {
    Utilities.customPrint(
        "🔄 MEETING DETAIL BLOC: Retrying load meeting transcripts");
    await loadMeetingTranscripts(meeting.id);
  }

  void switchTranscriptVersion(int versionIndex) {
    final currentTranscripts = _meetingTranscriptsSubject.value;

    if (versionIndex >= 0 && versionIndex < currentTranscripts.length) {
      _selectedTranscriptVersionIndexSubject.add(versionIndex);
      final selectedTranscript = currentTranscripts[versionIndex];
      Utilities.customPrint(
          "🎙️ MEETING DETAIL BLOC: Switched to transcript version ${selectedTranscript.version} (index: $versionIndex)");
    } else {
      Utilities.customPrint(
          "❌ MEETING DETAIL BLOC: Invalid transcript version index: $versionIndex (available: ${currentTranscripts.length})");
    }
  }

  // Helper methods for UI
  MeetingNoteByTranscriptResponse? get currentSelectedNote {
    final notes = _meetingNotesSubject.value;
    final selectedIndex = _selectedNoteVersionIndexSubject.value;

    if (notes.isNotEmpty &&
        selectedIndex >= 0 &&
        selectedIndex < notes.length) {
      return notes[selectedIndex];
    }
    return null;
  }

  List<String> get versionDropdownItems {
    final notes = _meetingNotesSubject.value;
    return MeetingNoteByTranscriptResponse.generateVersionDropdownItems(notes);
  }

  bool get hasNotes {
    return _meetingNotesSubject.value.isNotEmpty;
  }

  String? get currentNoteMarkdownContent {
    return currentSelectedNote?.markdownContent;
  }

  // Helper methods for transcript UI
  MeetingTranscriptsResponse? get currentSelectedTranscript {
    final transcripts = _meetingTranscriptsSubject.value;
    final selectedIndex = _selectedTranscriptVersionIndexSubject.value;

    if (transcripts.isNotEmpty &&
        selectedIndex >= 0 &&
        selectedIndex < transcripts.length) {
      return transcripts[selectedIndex];
    }
    return null;
  }

  List<String> get transcriptVersionDropdownItems {
    final transcripts = _meetingTranscriptsSubject.value;
    return MeetingTranscriptsResponse.generateVersionDropdownItems(transcripts);
  }

  bool get hasTranscripts {
    return _meetingTranscriptsSubject.value.isNotEmpty;
  }

  List<TranscriptSegment> get currentTranscriptSegments {
    final transcript = currentSelectedTranscript;
    return transcript?.parseTranscriptSegments() ?? [];
  }

  bool get currentTranscriptIsProcessing {
    final transcript = currentSelectedTranscript;
    return transcript?.isProcessing ?? false;
  }

  bool get currentTranscriptIsReady {
    final transcript = currentSelectedTranscript;
    return transcript?.isReady ?? false;
  }

  bool get currentTranscriptIsFailed {
    final transcript = currentSelectedTranscript;
    return transcript?.isFailed ?? false;
  }

  void onTabChanged(int index) {
    Utilities.customPrint(
        '📄 MEETING DETAIL BLOC: Tab changed to index: $index');
  }

  void onVersionDropdownChanged(String version) {
    Utilities.customPrint(
        '📄 MEETING DETAIL BLOC: Version changed to: $version');
  }

  void onMoreOptions() {
    Utilities.customPrint('📄 MEETING DETAIL BLOC: More options clicked');
  }

  // Refresh methods for pull-to-refresh
  Future<void> refreshMeetingDetail() async {
    Utilities.customPrint('🔄 MEETING DETAIL BLOC: Refreshing meeting detail');
    await loadMeetingDetail(meeting.id);
  }

  Future<void> refreshMeetingNotes() async {
    Utilities.customPrint('🔄 MEETING DETAIL BLOC: Refreshing meeting notes');
    await loadMeetingNotes(meeting.id);
  }

  Future<void> refreshMeetingTranscripts() async {
    Utilities.customPrint('🔄 MEETING DETAIL BLOC: Refreshing meeting transcripts');
    await loadMeetingTranscripts(meeting.id);
  }

  Future<void> refreshCurrentTab(int tabIndex) async {
    Utilities.customPrint('🔄 MEETING DETAIL BLOC: Refreshing tab $tabIndex');
    
    // Always refresh meeting detail
    await refreshMeetingDetail();
    
    // Refresh tab-specific data
    if (tabIndex == 0) {
      // Summary tab
      await refreshMeetingNotes();
    } else if (tabIndex == 1) {
      // Transcript tab
      await refreshMeetingTranscripts();
    }
  }

  // Download meeting notes
  Future<void> downloadMeetingNotes() async {
    if (_isDownloadingSubject.value) {
      Utilities.customPrint('⚠️ Already downloading, skipping...');
      return;
    }

    try {
      _isDownloadingSubject.add(true);
      _downloadMessageSubject.add(null);

      Utilities.customPrint('📥 Starting download meeting notes for ID: ${meeting.id}');

      final result = await MeetingDownloadService.downloadMeetingNotes(meeting.id);

      if (result.success) {
        _downloadMessageSubject.add('Tải file thành công: ${result.fileName}');
        Utilities.customPrint('✅ Download successful: ${result.filePath}');
      } else {
        _downloadMessageSubject.add(result.message);
        Utilities.customPrint('❌ Download failed: ${result.message}');
      }
    } catch (e) {
      const errorMessage = 'Lỗi tải file. Vui lòng thử lại.';
      _downloadMessageSubject.add(errorMessage);
      Utilities.customPrint('❌ Download exception: ${e.toString()}');
    } finally {
      _isDownloadingSubject.add(false);
    }
  }

  // Share meeting notes
  Future<void> shareMeetingNotes() async {
    if (_isSharingSubject.value) {
      Utilities.customPrint('⚠️ Already sharing, skipping...');
      return;
    }

    try {
      _isSharingSubject.add(true);
      _shareMessageSubject.add(null);

      Utilities.customPrint('📤 Starting share meeting notes for ID: ${meeting.id}');

      final result = await MeetingShareService.shareMeetingNotes(meeting.id, meeting.title);

      if (result.success) {
        _shareMessageSubject.add('Chia sẻ thành công');
        Utilities.customPrint('✅ Share successful');
      } else {
        _shareMessageSubject.add(result.message);
        Utilities.customPrint('❌ Share failed: ${result.message}');
      }
    } catch (e) {
      const errorMessage = 'Lỗi chia sẻ file. Vui lòng thử lại.';
      _shareMessageSubject.add(errorMessage);
      Utilities.customPrint('❌ Share exception: ${e.toString()}');
    } finally {
      _isSharingSubject.add(false);
    }
  }
}
