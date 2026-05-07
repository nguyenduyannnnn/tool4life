class GroupInfo {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final bool isActive;

  GroupInfo({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.isActive,
  });

  factory GroupInfo.fromJson(Map<String, dynamic> json) {
    return GroupInfo(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      createdBy: json['created_by'] ?? '',
      isActive: json['is_active'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'created_by': createdBy,
      'is_active': isActive,
    };
  }
}

class MeetingDetailModel {
  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime meetingDate;
  final int? durationSeconds;
  final String? meetingType;
  final String status;
  final bool isEncrypted;
  final bool isRecurring;
  final String language;
  final String? platform;
  final String? meetingLink;
  final String? organizerEmail;
  final String? organizerName;
  final DateTime? lastJoinedAt;
  final DateTime? createDate;
  final DateTime? updateDate;
  final String? groupId;
  final String? groupName;
  final GroupInfo? groupInfo;

  MeetingDetailModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.meetingDate,
    this.durationSeconds,
    this.meetingType,
    required this.status,
    required this.isEncrypted,
    required this.isRecurring,
    required this.language,
    this.platform,
    this.meetingLink,
    this.organizerEmail,
    this.organizerName,
    this.lastJoinedAt,
    this.createDate,
    this.updateDate,
    this.groupId,
    this.groupName,
    this.groupInfo,
  });

  factory MeetingDetailModel.fromJson(Map<String, dynamic> json) {
    return MeetingDetailModel(
      id: json['id']?.toString() ?? '',
      userId: json['user_id'].toString() ?? '',
      title: json['title'] ?? '',
      description: json['description'],
      meetingDate: DateTime.parse(
          json['meeting_date'] ?? DateTime.now().toIso8601String()),
      durationSeconds: json['duration_seconds'],
      meetingType: json['meeting_type'],
      status: json['status'] ?? '',
      isEncrypted: json['is_encrypted'] ?? false,
      isRecurring: json['is_recurring'] ?? false,
      language: json['language'] ?? '',
      platform: json['platform'],
      meetingLink: json['meeting_link'],
      organizerEmail: json['organizer_email'],
      organizerName: json['organizer_name'],
      lastJoinedAt: json['last_joined_at'] != null
          ? DateTime.parse(json['last_joined_at'])
          : null,
      createDate: json['create_date'] != null
          ? DateTime.parse(json['create_date'])
          : null,
      updateDate: json['update_date'] != null
          ? DateTime.parse(json['update_date'])
          : null,
      groupId: json['group_id'],
      groupName: json['group_name'],
      groupInfo: json['group_info'] != null
          ? GroupInfo.fromJson(json['group_info'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'meeting_date': meetingDate.toIso8601String(),
      'duration_seconds': durationSeconds,
      'meeting_type': meetingType,
      'status': status,
      'is_encrypted': isEncrypted,
      'is_recurring': isRecurring,
      'language': language,
      'platform': platform,
      'meeting_link': meetingLink,
      'organizer_email': organizerEmail,
      'organizer_name': organizerName,
      'last_joined_at': lastJoinedAt?.toIso8601String(),
      'create_date': createDate?.toIso8601String(),
      'update_date': updateDate?.toIso8601String(),
      'group_id': groupId,
      'group_name': groupName,
      'group_info': groupInfo?.toJson(),
    };
  }

  // Helper methods for UI display
  String get displayStatus {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Hoàn thành';
      case 'scheduled':
        return 'Đã lên lịch';
      case 'in_progress':
        return 'Đang diễn ra';
      case 'cancelled':
        return 'Đã hủy';
      case 'failed':
        return 'Thất bại';
      case 'reprocessing':
        return 'Đang xử lý lại';
      default:
        return status;
    }
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

    final weekday = weekdays[meetingDate.weekday % 7];
    final day = meetingDate.day;
    final month = months[meetingDate.month - 1];
    final year = meetingDate.year;

    return '$weekday, $day $month $year';
  }

  String get formattedTime {
    final hour = meetingDate.hour.toString().padLeft(2, '0');
    final minute = meetingDate.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get formattedDuration {
    if (durationSeconds == null) return 'Chưa xác định';

    final hours = durationSeconds! ~/ 3600;
    final minutes = (durationSeconds! % 3600) ~/ 60;
    final seconds = durationSeconds! % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  String get platformDisplayName {
    if (platform == null) return 'Không xác định';

    switch (platform!.toLowerCase()) {
      case 'google':
      case 'google-meet':
        return 'Google Meet';
      case 'zoom':
        return 'Zoom';
      case 'webex':
        return 'Cisco Webex';
      case 'teams':
        return 'Microsoft Teams';
      default:
        return platform!;
    }
  }

  String get languageDisplayName {
    switch (language.toLowerCase()) {
      case 'vi':
        return 'Tiếng Việt';
      case 'en':
        return 'English';
      case 'zh':
        return '中文';
      default:
        return language;
    }
  }
}


