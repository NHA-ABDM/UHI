import 'dart:convert';
import 'dart:io';

import 'package:cryptography/cryptography.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt_io.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get_navigation/src/routes/transitions_type.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pointycastle/asymmetric/api.dart';

import '../../model/src/chat_message_encryption_model.dart';

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

  static String getChatDisplayDateTime({required DateTime startDateTime}){

    DateTime now = DateTime.now();
    DateTime justNow = DateTime.now().subtract(const Duration(minutes: 1));
    DateTime localDateTime = startDateTime.toLocal();

    if (!localDateTime.difference(justNow).isNegative) {
      return 'Just now';
    }

    String roughTimeString = DateFormat('jm').format(startDateTime);
    if (localDateTime.day == now.day && localDateTime.month == now.month && localDateTime.year == now.year) {
      return roughTimeString;
    }

    DateTime yesterday = now.subtract(const Duration(days: 1));

    if (localDateTime.day == yesterday.day && localDateTime.month == yesterday.month && localDateTime.year == yesterday.year) {
      return 'Yesterday, ' + roughTimeString;
    }

    if (now.difference(localDateTime).inDays < 4) {
      String weekday = DateFormat('EEEE').format(localDateTime);

      return '$weekday, $roughTimeString';
    }

    return '${DateFormat('MMM dd yyyy').format(startDateTime)}, $roughTimeString';

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

  static Future<SecretKey?> getSecretKey({required String publicKey, required String privateKey}) async{
    SecretKey? _sharedSecretKey;
    final encryptionAlgorithm = X25519();
    List<int> publicKeyBytes =
    (jsonDecode(publicKey) as List)
        .map((e) => int.parse(e.toString()))
        .toList();

    List<int> privateKeyBytes = (jsonDecode(privateKey) as List)
        .map((e) => int.parse(e.toString()))
        .toList();

    debugPrint('Private key is $privateKeyBytes');

    final doctorPublicKey =
    SimplePublicKey(publicKeyBytes, type: KeyPairType.x25519);

    final keyPair = SimpleKeyPairData(privateKeyBytes,
        publicKey: doctorPublicKey, type: KeyPairType.x25519);

    _sharedSecretKey = await encryptionAlgorithm.sharedSecretKey(
        keyPair: keyPair, remotePublicKey: doctorPublicKey);

    return _sharedSecretKey;
  }

  static Future<String?> encryptMessage({required String message, required SecretKey secretKey}) async {
    SecretBox? _secretBox;
    ///Encryption algorithm
    final algorithm = AesCtr.with256bits(macAlgorithm: Hmac.sha256());
    ///Message we want to encrypt
    final utfEncodedMessage = utf8.encode(message);

    ///Encrypt
    _secretBox = await algorithm.encrypt(
      utfEncodedMessage,
      secretKey: secretKey,
    );

    ChatMessageEncryptionModel chatMessageEncryptionModel =
    ChatMessageEncryptionModel();
    chatMessageEncryptionModel.cipherText = _secretBox.cipherText;
    chatMessageEncryptionModel.nonce = _secretBox.nonce;
    chatMessageEncryptionModel.macBytes = _secretBox.mac.bytes;

    return jsonEncode(chatMessageEncryptionModel);
  }

  static Future<String?> decryptMessage({required String? message, required SecretKey secretKey}) async {
    debugPrint('Message to decrypt is $message');


    ///Encryption algorithm
    final algorithm = AesCtr.with256bits(macAlgorithm: Hmac.sha256());
    String? decryptedMessage;
    List<int> decodedText;

    try{
      if(message != null) {
        ChatMessageEncryptionModel chatMessageEncryptionModel =
        ChatMessageEncryptionModel.fromJson(jsonDecode(message));

        SecretBox secretBox = SecretBox(chatMessageEncryptionModel.cipherText!,
            nonce: chatMessageEncryptionModel.nonce!,
            mac: Mac(chatMessageEncryptionModel.macBytes!));

        ///Decrypt
        decodedText = await algorithm.decrypt(
          secretBox,
          secretKey: secretKey,
        );

        decryptedMessage = utf8.decode(decodedText);
      }
    } catch (e) {
      debugPrint('Decrypt exception is $e');
    }

    return decryptedMessage;
  }

  static String getSlotDividerDisplayDate({required DateTime date}){
    String displayDate = '';
    DateFormat format = DateFormat('MMMM d');
    displayDate = format.format(date);
    return displayDate;
  }
}