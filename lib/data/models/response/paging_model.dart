class PagingModel {
  final int total;
  final int totalPages;
  final int page;
  final int pageSize;

  PagingModel({
    required this.total,
    required this.totalPages,
    required this.page,
    required this.pageSize,
  });

  factory PagingModel.fromJson(Map<String, dynamic> json) {
    return PagingModel(
      total: json['total'] ?? 0,
      totalPages: json['total_pages'] ?? 0,
      page: json['page'] ?? 1,
      pageSize: json['page_size'] ?? 10,
    );
  }

  bool get hasMorePages => page < totalPages;

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'total_pages': totalPages,
      'page': page,
      'page_size': pageSize,
    };
  }
}


