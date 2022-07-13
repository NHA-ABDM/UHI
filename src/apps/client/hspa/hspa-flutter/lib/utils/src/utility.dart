import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt_io.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/asymmetric/api.dart';

class Utility {

  static Transition pageTransition = Transition.rightToLeft;

  static Future<bool> isInternetAvailable () async {
    bool isConnected = false;
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        debugPrint('connected');
        isConnected = true;
      }
    } on SocketException catch (_) {
      debugPrint('not connected');
      isConnected = false;
    }
    return isConnected;
  }

  static String getAppointmentDisplayDate({required DateTime date}){
    String displayDate = '';
    DateFormat format = DateFormat('dd MMM');
    displayDate = format.format(date);
    return displayDate;
  }

  static String getAppointmentDisplayTimeRange({required DateTime startDateTime, required DateTime endDateTime}){
    debugPrint('Date to convert in time is $startDateTime - $endDateTime');
    String displayDate = '';
    DateFormat format = DateFormat('hh:mm aa');
    displayDate = format.format(startDateTime) + ' - ' + format.format(endDateTime);
    return displayDate;
  }

  static String getTimeSlotDisplayTime({required DateTime startDateTime}){
    String displayDate = '';
    DateFormat format = DateFormat('hh:mm aa');
    displayDate = format.format(startDateTime);
    return displayDate;
  }

  static String getAPIRequestDateFormatString(DateTime date) {
    String requestDateString = '';
    requestDateString = DateFormat('yyyy-MM-ddTHH:mm:ss').format(date);
    return requestDateString;
  }

  static Future writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  static Future<Encrypted> encryptString({required String value}) async {
    var pubKey = await rootBundle.load("assets/keys/public.pem");
    String dir = (await getApplicationDocumentsDirectory()).path;

    writeToFile(pubKey, '$dir/public.pem');
    final publicKey =
    await parseKeyFromFile<RSAPublicKey>(File('$dir/public.pem').path);
    final encryptedString = Encrypter(RSA(
      publicKey: publicKey,
    ));
    final encrypted =
    encryptedString.encrypt(value);
    debugPrint('Encrypted string is ${encrypted.base64}');
    return encrypted;
  }

  static double? getRadius({required dynamic context}) {
    double? radius = 60;
    radius = ((MediaQuery.of(context).size.width / 3) / 2);
    debugPrint('Radius is $radius');
    return radius;
  }

  static double? getRightAlignment({required dynamic context}) {
    double? radius = getRadius(context: context);
    radius = radius ?? 0;
    double width = ((MediaQuery.of(context).size.width / 2) - (radius / 1.1));
    debugPrint('Right alignment is $width');
    return width;
  }
}