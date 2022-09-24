import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uhi_flutter_app/common/common.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/controller/login/src/access_token_controller.dart';
import 'package:uhi_flutter_app/controller/login/src/login_init_controller.dart';
import 'package:uhi_flutter_app/controller/login/src/post_fcm_token_controller.dart';
import 'package:uhi_flutter_app/model/common/src/fcm_token_model.dart';
import 'package:uhi_flutter_app/model/request/src/login_abha_address_init_request_model.dart';
import 'package:uhi_flutter_app/model/request/src/login_verify_request_model.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'package:uhi_flutter_app/view/authentication/login/src/otp_verification.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:uhi_flutter_app/view/home/src/home_page.dart';

class LoginWithAbhaAddressPage extends StatefulWidget {
  //const LoginWithEmailPage({Key? key}) : super(key: key);

  @override
  State<LoginWithAbhaAddressPage> createState() =>
      _LoginWithAbhaAddressPageState();
}

class _LoginWithAbhaAddressPageState extends State<LoginWithAbhaAddressPage> {
  ///CONTROLLERS
  final accessTokenController = Get.put(AccessTokenController());
  final postFcmTokenController = Get.put(PostFCMTokenController());

  ///SIZE
  var width;
  var height;
  var isPortrait;
  bool showName = true;
  bool showSpecialty = true;
  bool showTimeSlots = true;
  final abhaAddressTextFieldController = TextEditingController();
  final passwordTextFieldController = TextEditingController();
  final loginInitController = Get.put(LoginInitController());
  bool _loading = false;
  @override
  void initState() {
    super.initState();
  }

  void showProgressDialog() {
    setState(() {
      _loading = true;
    });
  }

  void hideProgressDialog() {
    setState(() {
      _loading = false;
    });
  }

  Future writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future<Encrypted> encryptPassword() async {
    var pubKey = await rootBundle.load("assets/keys/public.pem");
    String dir = (await getApplicationDocumentsDirectory()).path;

    writeToFile(pubKey, '$dir/public.pem');
    final publicKey =
        await parseKeyFromFile<RSAPublicKey>(File('$dir/public.pem').path);
    final encrypter = Encrypter(RSA(
      publicKey: publicKey,
    ));
    final encrypted = encrypter.encrypt(passwordTextFieldController.text);
    return encrypted;
  }

  callAccessTokenApi() async {
    await accessTokenController.postAccessTokenAPI();
  }

  ///APIs
  callApi() async {
    await callAccessTokenApi();
    loginInitController.refresh();
    LoginInitRequester initRequester = LoginInitRequester();
    initRequester.id = "phr_001";
    initRequester.type = "PHR";
    LoginAbhaAddressInitRequestModel initRequestModel =
        LoginAbhaAddressInitRequestModel();
    initRequestModel.authMode = "PASSWORD";
    initRequestModel.purpose = "CM_ACCESS";
    initRequestModel.requester = initRequester;
    initRequestModel.patientId =
        abhaAddressTextFieldController.text; //Encrypted mobile number
    await loginInitController.postAbhaAddressInitAuth(
        loginDetails: initRequestModel);
    hideProgressDialog();
    loginInitController.loginInitResponseModel != null
        ? callPasswordApi()
        : null;
  }

  callPasswordApi() async {
    SharedPreferencesHelper.setTransactionId(
        loginInitController.loginInitResponseModel?.transactionId!);
    loginInitController.refresh();
    String? transactionId = await SharedPreferencesHelper.getTransactionId();
    LoginVerifyRequestModel loginVerifyRequestModel = LoginVerifyRequestModel();
    Encrypted encrypted = await encryptPassword();
    loginVerifyRequestModel.authCode = encrypted.base64;
    loginVerifyRequestModel.requesterId = "phr_001";
    loginVerifyRequestModel.transactionId = transactionId;
    await loginInitController.postAbhaAddressAuthConfirm(
        loginDetails: loginVerifyRequestModel);
    hideProgressDialog();
    loginInitController.loginInitResponseModel != null
        ? navigateToHomePage(abhaAddressTextFieldController.text)
        : null;
  }

