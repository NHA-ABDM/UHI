class AccessTokenResponseModel {
  String? accessToken;
  int? expiresIn;
  int? refreshExpiresIn;
  String? refreshToken;
  String? tokenType;

  AccessTokenResponseModel(
      {this.accessToken,
      this.expiresIn,
      this.refreshExpiresIn,
      this.refreshToken,
      this.tokenType});

  AccessTokenResponseModel.fromJson(Map<String, dynamic> json) {
    accessToken = json['accessToken'];
    expiresIn = json['expiresIn'];
    refreshExpiresIn = json['refreshExpiresIn'];
    refreshToken = json['refreshToken'];
    tokenType = json['tokenType'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['accessToken'] = accessToken;
    data['expiresIn'] = expiresIn;
    data['refreshExpiresIn'] = refreshExpiresIn;
    data['refreshToken'] = refreshToken;
    data['tokenType'] = tokenType;
    return data;
  }
}
