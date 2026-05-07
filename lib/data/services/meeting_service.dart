import 'package:changmeeting/data/models/meeting_model.dart';

class MeetingService {
  static final List<MeetingModel> _hardDataMeetings = [
    MeetingModel(
      id: '1',
      title: 'Cuộc họp ngắn',
      dateTime: DateTime(2024, 11, 4, 9, 31),
      status: 'Hoàn thành',
      type: 'offline',
    ),
    MeetingModel(
      id: '2',
      title: 'Meeting Summary — "Point-to-Voucher Integration & Pilot...',
      dateTime: DateTime(2024, 11, 29, 11, 7),
      status: 'Hoàn thành',
      type: 'google-meet',
      meetingId: 'point-voucher-pilot',
    ),
    MeetingModel(
      id: '3',
      title: 'Meeting on Machine Measurement and Logistics',
      dateTime: DateTime(2024, 11, 29, 9, 54),
      status: 'Hoàn thành',
      type: 'google-meet',
      meetingId: 'machine-logistics',
    ),
    MeetingModel(
      id: '4',
      title: 'Generated Meeting Note',
      dateTime: DateTime(2024, 11, 28, 10, 31),
      status: 'Hoàn thành',
      type: 'offline',
    ),
    MeetingModel(
      id: '5',
      title: 'Thảo luận về dựng cụ vệ sinh nhà cửa',
      dateTime: DateTime(2024, 11, 28, 10, 21),
      status: 'Hoàn thành',
      type: 'offline',
    ),
    MeetingModel(
      id: '6',
      title: 'Generated Meeting Note',
      dateTime: DateTime(2024, 11, 27, 16, 6),
      status: 'Hoàn thành',
      type: 'offline',
    ),
    MeetingModel(
      id: '7',
      title: 'Cuộc họp với team Marketing',
      dateTime: DateTime(2024, 11, 27, 14, 30),
      status: 'Hoàn thành',
      type: 'google-meet',
      meetingId: 'marketing-team',
    ),
    MeetingModel(
      id: '8',
      title: 'Báo cáo dự án Q4 2024',
      dateTime: DateTime(2024, 11, 26, 15, 45),
      status: 'Hoàn thành',
      type: 'offline',
    ),
    MeetingModel(
      id: '9',
      title: 'Thảo luận kế hoạch năm 2025',
      dateTime: DateTime(2024, 11, 26, 10, 15),
      status: 'Hoàn thành',
      type: 'google-meet',
      meetingId: 'plan-2025',
    ),
    MeetingModel(
      id: '10',
      title: 'Training session về AI và Machine Learning',
      dateTime: DateTime(2024, 11, 25, 9, 0),
      status: 'Hoàn thành',
      type: 'offline',
    ),
  ];

  static List<MeetingModel> getAllMeetings() {
    return List.from(_hardDataMeetings);
  }

  static List<MeetingModel> searchMeetings(String query) {
    if (query.isEmpty) return getAllMeetings();

    return _hardDataMeetings.where((meeting) {
      return meeting.title.toLowerCase().contains(query.toLowerCase()) ||
          meeting.meetingId?.toLowerCase().contains(query.toLowerCase()) ==
              true;
    }).toList();
  }
}
