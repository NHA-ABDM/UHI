import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:encrypt/encrypt.dart';
import 'package:encrypt/encrypt_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:uhi_flutter_app/constants/src/strings.dart';
import 'package:uhi_flutter_app/controller/login/src/login_confirm_controller.dart';
import 'package:uhi_flutter_app/controller/login/src/login_verify_controller.dart';
import 'package:uhi_flutter_app/model/model.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/utils/src/shared_preferences.dart';
import 'package:pointycastle/asymmetric/api.dart';
import 'package:uhi_flutter_app/view/view.dart';

import '../../../../common/common.dart';
import '../../../../controller/login/login.dart';
import '../../../../controller/login/src/access_token_controller.dart';
import '../../../../controller/login/src/post_fcm_token_controller.dart';
import '../../../../model/common/src/fcm_token_model.dart';

class OTPVerificationPage extends StatefulWidget {
  String? mobileNumber;
  String? emailId;
  String? fcmToken;
  bool? isFromMobile;

  OTPVerificationPage(
      {this.mobileNumber,
      this.emailId,
      @required this.isFromMobile,
      this.fcmToken});

  @override
  State<OTPVerificationPage> createState() => _OTPVerificationPageState();
}

class _OTPVerificationPageState extends State<OTPVerificationPage> {
  ///CONTROLLERS
  final loginVerifyController = Get.put(LoginVerifyController());
  final loginConfirmController = Get.put(LoginConfirmController());
  final postFcmTokenController = Get.put(PostFCMTokenController());
  final loginInitController = Get.put(LoginInitController());
  //final AccessTokenController commonController = Get.find();
  final accessTokenController = Get.put(AccessTokenController());

  ///SIZE
  var width;
  var height;
  var isPortrait;
  String? mobileNumber;
  String? otpValue;
  List<String>? mappedPhrAddress = [];
  Duration myDuration = Duration(minutes: 10);
  Timer? countdownTimer;
  int timerSeconds = 600;

  ///DATA VARIABLES
  bool _loading = false;

  void startTimer() {
    timerSeconds = 600;
    countdownTimer =
        Timer.periodic(Duration(seconds: 1), (_) => setCountDown());
  }

  void stopTimer() {
    setState(() => countdownTimer!.cancel());
  }

  void resetTimer() {
    stopTimer();
    setState(() => myDuration = Duration(minutes: 10));
  }

