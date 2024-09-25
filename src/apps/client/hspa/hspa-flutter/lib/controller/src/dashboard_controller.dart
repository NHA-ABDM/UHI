import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hspa_app/services/services.dart';

import '../../constants/src/request_urls.dart';
import '../../constants/src/strings.dart';
import '../../model/response/src/appointment_slots_response.dart';
import '../../model/src/doctor_profile.dart';
import '../../settings/src/preferences.dart';

class DashboardController extends GetxController with ExceptionHandler {
  ///ERROR STRING
  var errorString = '';

  Future<void> getProviderAppointmentSlots({required String startDate, required String endDate, required String provider, required String appointType}) async{
    await BaseClient(url: "${RequestUrls.getProviderAppointmentSlots}?startDate=$startDate&endDate=$endDate&limit=100&q=&provider=$provider&appointmentType=$appointType&v=default")
        .get()
        .then(
          (value) async {
        if (value == null) {
        } else {
          String? response = value;
          debugPrint('GET Provider appointment time slots response is $response');

          AppointmentSlots? appointmentSlots =
          AppointmentSlots.fromJson(json.decode(response!));
          if(appointmentSlots.providerAppointmentSlots != null && appointmentSlots.providerAppointmentSlots!.isNotEmpty){
            debugPrint('get provider appointment slots parsed successfully');
          }
        }
      },
    ).catchError(
          (onError) {
        debugPrint('GET Provider appointment time slots error $onError');

        errorString = onError.toString();

        handleError(onError, isShowDialog: true, isShowSnackbar: false);
      },
    );
  }

    Future<void> getProviderAppointments({required String? fromDate, required String? toDate, required String provider, required String appointType, int limit = 100}) async{
      String requestUrl = '${RequestUrls.getProviderAppointments}?limit=$limit&q=&provider=$provider&appointmentType=$appointType&v=default';
      if(fromDate != null && toDate != null) {
        requestUrl += '&fromDate=$fromDate&toDate=$toDate';
      }
      await BaseClient(
          url: requestUrl)
          .get()
          .then(
            (value) async {
          if (value == null) {
          } else {
            String? response = value;
            debugPrint('GET Provider appointments response is $response');

            AppointmentSlots? appointmentSlots =
            AppointmentSlots.fromJson(json.decode(response!));
            if(appointmentSlots.providerAppointmentSlots != null && appointmentSlots.providerAppointmentSlots!.isNotEmpty){
              debugPrint('get provider appointment parsed successfully');
            }
          }
        },
      ).catchError(
            (onError) {
          debugPrint('GET Provider appointments error $onError');

          errorString = onError.toString();

          handleError(onError, isShowDialog: true, isShowSnackbar: false);
        },
      );
    }

    /// Fetch and saves the device firebase token
    Future<void> saveFirebaseToken() async{
    String? deviceToken = await _getDeviceToken();
      DoctorProfile? profile = await DoctorProfile.getSavedProfile();
      String? deviceId = await _getDeviceId();

      debugPrint('Device token is $deviceToken');
      debugPrint('Device Id is $deviceId');
      debugPrint('Hpr Address is ${profile?.hprAddress}');

      if(deviceId != null && profile != null && deviceToken != null){
        String deviceType = Platform.isAndroid ? 'Android' : Platform.isIOS ? 'iOS' : 'Web';
        String hprAddress = profile.hprAddress!;

        await _saveDeviceFirebaseToken(deviceToken : deviceToken, deviceId: deviceId, deviceType: deviceType, hprAddress: hprAddress);
      }
    }

