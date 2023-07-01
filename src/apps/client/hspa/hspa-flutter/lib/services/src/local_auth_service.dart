import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

class LocalAuthService {
  static final _auth = LocalAuthentication();

  static Future<bool> hasBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } on PlatformException {
      return false;
    }
  }

  static Future<bool> authenticate() async {
    final isBiometricsAvailable = await hasBiometrics();

    if (!isBiometricsAvailable) return false;

    try {
      return await _auth.authenticate(
        localizedReason:
            "Please scan your Fingerprint or Face to authenticate.",
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
    } on PlatformException catch (e) {
      debugPrint('Local auth exception is ${e.toString()}');
      return false;
    }
  }

  static Future<void> cancelAuthentication() async {
    try {
      _auth.stopAuthentication();
    } on PlatformException {
      debugPrint('Local auth exception');
    }
  }
}
