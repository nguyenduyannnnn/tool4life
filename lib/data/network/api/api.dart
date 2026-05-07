import 'package:changmeeting/common/globals.dart';

class API {
  static String get server => Globals.config.server ?? "";
  static int get successCode => 0;

  // Authentication
  static login() => "api/v1/auth/login";
  static azureDirectLogin() => "api/v1/auth/azure/direct-login";
  static logout() => "api/v1/auth/logout";
  static refreshToken() => "api/v1/auth/refresh";

  // User Management
  static deleteUser(String userId) => "api/v1/users/$userId";

  // Meetings
  static getMeetings() => "api/v1/meetings/";
  static getMeetingDetail(String meetingId) => "api/v1/meetings/$meetingId";
  static deleteMeeting(String meetingId) => "api/v1/meetings/$meetingId";

  // Meeting Notes
  static getMeetingNotesByTranscript(String transcriptId) =>
      "api/v1/notes/transcript/$transcriptId?include_items=true";
  
  // Meeting Files
  static getMeetingFiles(String meetingId) =>
      "api/v1/meeting-files/meeting/$meetingId";
  
  // Get notes by transcript ID (for summary tab)
  static getNotesByTranscriptId(String transcriptId) =>
      "api/v1/notes/transcript/$transcriptId";

  // Meeting Transcripts
  static getMeetingTranscripts(String meetingId) =>
      "api/v1/transcripts/meeting/$meetingId";
  
  // Download meeting notes
  static downloadMeetingNotes(String meetingId) =>
      "api/v1/meetings/$meetingId/notes/download";
  
  // Upload audio recording
  static uploadAudioRecording() => "api/v1/transcripts/audio";
}
