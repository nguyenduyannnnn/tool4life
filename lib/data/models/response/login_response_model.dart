class LoginResponseModel {
  String? id;
  String? email;
  String? role;
  String? name;
  String? username;
  bool? confirmed;
  String? createDate;
  String? updateDate;
  String? profilePicture;
  String? firstName;
  String? lastName;
  String? locale;
  String? oauthId;
  String? oauthProvider;
  String? ssoProvider;
  String? ssoId;
  String? accessToken;
  String? refreshToken;

  LoginResponseModel({
    this.id,
    this.email,
    this.role,
    this.name,
    this.username,
    this.confirmed,
    this.createDate,
    this.updateDate,
    this.profilePicture,
    this.firstName,
    this.lastName,
    this.locale,
    this.oauthId,
    this.oauthProvider,
    this.ssoProvider,
    this.ssoId,
    this.accessToken,
    this.refreshToken,
  });

  LoginResponseModel.fromJson(Map<String, dynamic> json) {
    id = json['id']?.toString();
    email = json['email'];
    role = json['role'];
    name = json['name'];
    username = json['username'];
    confirmed = json['confirmed'];
    createDate = json['create_date'];
    updateDate = json['update_date'];
    profilePicture = json['profile_picture'];
    firstName = json['first_name'];
    lastName = json['last_name'];
    locale = json['locale'];
    oauthId = json['oauth_id'];
    oauthProvider = json['oauth_provider'];
    ssoProvider = json['sso_provider'];
    ssoId = json['sso_id'];
    accessToken = json['access_token'];
    refreshToken = json['refresh_token'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['email'] = email;
    data['role'] = role;
    data['name'] = name;
    data['username'] = username;
    data['confirmed'] = confirmed;
    data['create_date'] = createDate;
    data['update_date'] = updateDate;
    data['profile_picture'] = profilePicture;
    data['first_name'] = firstName;
    data['last_name'] = lastName;
    data['locale'] = locale;
    data['oauth_id'] = oauthId;
    data['oauth_provider'] = oauthProvider;
    data['sso_provider'] = ssoProvider;
    data['sso_id'] = ssoId;
    data['access_token'] = accessToken;
    data['refresh_token'] = refreshToken;
    return data;
  }
}
