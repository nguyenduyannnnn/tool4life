class MeetingModel {
  final String id;
  final String title;
  final DateTime dateTime;
  final String status;
  final String type; // 'offline' or 'google-meet'
  final String? meetingId;

  MeetingModel({
    required this.id,
    required this.title,
    required this.dateTime,
    required this.status,
    required this.type,
    this.meetingId,
  });

  factory MeetingModel.fromJson(Map<String, dynamic> json) {
    return MeetingModel(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      dateTime: DateTime.parse(
          json['meeting_date'] ?? DateTime.now().toIso8601String()),
      status: _mapStatus(json['status'] ?? ''),
      type: json['platform'] ?? '',
      meetingId: json['meeting_link'],
    );
  }

  static String _mapStatus(String apiStatus) {
    switch (apiStatus.toLowerCase()) {
      case 'completed':
        return 'Hoàn thành';
      case 'scheduled':
        return 'Đã lên lịch';
      case 'in_progress':
        return 'Đang diễn ra';
      case 'cancelled':
        return 'Đã hủy';
      default:
        return apiStatus;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'meeting_date': dateTime.toIso8601String(),
      'status': status,
      'platform': type,
      'meeting_link': meetingId,
    };
  }

  String get formattedDate {
    final weekdays = [
      'Chủ nhật',
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7'
    ];
    final months = [
      'thg 1',
      'thg 2',
      'thg 3',
      'thg 4',
      'thg 5',
      'thg 6',
      'thg 7',
      'thg 8',
      'thg 9',
      'thg 10',
      'thg 11',
      'thg 12'
    ];

    final weekday = weekdays[dateTime.weekday % 7];
    final day = dateTime.day;
    final month = months[dateTime.month - 1];

    return '$weekday, $day $month';
  }

  String get formattedTime {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
