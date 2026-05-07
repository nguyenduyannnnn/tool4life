class BaseResponseModel<T> {
  int? code;
  String? message;
  T? data;

  BaseResponseModel({
    this.code,
    this.message,
    this.data,
  });

  BaseResponseModel.fromJson(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJsonT) {
    // Support both 'code' and 'error_code' fields
    code = json['code'] ?? json['error_code'];
    message = json['message'];
    data = json['data'] != null ? fromJsonT(json['data']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['code'] = code;
    data['message'] = message;
    data['data'] = data;
    return data;
  }

  bool get isSuccess => code == 0;
}