  Future<String?> _getDeviceId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if(Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      debugPrint('androidDeviceInfo ${androidDeviceInfo.toMap()}');
      return androidDeviceInfo.androidId; // unique ID on Android
    }
    return null;
  }

  // Get device token from firebase
  Future<String?> _getDeviceToken() async {
    String? deviceToken = '@';
    try {
      deviceToken = await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint("could not get the token");
      debugPrint(e.toString());
    }
    if (deviceToken != null) {
      debugPrint('---------Device Token---------$deviceToken');
    }
    return deviceToken;
  }

  Future<void> _saveDeviceFirebaseToken(
      {required String deviceToken,
      required String deviceId,
      required String deviceType,
      required String hprAddress}) async {
    Map<String, dynamic> requestBody = {
      'token': deviceToken,
      'deviceId': deviceId,
      'type': deviceType,
      'userName': hprAddress
    };
    debugPrint('Save firebase token request body is $requestBody');
    await BaseClient(
      url: RequestUrls.saveFirebaseToken,
      body: requestBody,
    ).post().then(
      (value) async {
        if (value != null) {
          debugPrint('Save firebase token API response is $value');
        }
      },
    ).catchError(
      (onError) {
        debugPrint('Save firebase token error $onError');
      },
    );
  }

  /// Logout user and delete device firebase token
  Future<void> logoutUser() async{
    DoctorProfile? profile = await DoctorProfile.getSavedProfile();
    String? deviceId = await _getDeviceId();

    if(deviceId != null && profile != null){
      String hprAddress = profile.hprAddress!;
      await _deleteDeviceFirebaseToken(deviceId: deviceId, hprAddress: hprAddress);
    }
  }

  Future<void> _deleteDeviceFirebaseToken({
        required String deviceId,
        required String hprAddress}) async {
    Map<String, dynamic> requestBody = {
      'deviceId': deviceId,
      'userName': hprAddress
    };
    debugPrint('Delete firebase token request body is $requestBody');
    await BaseClient(
      url: RequestUrls.deleteFirebaseToken,
      body: requestBody,
    ).post().then(
          (value) async {
        if (value != null) {
          debugPrint('Delete firebase token API response is $value');
        }
      },
    ).catchError(
          (onError) {
        debugPrint('Delete firebase token API error $onError');
      },
    );
  }


  ///SAVE SHARED KEY API
  Future<void> saveSharedKey() async {
    final encryptionAlgorithm = X25519();
    // Get a public key for our peer.
    final remoteKeyPair = await encryptionAlgorithm.newKeyPair();
    final remotePublicKey = await remoteKeyPair.extractPublicKey();


    DoctorProfile? _profile = await DoctorProfile.getSavedProfile();
    if (_profile != null) {
      Map<String, dynamic> requestBody = {
        'publicKey': remotePublicKey.bytes.toString(),
        'userName': _profile.hprAddress
      };
      debugPrint('Save public key request body is $requestBody');
      debugPrint('Save public key request url is ${RequestUrls.savePublicKey}');
      await BaseClient(
        url: RequestUrls.savePublicKey,
        body: requestBody,
      ).post().then(
            (value) async {
          if (value != null) {
            debugPrint('Save public key API response is $value');
          }
        },
      ).catchError(
            (onError) {
          debugPrint('Save public key API error $onError');
        },
      );
    }
  }///SAVE SHARED KEY API

  Future<void> savePrivatePublicKeys() async {

    String? privateKey = Preferences.getString(
        key: AppStrings.encryptionPrivateKey);
    debugPrint('Shared preference private key is $privateKey');
    if (privateKey == null || privateKey.isEmpty) {
    final encryptionAlgorithm = X25519();
    // Get a public key for our peer.
    final remoteKeyPair = await encryptionAlgorithm.newKeyPair();
    final remotePublicKey = await remoteKeyPair.extractPublicKey();
    String privateKeyBytes =
    (await remoteKeyPair.extractPrivateKeyBytes()).toString();

    DoctorProfile? _profile = await DoctorProfile.getSavedProfile();
    if (_profile != null) {
      Map<String, dynamic> requestBody = {
        'publicKey': remotePublicKey.bytes.toString(),
        'userName': _profile.hprAddress,
        'privateKey': privateKeyBytes
      };
      debugPrint('Save private public key request body is $requestBody');
      debugPrint('Save private public key request url is ${RequestUrls
          .savePrivatePublicKey}');
      await BaseClient(
        url: RequestUrls.savePrivatePublicKey,
        body: requestBody,
      ).post().then(
            (value) async {
          if (value != null) {
            debugPrint('Save private public key API response is $value');
            Map<String, dynamic> responseMap = json.decode(value);
            if(responseMap.containsKey('privateKey')){
              privateKey = responseMap['privateKey'];
              Preferences.saveString(key: AppStrings.encryptionPrivateKey, value: privateKey);
            }
          }
        },
      ).catchError(
            (onError) {
          debugPrint('Save private public key API error $onError');
        },
      );
    }
  }
  }
}