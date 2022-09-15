import 'package:cryptography/cryptography.dart';
import 'package:flutter/material.dart';

class ChatMessageEncryptionModel {
  List<int>? cipherText;
  List<int>? nonce;
  List<int>? macBytes;

  ChatMessageEncryptionModel({this.cipherText, this.nonce, this.macBytes});

  ChatMessageEncryptionModel.fromJson(Map<String, dynamic> json) {
    debugPrint('ChatMessageEncryptionModel.fromJson is $json');
    cipherText = (json['cipher_text'] as List).map((e) => e as int).toList();
    nonce = (json['nonce'] as List).map((e) => e as int).toList();
    macBytes = (json['mac_bytes'] as List).map((e) => e as int).toList();
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['cipher_text'] = cipherText;
    data['nonce'] = nonce;
    data['mac_bytes'] = macBytes;
    return data;
  }
}
