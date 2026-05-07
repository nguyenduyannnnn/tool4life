class RefreshTokenRequestModel {
  String refreshToken;

  RefreshTokenRequestModel({
    required this.refreshToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'refresh_token': refreshToken,
    };
  }
}


