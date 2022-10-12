import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static const String _token = 'tokenKey';
  static const String _regToken = 'regTokenKey';
  static const String _regRefreshToken = '_regRefreshToken';
  static const String abhaAddress = 'abhaAddressKey';
  static const String _authTokenHeader = 'authTokenHeader';
  static const String _userData = 'userData';
  static const String _transactionId = 'transactionIdKey';
  static const String _autoLogin = 'autoLoginKey';
  static const String _city = 'cityKey';
  static const String _fcmToken = 'fcmToken';
  static const String _localAuth = 'localAuth';
  static const String _encryptionPrivateKey = 'encryptionPrivateKey';
  static const String _encryptionPublicKey = 'encryptionPublicKey';
  static const String _doctorImages = 'doctorImages';
  static const String bookingOrderIdOne = 'bookingOrderIdOne';
  static const String bookingOrderIdTwo = 'bookingOrderIdTwo';

  static Future<String?> getAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_token);
  }

  static void setAccessToken(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_token, value);
  }

  static Future<String?> getRegAccessToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_regToken);
  }

  static void setRegAccessToken(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_regToken, value);
  }

  static Future<String?> getRegRefreshToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_regRefreshToken);
  }

  static void setRegRefreshToken(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_regRefreshToken, value);
  }

  static Future<String?> getABhaAddress() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(abhaAddress);
  }

  static void setABhaAddress(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(abhaAddress, value);
  }

  static Future<String?> getAuthHeaderToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_authTokenHeader);
  }

  static void setAuthHeaderToken(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_authTokenHeader, value);
  }

  static Future<String?> getUserData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userData);
  }

  static void setUserData(String value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_userData, value);
  }

  static Future<String?> getTransactionId() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_transactionId);
  }

  static void setTransactionId(String? value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_transactionId, value!);
  }

  static Future<bool?> getAutoLoginFlag() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoLogin);
  }

  static void setAutoLoginFlag(bool? value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_autoLogin, value!);
  }

  static Future<String?> getCity() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_city);
  }

  static void setCity(String? value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_city, value!);
  }

  static Future<String?> getFCMToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fcmToken);
  }

  static void setFCMToken(String? value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_fcmToken, value ?? "");
  }

  static Future<bool?> getLocalAuth() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_localAuth);
  }

  static void setLocalAuth(bool? value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(_localAuth, value!);
  }

  static Future<String?> getPrivateKey() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_encryptionPrivateKey);
  }

  static void setPrivateKey(String? value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_encryptionPrivateKey, value ?? "");
  }

  static Future<String?> getPublicKey() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_encryptionPublicKey);
  }

  static void setPublicKey(String? value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(_encryptionPublicKey, value ?? "");
  }

  static Future<List<String>?> getDoctorImages() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_doctorImages);
  }

  static void setDoctorImages(List<String> value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList(_doctorImages, value);
  }
}