  navigateToHomePage(String selectedAbhaAddress) {
    postFcmToken(selectedAbhaAddress);
    SharedPreferencesHelper.setAutoLoginFlag(true);
    Get.to(HomePage());
  }

  // TODO-CHECK THIS FUNC
  ///SAVE FCM TOKEN API
  postFcmToken(String? selectedAbhaAddress) async {
    FCMTokenModel fcmTokenModel = FCMTokenModel();
    fcmTokenModel.userName = selectedAbhaAddress;
    fcmTokenModel.token = "";
    fcmTokenModel.deviceId = await _getId();
    fcmTokenModel.type = Platform.operatingSystem;
    // log("${json.encode(fcmTokenModel)}", name: "FCM TOKEN MODEL");
    await postFcmTokenController.postFCMTokenDetails(
        fcmTokenDetails: fcmTokenModel);

    if (postFcmTokenController.fcmTokenAckDetails["status"] == 200) {
      SharedPreferencesHelper.setFCMToken("");
    }
  }

  Future<String?> _getId() async {
    var deviceInfo = DeviceInfoPlugin();
    if (Platform.isIOS) {
      // import 'dart:io'
      var iosDeviceInfo = await deviceInfo.iosInfo;
      return iosDeviceInfo.identifierForVendor; // unique ID on iOS
    } else if (Platform.isAndroid) {
      var androidDeviceInfo = await deviceInfo.androidInfo;
      return androidDeviceInfo.androidId; // unique ID on Android
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    ///ASSIGNING VALUES
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    isPortrait = MediaQuery.of(context).orientation;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.white,
        shadowColor: Colors.black.withOpacity(0.1),
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.chevron_left_rounded,
            color: AppColors.darkGrey323232,
            size: 32,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        titleSpacing: 0,
        title: Text(
          AppStrings().loginWithEmail,
          style:
              AppTextStyle.textBoldStyle(color: AppColors.black, fontSize: 16),
        ),
      ),
      body: ModalProgressHUD(
        child: buildWidgets(),
        inAsyncCall: _loading,
        dismissible: false,
        progressIndicator: const CircularProgressIndicator(
          backgroundColor: AppColors.DARK_PURPLE,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.amountColor),
        ),
      ),
    );
  }

  buildWidgets() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings().enterEmail,
            style: AppTextStyle.textMediumStyle(
                color: AppColors.mobileNumberTextColor, fontSize: 14),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 50,
            width: width * 0.9,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.doctorExperienceColor,
              ),
            ),
            child: TextFormField(
              controller: abhaAddressTextFieldController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                border: InputBorder.none,
                hintText: AppStrings().hintEmail,
                hintStyle: AppTextStyle.textLightStyle(
                    color: AppColors.testColor, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            height: 50,
            width: width * 0.9,
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.doctorExperienceColor,
              ),
            ),
            child: TextFormField(
              controller: passwordTextFieldController,
              decoration: InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                border: InputBorder.none,
                hintText: AppStrings().hintEmail,
                hintStyle: AppTextStyle.textLightStyle(
                    color: AppColors.testColor, fontSize: 14),
              ),
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                if (abhaAddressTextFieldController.text.isEmpty) {
                  DialogHelper.showErrorDialog(
                      title: AppStrings().errorString,
                      description: "Enter Your Abha Address");
                } else if (passwordTextFieldController.text.isEmpty) {
                  DialogHelper.showErrorDialog(
                      title: AppStrings().errorString,
                      description: "Enter Your Password");
                } else {
                  showProgressDialog();
                  callApi();
                }
              },
              child: Container(
                height: 50,
                width: width * 0.89,
                decoration: const BoxDecoration(
                  color: AppColors.tileColors,
                  borderRadius: BorderRadius.all(
                    Radius.circular(10),
                  ),
                ),
                child: Center(
                  child: Text(
                    AppStrings().btnContinue,
                    style: AppTextStyle.textMediumStyle(
                        color: AppColors.white, fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  bool isEmail(String em) {
    String p =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regExp = RegExp(p);
    return regExp.hasMatch(em);
  }

  showAlertDialog(BuildContext context, String title, String body) {
    // set up the button
    Widget okButton = TextButton(
      child: const Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [
        okButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
