import 'package:flutter/material.dart';

class GetSharedKeyResponseModel {
  String? userName;
  String? publicKey;

  GetSharedKeyResponseModel({this.userName, this.publicKey});

  GetSharedKeyResponseModel.fromJson(Map<String, dynamic> json) {
    userName = json['userName'];
    publicKey = json['publicKey'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['userName'] = userName;
    data['publicKey'] = publicKey;
    return data;
  }
}
