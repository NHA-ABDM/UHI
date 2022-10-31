import 'dart:io';

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
import 'package:uhi_flutter_app/model/request/src/login_init_request_model.dart';
import 'package:uhi_flutter_app/theme/theme.dart';
import 'package:uhi_flutter_app/view/authentication/login/src/otp_verification.dart';
import 'package:pointycastle/asymmetric/api.dart';

class LoginWithEmailPage extends StatefulWidget {
  //const LoginWithEmailPage({Key? key}) : super(key: key);

  @override
  State<LoginWithEmailPage> createState() => _LoginWithEmailPageState();
}

class _LoginWithEmailPageState extends State<LoginWithEmailPage> {
  ///CONTROLLERS
  final accessTokenController = Get.put(AccessTokenController());

  ///SIZE
  var width;
  var height;
  var isPortrait;
  bool showName = true;
  bool showSpecialty = true;
  bool showTimeSlots = true;
  final emailTextFieldController = TextEditingController();
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

  Future<Encrypted> encryptEmailId() async {
    var pubKey = await rootBundle.load("assets/keys/public.pem");
    String dir = (await getApplicationDocumentsDirectory()).path;

    writeToFile(pubKey, '$dir/public.pem');
    final publicKey =
        await parseKeyFromFile<RSAPublicKey>(File('$dir/public.pem').path);
    final encrypter = Encrypter(RSA(
      publicKey: publicKey,
    ));
    final encrypted = encrypter.encrypt(emailTextFieldController.text);
    return encrypted;
  }

  callAccessTokenApi() async {
    await accessTokenController.postAccessTokenAPI();
  }

  ///APIs
  callApi() async {
    await callAccessTokenApi();
    loginInitController.refresh();
    LoginInitRequestModel initRequestModel = LoginInitRequestModel();
    initRequestModel.authMode = "EMAIL_OTP";
    initRequestModel.purpose = "CM_ACCESS";
    LoginInitRequester initRequester = LoginInitRequester();
    initRequester.id = "phr_001";
    initRequester.type = "PHR";
    initRequestModel.requester = initRequester;
    Encrypted encrypted = await encryptEmailId();
    initRequestModel.value = encrypted.base64; //Encrypted mobile number
    await loginInitController.postInitAuth(loginDetails: initRequestModel);
    hideProgressDialog();
    loginInitController.loginInitResponseModel != null
        ? navigateToOtpVerificationPage(
            loginInitController.loginInitResponseModel!.transactionId)
        : null;
  }

  navigateToOtpVerificationPage(String? transactionId) {
    debugPrint("transactionId in Auth init:$transactionId");
    Get.to(OTPVerificationPage(
      emailId: emailTextFieldController.text,
      isFromMobile: false,
      transactionId: transactionId,
    ));
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
              controller: emailTextFieldController,
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
                if (emailTextFieldController.text.isEmpty) {
                  DialogHelper.showErrorDialog(
                      title: AppStrings().errorString,
                      description: AppStrings().enterEmailIdMsg);
                } else if (isEmail(emailTextFieldController.text)) {
                  showProgressDialog();
                  callApi();
                } else {
                  DialogHelper.showErrorDialog(
                      title: AppStrings().errorString,
                      description: AppStrings().invalidEmailError);
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
