import 'package:changmeeting/data/models/meeting_model.dart';
import 'package:changmeeting/data/models/response/paging_model.dart';

class MeetingsResponseModel {
  final List<MeetingModel> items;
  final PagingModel paging;

  MeetingsResponseModel({
    required this.items,
    required this.paging,
  });

  factory MeetingsResponseModel.fromJson(Map<String, dynamic> json) {
    var itemsList = json['items'] as List? ?? [];

    return MeetingsResponseModel(
      items: itemsList.map((item) => MeetingModel.fromJson(item)).toList(),
      paging: PagingModel.fromJson(json['paging'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'paging': paging.toJson(),
    };
  }
}