  void setCountDown() {
    final reduceSecondsBy = 1;
    setState(() {
      timerSeconds = myDuration.inSeconds - reduceSecondsBy;
      if (timerSeconds < 0) {
        countdownTimer!.cancel();
      } else {
        myDuration = Duration(seconds: timerSeconds);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    startTimer();
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

  @override
  dispose() {
    loginVerifyController.dispose();
    loginConfirmController.dispose();
    super.dispose();
  }

  Future writeToFile(ByteData data, String path) {
    final buffer = data.buffer;
    return File(path).writeAsBytes(
        buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
  }

  Future<Encrypted> encryptOTPNumber() async {
    var pubKey = await rootBundle.load("assets/keys/public.pem");
    String dir = (await getApplicationDocumentsDirectory()).path;

    writeToFile(pubKey, '$dir/public.pem');
    final publicKey =
        await parseKeyFromFile<RSAPublicKey>(File('$dir/public.pem').path);
    final encrypter = Encrypter(RSA(
      publicKey: publicKey,
    ));
    final encrypted = encrypter.encrypt(otpValue!);
    return encrypted;
  }

  callApi() async {
    loginVerifyController.refresh();
    String? transactionId = await SharedPreferencesHelper.getTransactionId();
    LoginVerifyRequestModel loginVerifyRequestModel = LoginVerifyRequestModel();
    Encrypted encrypted = await encryptOTPNumber();
    loginVerifyRequestModel.authCode = encrypted.base64;
    loginVerifyRequestModel.requesterId = "phr_001";
    loginVerifyRequestModel.transactionId = transactionId;

    await loginVerifyController.postVerify(
        loginDetails: loginVerifyRequestModel);
    hideProgressDialog();
    mappedPhrAddress =
        loginVerifyController.loginVerifyResponseModel?.mappedPhrAddress!;
    loginVerifyController.loginVerifyResponseModel != null
        ? navigateToLinkAccountPage()
        : null;
  }

  navigateToLinkAccountPage() {
    stopTimer();
    if (mappedPhrAddress!.length > 1) {
      SharedPreferencesHelper.setTransactionId(
          loginVerifyController.loginVerifyResponseModel?.transactionId!);
      Get.to(ABHAAddressSelectionPage(
        mappedPhrAddress: mappedPhrAddress!,
        fcmToken: widget.fcmToken,
      ));
    } else {
      showProgressDialog();
      callAuthenticationOfAbhaAddressApi(mappedPhrAddress![0]);
    }
  }

  callAuthenticationOfAbhaAddressApi(String selectedAbhaAddress) async {
    loginConfirmController.refresh();
    String? transactionId = await SharedPreferencesHelper.getTransactionId();
    LoginConfirmRequestModel confirmRequestModel = LoginConfirmRequestModel();
    confirmRequestModel.patientId = selectedAbhaAddress;
    confirmRequestModel.requesterId = "phr_001";
    confirmRequestModel.transactionId = transactionId;

    await loginConfirmController.postConfirm(loginDetails: confirmRequestModel);
    hideProgressDialog();
    loginConfirmController.loginConfirmResponseModel != null
        ? navigateToHomePage(selectedAbhaAddress)
        : null;
  }

  navigateToHomePage(String selectedAbhaAddress) {
    postFcmToken(selectedAbhaAddress);
    SharedPreferencesHelper.setAutoLoginFlag(true);
    Get.offAll(HomePage());
  }

  ///SAVE FCM TOKEN API
  postFcmToken(String? selectedAbhaAddress) async {
    FCMTokenModel fcmTokenModel = FCMTokenModel();
    fcmTokenModel.userName = selectedAbhaAddress;
    fcmTokenModel.token = widget.fcmToken;
    fcmTokenModel.deviceId = await _getId();
    fcmTokenModel.type = Platform.operatingSystem;

    log("${json.encode(fcmTokenModel)}", name: "FCM TOKEN MODEL");

    await postFcmTokenController.postFCMTokenDetails(
        fcmTokenDetails: fcmTokenModel);

    if (postFcmTokenController.fcmTokenAckDetails["status"] == 200) {
      SharedPreferencesHelper.setFCMToken(widget.fcmToken);
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
      backgroundColor: AppColors.white,
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
          widget.isFromMobile == true
              ? AppStrings().loginWithMobileNumber
              : AppStrings().loginWithEmail,
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
    String strDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = strDigits(myDuration.inMinutes.remainder(60));
    final seconds = strDigits(myDuration.inSeconds.remainder(60));
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings().sentOTPOn +
                " " +
                (widget.isFromMobile == true
                    ? widget.mobileNumber!
                    : widget.emailId!),
            style: AppTextStyle.textMediumStyle(
                color: AppColors.mobileNumberTextColor, fontSize: 12),
          ),
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Container(
                height: 50,
                color: Colors.white,
                width: width * 0.88,
                child: Form(
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 0.0, horizontal: 0),
                      child: PinCodeTextField(
                        textStyle:
                            const TextStyle(color: Colors.black, fontSize: 12),
                        appContext: context,
                        length: 6,
                        validator: (v) {
                          otpValue = v;
                          // if (v!.length < 6) {
                          //   return AppStrings().invalidOTP;
                          // } else {
                          //   return null;
                          // }
                          return null;
                        },
                        pinTheme: PinTheme(
                            shape: PinCodeFieldShape.box,
                            borderRadius: BorderRadius.circular(5),
                            fieldHeight: 30,
                            fieldWidth: 40,
                            selectedFillColor: Colors.grey,
                            activeFillColor: Colors.white,
                            inactiveFillColor: Colors.white,
                            selectedColor: Colors.white,
                            inactiveColor: Colors.grey,
                            borderWidth: 1),
                        cursorColor: Colors.black,
                        enableActiveFill: true,
                        keyboardType: TextInputType.number,
                        onCompleted: (v) {
                          debugPrint("Completed:$v");
                          otpValue = v;
                        },
                        onChanged: (value) {},
                      )),
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(
                onTap: () {
                  if (timerSeconds < 0) {
                    resetTimer();
                    showProgressDialog();
                    callResendOPTApi();
                  }
                },
                child: Text(
                  AppStrings().resendOTP,
                  style: AppTextStyle.textNormalStyle(
                      color: timerSeconds < 0 ? Colors.blue : Colors.grey,
                      fontSize: 14),
                ),
              ),
              Text(
                AppStrings().expiresIn + ' $minutes Mins $seconds Secs',
                style: AppTextStyle.textNormalStyle(
                    color: AppColors.amountColor, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(
            height: 30,
          ),
          Center(
            child: GestureDetector(
              onTap: () {
                if (otpValue == null) {
                  showAlertDialog(
                      context, AppStrings().errorString, AppStrings().emptyOTP);
                } else if (otpValue!.length != 6) {
                  showAlertDialog(context, AppStrings().errorString,
                      AppStrings().invalidOTP);
                } else {
                  showProgressDialog();
                  callApi();
                }

                //Get.to(const LinkAccountsPage());
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

  callAccessTokenApi() async {
    accessTokenController.refresh();
    await accessTokenController.postAccessTokenAPI();
  }

  callResendOPTApi() async {
    await callAccessTokenApi();
    loginInitController.refresh();
    LoginInitRequestModel initRequestModel = LoginInitRequestModel();
    initRequestModel.authMode = "MOBILE_OTP";
    initRequestModel.purpose = "CM_ACCESS";
    LoginInitRequester initRequester = LoginInitRequester();
    initRequester.id = "phr_001";
    initRequester.type = "PHR";
    initRequestModel.requester = initRequester;
    try {
      Encrypted encrypted = await encryptMobileNumber();
      initRequestModel.value = encrypted.base64;
    } catch (error) {
      DialogHelper.showErrorDialog(
          title: AppStrings().errorString,
          description: AppStrings().somethingWentWrongErrorMsg);
      hideProgressDialog();
    }
    await loginInitController.postInitAuth(loginDetails: initRequestModel);
    hideProgressDialog();
    loginInitController.loginInitResponseModel != null ? startTimer() : null;
  }

  Future<Encrypted> encryptMobileNumber() async {
    var pubKey = await rootBundle.load("assets/keys/public.pem");
    String dir = (await getApplicationDocumentsDirectory()).path;

    writeToFile(pubKey, '$dir/public.pem');
    final publicKey =
        await parseKeyFromFile<RSAPublicKey>(File('$dir/public.pem').path);
    final encryptedString = Encrypter(RSA(
      publicKey: publicKey,
    ));
    final encrypted = encryptedString.encrypt(
        widget.isFromMobile == true ? widget.mobileNumber! : widget.emailId!);
    return encrypted;
  }
}
